import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/runtime/decision_engine.dart';
import 'package:adaptive_gamification/src/runtime/state_key_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecisionEngine', () {
    const metadata = PolicyMetadata(
      formatVersion: '1.0',
      policyType: 'deterministic_lookup_table',
      stateOrder: <String>[
        'engagement',
        'motivation',
        'flow',
        'performance',
      ],
      stateDecimals: 2,
      exportedStateCount: 2,
      actionCount: 6,
    );

    const exactDecisionA = AdaptiveDecision(
      nextDifficulty: 1,
      source: 'exact_match',
      reason: 'stable',
      actionLabel: 'easy_task',
    );

    const exactDecisionB = AdaptiveDecision(
      nextDifficulty: 3,
      source: 'exact_match',
      reason: 'increase challenge',
      actionLabel: 'hard_task',
    );

    const indexedDecisions = <String, AdaptiveDecision>{
      '0.10|0.20|0.30|0.40': exactDecisionA,
      '0.40|0.50|0.60|0.70': exactDecisionB,
    };

    test('execute returns exact-match decision when key exists', () {
      const engine = DecisionEngine(
        indexedDecisions: indexedDecisions,
        metadata: metadata,
      );

      const inputState = AdaptiveState(
        engagement: 0.1,
        motivation: 0.2,
        flow: 0.3,
        performance: 0.4,
      );

      final result = engine.execute(
        inputState: inputState,
      );

      expect(result.decision.nextDifficulty, 1);
      expect(result.decision.source, DecisionSource.exactMatch);
      expect(result.decision.reason, 'stable');
      expect(result.decision.actionLabel, 'easy_task');

      expect(result.context.inputState, inputState);
      expect(result.context.normalizedState, inputState);
      expect(result.context.generatedStateKey, '0.10|0.20|0.30|0.40');
      expect(result.context.source, DecisionSource.exactMatch);
      expect(result.context.usedExactMatch, isTrue);
      expect(result.context.usedFallback, isFalse);
      expect(result.context.fallbackReason, isNull);

      expect(result.diagnostics, isNull);
    });

    test('execute includes sessionId and interactionId in context', () {
      const engine = DecisionEngine(
        indexedDecisions: indexedDecisions,
        metadata: metadata,
      );

      const inputState = AdaptiveState(
        engagement: 0.4,
        motivation: 0.5,
        flow: 0.6,
        performance: 0.7,
      );

      final result = engine.execute(
        inputState: inputState,
        sessionId: 'session_1',
        interactionId: 'interaction_1',
      );

      expect(result.context.sessionId, 'session_1');
      expect(result.context.interactionId, 'interaction_1');
      expect(result.context.generatedStateKey, '0.40|0.50|0.60|0.70');
    });

    test('execute uses fallback when key is missing', () {
      const engine = DecisionEngine(
        indexedDecisions: indexedDecisions,
        metadata: metadata,
      );

      const inputState = AdaptiveState(
        engagement: 0.9,
        motivation: 0.9,
        flow: 0.9,
        performance: 0.9,
      );

      final result = engine.execute(
        inputState: inputState,
      );

      expect(result.decision.source, DecisionSource.fallback);
      expect(result.decision.reason, 'missing_state_key');
      expect(result.context.source, DecisionSource.fallback);
      expect(result.context.usedFallback, isTrue);
      expect(result.context.usedExactMatch, isFalse);
      expect(result.context.fallbackReason, 'missing_state_key');
      expect(result.context.generatedStateKey, '0.90|0.90|0.90|0.90');
    });

    test('default fallback picks lexicographically first decision when indexed policy is not empty', () {
      const engine = DecisionEngine(
        indexedDecisions: indexedDecisions,
        metadata: metadata,
      );

      const inputState = AdaptiveState(
        engagement: 0.8,
        motivation: 0.8,
        flow: 0.8,
        performance: 0.8,
      );

      final result = engine.execute(inputState: inputState);

      expect(result.decision.nextDifficulty, 1);
      expect(result.decision.actionLabel, 'easy_task');
      expect(result.decision.source, DecisionSource.fallback);
      expect(result.decision.reason, 'missing_state_key');
    });

    test('fixed fallback strategy returns provided fixed decision', () {
      const fallbackDecision = AdaptiveDecision(
        nextDifficulty: 4,
        source: 'fallback',
        reason: 'fixed_fallback',
        actionLabel: 'hard_task',
      );

      const engine = DecisionEngine(
        indexedDecisions: indexedDecisions,
        metadata: metadata,
        fallbackStrategy: FixedDecisionFallbackStrategy(fallbackDecision),
      );

      const inputState = AdaptiveState(
        engagement: 0.99,
        motivation: 0.99,
        flow: 0.99,
        performance: 0.99,
      );

      final result = engine.execute(inputState: inputState);

      expect(result.decision.nextDifficulty, 4);
      expect(result.decision.actionLabel, 'hard_task');
      expect(result.decision.source, DecisionSource.fallback);
      expect(result.decision.reason, 'missing_state_key');
    });

    test('execute with diagnostics enabled returns runtime diagnostics', () {
      const engine = DecisionEngine(
        indexedDecisions: indexedDecisions,
        metadata: metadata,
        enableDiagnostics: true,
      );

      const inputState = AdaptiveState(
        engagement: 0.1,
        motivation: 0.2,
        flow: 0.3,
        performance: 0.4,
      );

      final result = engine.execute(
        inputState: inputState,
        sessionId: 'session_2',
        interactionId: 'interaction_2',
      );

      final diagnostics = result.diagnostics;
      expect(diagnostics, isNotNull);
      expect(diagnostics!.inputState, inputState);
      expect(diagnostics.normalizedState, inputState);
      expect(diagnostics.generatedStateKey, '0.10|0.20|0.30|0.40');
      expect(diagnostics.usedExactMatch, isTrue);
      expect(diagnostics.usedFallback, isFalse);
      expect(diagnostics.indexedPolicySize, 2);
      expect(diagnostics.fallbackReason, isNull);
      expect(diagnostics.decisionContext, isNotNull);
      expect(diagnostics.decisionContext!.sessionId, 'session_2');
      expect(diagnostics.decisionContext!.interactionId, 'interaction_2');
    });

    test('execute with diagnostics enabled includes fallback info', () {
      const engine = DecisionEngine(
        indexedDecisions: indexedDecisions,
        metadata: metadata,
        enableDiagnostics: true,
      );

      const inputState = AdaptiveState(
        engagement: 0.77,
        motivation: 0.77,
        flow: 0.77,
        performance: 0.77,
      );

      final result = engine.execute(inputState: inputState);

      final diagnostics = result.diagnostics;
      expect(diagnostics, isNotNull);
      expect(diagnostics!.usedExactMatch, isFalse);
      expect(diagnostics.usedFallback, isTrue);
      expect(diagnostics.fallbackReason, 'missing_state_key');
      expect(diagnostics.generatedStateKey, '0.77|0.77|0.77|0.77');
    });

    test('execute respects custom StateKeyBuilder decimals', () {
      const engine = DecisionEngine(
        indexedDecisions: <String, AdaptiveDecision>{
          '0.123|0.235|0.346|0.457': AdaptiveDecision(
            nextDifficulty: 2,
            source: 'exact_match',
            actionLabel: 'medium_task',
          ),
        },
        metadata: metadata,
        stateKeyBuilder: StateKeyBuilder(decimals: 3),
      );

      const inputState = AdaptiveState(
        engagement: 0.1234,
        motivation: 0.2345,
        flow: 0.3456,
        performance: 0.4567,
      );

      final result = engine.execute(inputState: inputState);

      expect(result.context.generatedStateKey, '0.123|0.235|0.346|0.457');
      expect(result.decision.nextDifficulty, 2);
      expect(result.decision.source, DecisionSource.exactMatch);
    });

    test('execute respects non-clamping StateKeyBuilder', () {
      const engine = DecisionEngine(
        indexedDecisions: <String, AdaptiveDecision>{
          '-0.50|1.50|0.50|2.00': AdaptiveDecision(
            nextDifficulty: 3,
            source: 'exact_match',
            actionLabel: 'hard_task',
          ),
        },
        metadata: metadata,
        stateKeyBuilder: StateKeyBuilder(
          clampValues: false,
        ),
      );

      const inputState = AdaptiveState(
        engagement: -0.5,
        motivation: 1.5,
        flow: 0.5,
        performance: 2.0,
      );

      final result = engine.execute(inputState: inputState);

      expect(result.context.generatedStateKey, '-0.50|1.50|0.50|2.00');
      expect(result.context.normalizedState.engagement, -0.5);
      expect(result.context.normalizedState.performance, 2.0);
      expect(result.decision.source, DecisionSource.exactMatch);
    });

    test('execute clamps normalized state when builder clamps values', () {
      const engine = DecisionEngine(
        indexedDecisions: <String, AdaptiveDecision>{},
        metadata: metadata,
        stateKeyBuilder: StateKeyBuilder(
          clampValues: true,
        ),
      );

      const inputState = AdaptiveState(
        engagement: -0.5,
        motivation: 1.5,
        flow: 0.5,
        performance: 2.0,
      );

      final result = engine.execute(inputState: inputState);

      expect(result.context.normalizedState.engagement, 0.0);
      expect(result.context.normalizedState.motivation, 1.0);
      expect(result.context.normalizedState.flow, 0.5);
      expect(result.context.normalizedState.performance, 1.0);
      expect(result.context.generatedStateKey, '0.00|1.00|0.50|1.00');
    });

    test('toString contains important fields', () {
      const engine = DecisionEngine(
        indexedDecisions: indexedDecisions,
        metadata: metadata,
        enableDiagnostics: true,
      );

      final text = engine.toString();

      expect(text, contains('DecisionEngine'));
      expect(text, contains('indexedDecisionCount: 2'));
      expect(text, contains('metadata:'));
      expect(text, contains('stateKeyBuilder:'));
      expect(text, contains('enableDiagnostics: true'));
    });

    test('DecisionExecutionResult equality works for identical values', () {
      const context = DecisionContext(
        inputState: AdaptiveState(
          engagement: 0.1,
          motivation: 0.2,
          flow: 0.3,
          performance: 0.4,
        ),
        normalizedState: AdaptiveState(
          engagement: 0.1,
          motivation: 0.2,
          flow: 0.3,
          performance: 0.4,
        ),
        generatedStateKey: '0.10|0.20|0.30|0.40',
        source: 'exact_match',
      );

      const diagnostics = RuntimeDiagnostics(
        inputState: AdaptiveState(
          engagement: 0.1,
          motivation: 0.2,
          flow: 0.3,
          performance: 0.4,
        ),
        normalizedState: AdaptiveState(
          engagement: 0.1,
          motivation: 0.2,
          flow: 0.3,
          performance: 0.4,
        ),
        generatedStateKey: '0.10|0.20|0.30|0.40',
        usedExactMatch: true,
        usedFallback: false,
        indexedPolicySize: 2,
      );

      const a = DecisionExecutionResult(
        decision: exactDecisionA,
        context: context,
        diagnostics: diagnostics,
      );

      const b = DecisionExecutionResult(
        decision: exactDecisionA,
        context: context,
        diagnostics: diagnostics,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}