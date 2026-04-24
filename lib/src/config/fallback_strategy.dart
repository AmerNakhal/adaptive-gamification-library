import '../domain/decisions/adaptive_decision.dart';
import '../domain/policy/policy_metadata.dart';
import '../domain/state/adaptive_state.dart';

/// Strategy abstraction used when an exact runtime policy match is unavailable.
///
/// Different fallback strategies may implement different recovery behaviors,
/// such as:
/// - returning a fixed adaptive decision
/// - using a deterministic default decision
/// - selecting the first stable indexed entry
/// - using a nearest-state heuristic
abstract class FallbackStrategy {
  /// Creates a fallback strategy.
  const FallbackStrategy();

  /// Resolves a fallback decision.
  ///
  /// Parameters:
  /// - [state]: the runtime adaptive state used during execution
  /// - [indexedPolicy]: the indexed policy map currently available
  /// - [metadata]: exported policy metadata
  /// - [reason]: optional explanation describing why fallback was triggered
  AdaptiveDecision resolve({
    required AdaptiveState state,
    required Map<String, AdaptiveDecision> indexedPolicy,
    required PolicyMetadata metadata,
    String? reason,
  });
}

/// Default deterministic fallback strategy.
///
/// Behavior:
/// 1. If indexed policy entries exist, returns the lexicographically first
///    indexed decision as a deterministic fallback.
/// 2. Otherwise, returns a conservative built-in fallback decision.
///
/// This strategy prioritizes:
/// - deterministic behavior
/// - stable testing outcomes
/// - safe default execution
class DefaultFallbackStrategy extends FallbackStrategy {
  /// Creates the default fallback strategy.
  const DefaultFallbackStrategy({
    this.defaultDifficulty = 1,
    this.defaultActionLabel = 'default_fallback',
    this.defaultEmptyPolicyReason = 'empty_indexed_policy',
  });

  /// Default difficulty rank or index used when no policy entries exist.
  final int defaultDifficulty;

  /// Default action label used when no policy entries exist.
  final String? defaultActionLabel;

  /// Default human-readable reason used when indexed policy is empty and no
  /// explicit reason is provided.
  final String defaultEmptyPolicyReason;

  @override
  AdaptiveDecision resolve({
    required AdaptiveState state,
    required Map<String, AdaptiveDecision> indexedPolicy,
    required PolicyMetadata metadata,
    String? reason,
  }) {
    if (indexedPolicy.isNotEmpty) {
      final sortedKeys = indexedPolicy.keys.toList()..sort();
      final selectedKey = sortedKeys.first;
      final selectedDecision = indexedPolicy[selectedKey]!;

      return selectedDecision.copyWith(
        source: 'fallback',
        reason: reason ?? 'missing_state_key',
      );
    }

    return AdaptiveDecision(
      nextDifficulty: defaultDifficulty,
      source: 'fallback',
      reason: reason ?? defaultEmptyPolicyReason,
      actionLabel: defaultActionLabel,
    );
  }
}

/// A deterministic fallback strategy that always returns a fixed decision.
///
/// This is useful for:
/// - controlled experiments
/// - tests
/// - bounded integration scenarios
/// - predictable application-level fallback behavior
class FixedDecisionFallbackStrategy extends FallbackStrategy {
  /// Creates a fixed-decision fallback strategy.
  const FixedDecisionFallbackStrategy(this.decision);

  /// The fixed decision returned whenever fallback is triggered.
  final AdaptiveDecision decision;

  @override
  AdaptiveDecision resolve({
    required AdaptiveState state,
    required Map<String, AdaptiveDecision> indexedPolicy,
    required PolicyMetadata metadata,
    String? reason,
  }) {
    return decision.copyWith(
      source: 'fallback',
      reason: reason ?? decision.reason ?? 'fixed_fallback',
    );
  }
}