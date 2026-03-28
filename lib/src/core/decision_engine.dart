import '../models/adaptive_decision.dart';
import '../models/user_state.dart';
import '../utils/state_mapper.dart';

/// Executes deterministic adaptive decisions from a loaded policy index.
///
/// The engine:
/// - maps [UserState] into the deployment-facing RL state
/// - builds the exported lookup key
/// - retrieves the matching policy entry
/// - returns an [AdaptiveDecision]
/// - falls back deterministically when no exact entry is found
class DecisionEngine {
  /// Creates a decision engine over a loaded policy index.
  ///
  /// [policyIndex] must contain entries keyed using the Python-compatible
  /// deployment key format:
  /// `eng=0.25|mot=0.50|flow=0.75|perf=1.00`
  ///
  /// [stateDecimals] controls fixed-decimal key formatting.
  ///
  /// [grid] controls discretization before lookup.
  DecisionEngine(
      this.policyIndex, {
        this.stateDecimals = 2,
        this.grid = StateMapper.defaultGrid,
      });

  /// Full exported policy index:
  /// key -> entry
  ///
  /// Each entry is expected to contain:
  /// - `state`
  /// - `action`
  /// - `decision`
  /// - `probs`
  /// - `value`
  final Map<String, Map<String, dynamic>> policyIndex;

  /// Number of decimals used in exported policy keys.
  final int stateDecimals;

  /// Grid used for runtime discretization.
  final double grid;

  /// Computes the adaptive decision for a given runtime [userState].
  ///
  /// If an exact policy entry exists, the decision is returned from the
  /// exported policy.
  ///
  /// Otherwise, a deterministic fallback decision is generated.
  AdaptiveDecision decide(UserState userState) {
    final List<double> rl = StateMapper.toRlState(userState);

    final String key = StateMapper.buildKeyFromRlState(
      rl,
      grid: grid,
      decimals: stateDecimals,
    );

    final Map<String, dynamic>? entry = policyIndex[key];
    if (entry == null) {
      return _fallback(userState, rl);
    }

    final Map<String, dynamic>? decision = _asStringKeyMap(entry['decision']);
    if (decision == null) {
      return _fallback(userState, rl);
    }

    final String nextDifficulty =
    (decision['next_difficulty'] ?? 'medium').toString();

    final String supportStrategy =
    (decision['support_strategy'] ?? 'policy_lookup').toString();

    final String sourceActionName =
    (decision['source_action_name'] ??
        entry['source_action_name'] ??
        'policy')
        .toString();

    final String reason = (decision['reason'] ?? 'policy_lookup').toString();

    return AdaptiveDecision(
      nextDifficulty: nextDifficulty,
      reason: reason,
      supportStrategy: supportStrategy,
      sourceActionName: sourceActionName,
      lookupKey: key,
      foundExactMatch: true,
    );
  }

  AdaptiveDecision _fallback(UserState s, List<double> rl) {
    final double eng = rl[0];
    final double mot = rl[1];
    final double flow = rl[2];
    final double perf = rl[3];

    // Strong recovery case
    if (mot < 0.30 && eng < 0.35) {
      return const AdaptiveDecision(
        nextDifficulty: 'easy',
        reason: 'fallback_recovery_low_motivation_and_engagement',
        foundExactMatch: false,
      );
    }

    // Low flow and weak performance -> reduce pressure
    if (flow < 0.28 && perf < 0.40) {
      return const AdaptiveDecision(
        nextDifficulty: 'easy',
        reason: 'fallback_low_flow_low_performance',
        foundExactMatch: false,
      );
    }

    // Strong readiness -> increase challenge
    if (perf >= 0.80 && flow >= 0.60 && mot >= 0.45) {
      return const AdaptiveDecision(
        nextDifficulty: 'hard',
        reason: 'fallback_high_readiness',
        foundExactMatch: false,
      );
    }

    // Mid balanced case
    if (perf >= 0.45 && perf <= 0.75 && flow >= 0.45) {
      return const AdaptiveDecision(
        nextDifficulty: 'medium',
        reason: 'fallback_balanced_mid_zone',
        foundExactMatch: false,
      );
    }

    // Conservative fallback using accuracy as last simple signal
    if (s.accuracy >= 0.80) {
      return const AdaptiveDecision(
        nextDifficulty: 'hard',
        reason: 'fallback_high_accuracy',
        foundExactMatch: false,
      );
    }

    if (s.accuracy <= 0.30) {
      return const AdaptiveDecision(
        nextDifficulty: 'easy',
        reason: 'fallback_low_accuracy',
        foundExactMatch: false,
      );
    }

    return const AdaptiveDecision(
      nextDifficulty: 'medium',
      reason: 'fallback_default_medium',
      foundExactMatch: false,
    );
  }

  static Map<String, dynamic>? _asStringKeyMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map<dynamic, dynamic>) {
      final Map<String, dynamic> out = <String, dynamic>{};
      value.forEach((dynamic k, dynamic v) {
        out[k.toString()] = v;
      });
      return out;
    }
    return null;
  }
}