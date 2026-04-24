import '../domain/state/adaptive_state.dart';
import 'decision_engine.dart';
import 'loaded_policy.dart';

/// High-level runtime wrapper around a loaded policy and its decision engine.
///
/// This engine represents the executable runtime core used by the broader
/// adaptive gamification library.
class AdaptiveRuntimeEngine {
  /// Loaded policy used by the runtime.
  final LoadedPolicy loadedPolicy;

  /// Core decision engine used for deterministic execution.
  final DecisionEngine decisionEngine;

  /// Creates an adaptive runtime engine.
  const AdaptiveRuntimeEngine({
    required this.loadedPolicy,
    required this.decisionEngine,
  });

  /// Executes the runtime for the given [inputState].
  DecisionExecutionResult execute({
    required AdaptiveState inputState,
    String? sessionId,
    String? interactionId,
  }) {
    return decisionEngine.execute(
      inputState: inputState,
      sessionId: sessionId,
      interactionId: interactionId,
    );
  }

  /// Returns whether the loaded policy is valid.
  bool get isValid => loadedPolicy.isValid;

  /// Returns the number of indexed runtime policy entries.
  int get policySize => loadedPolicy.policySize;

  @override
  String toString() {
    return 'AdaptiveRuntimeEngine('
        'isValid: $isValid, '
        'policySize: $policySize, '
        'loadedPolicy: $loadedPolicy'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdaptiveRuntimeEngine &&
            other.loadedPolicy == loadedPolicy &&
            other.decisionEngine == decisionEngine);
  }

  @override
  int get hashCode => Object.hash(loadedPolicy, decisionEngine);
}