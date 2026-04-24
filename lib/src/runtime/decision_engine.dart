import '../config/fallback_strategy.dart';
import '../domain/analytics/runtime_diagnostics.dart';
import '../domain/decisions/adaptive_decision.dart';
import '../domain/decisions/decision_context.dart';
import '../domain/decisions/decision_source.dart';
import '../domain/policy/policy_metadata.dart';
import '../domain/state/adaptive_state.dart';
import 'state_key_builder.dart';

/// Result of a single runtime decision execution.
class DecisionExecutionResult {
  /// The adaptive decision produced by the runtime.
  final AdaptiveDecision decision;

  /// The decision context associated with the execution.
  final DecisionContext context;

  /// Optional lightweight runtime diagnostics.
  final RuntimeDiagnostics? diagnostics;

  /// Creates a decision execution result.
  const DecisionExecutionResult({
    required this.decision,
    required this.context,
    this.diagnostics,
  });

  @override
  String toString() {
    return 'DecisionExecutionResult('
        'decision: $decision, '
        'context: $context, '
        'diagnostics: $diagnostics'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DecisionExecutionResult &&
            other.decision == decision &&
            other.context == context &&
            other.diagnostics == diagnostics);
  }

  @override
  int get hashCode => Object.hash(decision, context, diagnostics);
}

/// Core runtime decision engine for deterministic adaptive execution.
///
/// Responsibilities:
/// - normalize input state
/// - build deterministic state key
/// - perform exact lookup
/// - apply fallback when needed
/// - build decision context
/// - optionally produce runtime diagnostics
class DecisionEngine {
  /// Runtime-indexed decisions keyed by deterministic state key.
  final Map<String, AdaptiveDecision> indexedDecisions;

  /// Exported policy metadata.
  final PolicyMetadata metadata;

  /// State-key builder used for deterministic lookup.
  final StateKeyBuilder stateKeyBuilder;

  /// Fallback strategy used when no exact state-key match is found.
  final FallbackStrategy fallbackStrategy;

  /// Whether runtime diagnostics should be generated.
  final bool enableDiagnostics;

  /// Creates a runtime decision engine.
  const DecisionEngine({
    required this.indexedDecisions,
    required this.metadata,
    this.stateKeyBuilder = const StateKeyBuilder(),
    this.fallbackStrategy = const DefaultFallbackStrategy(),
    this.enableDiagnostics = false,
  });

  /// Executes a decision lookup for [inputState].
  DecisionExecutionResult execute({
    required AdaptiveState inputState,
    String? sessionId,
    String? interactionId,
  }) {
    final normalizedState = stateKeyBuilder.normalizeState(inputState);
    final generatedStateKey = stateKeyBuilder.build(inputState);

    final warnings = <String>[];
    final exactDecision = indexedDecisions[generatedStateKey];

    late final AdaptiveDecision finalDecision;
    late final DecisionContext context;

    if (exactDecision != null) {
      finalDecision = exactDecision.copyWith(
        source: DecisionSource.exactMatch,
      );

      context = DecisionContext(
        inputState: inputState,
        normalizedState: normalizedState,
        generatedStateKey: generatedStateKey,
        source: DecisionSource.exactMatch,
        sessionId: sessionId,
        interactionId: interactionId,
        warnings: List<String>.unmodifiable(warnings),
      );
    } else {
      final fallbackDecision = fallbackStrategy.resolve(
        state: normalizedState,
        indexedPolicy: indexedDecisions,
        metadata: metadata,
        reason: 'missing_state_key',
      );

      finalDecision = fallbackDecision.copyWith(
        source: DecisionSource.fallback,
        reason: fallbackDecision.reason ?? 'missing_state_key',
      );

      context = DecisionContext(
        inputState: inputState,
        normalizedState: normalizedState,
        generatedStateKey: generatedStateKey,
        source: DecisionSource.fallback,
        fallbackReason: finalDecision.reason,
        sessionId: sessionId,
        interactionId: interactionId,
        warnings: List<String>.unmodifiable(warnings),
      );
    }

    RuntimeDiagnostics? diagnostics;
    if (enableDiagnostics) {
      diagnostics = RuntimeDiagnostics(
        inputState: inputState,
        normalizedState: normalizedState,
        generatedStateKey: generatedStateKey,
        usedExactMatch: context.usedExactMatch,
        usedFallback: context.usedFallback,
        fallbackReason: context.fallbackReason,
        indexedPolicySize: indexedDecisions.length,
        warnings: context.warnings,
        decisionContext: context,
      );
    }

    return DecisionExecutionResult(
      decision: finalDecision,
      context: context,
      diagnostics: diagnostics,
    );
  }

  @override
  String toString() {
    return 'DecisionEngine('
        'indexedDecisionCount: ${indexedDecisions.length}, '
        'metadata: $metadata, '
        'stateKeyBuilder: $stateKeyBuilder, '
        'fallbackStrategy: ${fallbackStrategy.runtimeType}, '
        'enableDiagnostics: $enableDiagnostics'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DecisionEngine &&
            _mapEquals(other.indexedDecisions, indexedDecisions) &&
            other.metadata == metadata &&
            other.stateKeyBuilder == stateKeyBuilder &&
            other.fallbackStrategy.runtimeType ==
                fallbackStrategy.runtimeType &&
            other.enableDiagnostics == enableDiagnostics);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(
        indexedDecisions.entries.map(
              (entry) => Object.hash(entry.key, entry.value),
        ),
      ),
      metadata,
      stateKeyBuilder,
      fallbackStrategy.runtimeType,
      enableDiagnostics,
    );
  }

  static bool _mapEquals(
      Map<String, AdaptiveDecision> a,
      Map<String, AdaptiveDecision> b,
      ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}