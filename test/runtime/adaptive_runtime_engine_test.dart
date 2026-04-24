import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/runtime/adaptive_runtime_engine.dart';
import 'package:adaptive_gamification/src/runtime/decision_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveRuntimeEngine', () {
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

    const exportedPolicy = ExportedPolicy(
      metadata: metadata,
      entries: <PolicyEntry>[
        PolicyEntry(
          stateKey: '0.10|0.20|0.30|0.40',
          decision: AdaptiveDecision(
            nextDifficulty: 1,
            source: 'exact_match',
            reason: 'stable',
            actionLabel: 'easy_task',
          ),
        ),
        PolicyEntry(
          stateKey: '0.40|0.50|0.60|0.70',
          decision: AdaptiveDecision(
            nextDifficulty: 3,
            source: 'exact_match',
            reason: 'increase challenge',
            actionLabel: 'hard_task',
          ),
        ),
      ],
      validationResult: PolicyValidationResult(
        isValid: true,
      ),
    );

    const indexedDecisions = <String, AdaptiveDecision>{
      '0.10|0.20|0.30|0.40': AdaptiveDecision(
        nextDifficulty: 1,
        source: 'exact_match',
        reason: 'stable',
        actionLabel: 'easy_task',
      ),
      '0.40|0.50|0.60|0.70': AdaptiveDecision(
        nextDifficulty: 3,
        source: 'exact_match',
        reason: 'increase challenge',
        actionLabel: 'hard_task',
      ),
    };

    const loadedPolicy = LoadedPolicy(
      exportedPolicy: exportedPolicy,
      indexedDecisions: indexedDecisions,
    );

    const decisionEngine = DecisionEngine(
      indexedDecisions: indexedDecisions,
      metadata: metadata,
      enableDiagnostics: true,
    );

    const runtimeEngine = AdaptiveRuntimeEngine(
      loadedPolicy: loadedPolicy,
      decisionEngine: decisionEngine,
    );

    test('isValid proxies loaded policy validity', () {
      expect(runtimeEngine.isValid, isTrue);
    });

    test('policySize proxies loaded policy size', () {
      expect(runtimeEngine.policySize, 2);
    });

    test('execute delegates to decision engine for exact match', () {
      const inputState = AdaptiveState(
        engagement: 0.1,
        motivation: 0.2,
        flow: 0.3,
        performance: 0.4,
      );

      final result = runtimeEngine.execute(
        inputState: inputState,
      );

      expect(result.decision.nextDifficulty, 1);
      expect(result.decision.source, DecisionSource.exactMatch);
      expect(result.decision.reason, 'stable');
      expect(result.decision.actionLabel, 'easy_task');

      expect(result.context.generatedStateKey, '0.10|0.20|0.30|0.40');
      expect(result.context.usedExactMatch, isTrue);
      expect(result.context.usedFallback, isFalse);

      expect(result.diagnostics, isNotNull);
      expect(result.diagnostics!.usedExactMatch, isTrue);
      expect(result.diagnostics!.usedFallback, isFalse);
    });

    test('execute delegates to decision engine for fallback path', () {
      const inputState = AdaptiveState(
        engagement: 0.9,
        motivation: 0.9,
        flow: 0.9,
        performance: 0.9,
      );

      final result = runtimeEngine.execute(
        inputState: inputState,
      );

      expect(result.decision.source, DecisionSource.fallback);
      expect(result.decision.reason, 'missing_state_key');
      expect(result.context.usedFallback, isTrue);
      expect(result.context.generatedStateKey, '0.90|0.90|0.90|0.90');

      expect(result.diagnostics, isNotNull);
      expect(result.diagnostics!.usedFallback, isTrue);
      expect(result.diagnostics!.fallbackReason, 'missing_state_key');
    });

    test('execute passes sessionId and interactionId through to decision engine',
            () {
          const inputState = AdaptiveState(
            engagement: 0.4,
            motivation: 0.5,
            flow: 0.6,
            performance: 0.7,
          );

          final result = runtimeEngine.execute(
            inputState: inputState,
            sessionId: 'session_1',
            interactionId: 'interaction_1',
          );

          expect(result.context.sessionId, 'session_1');
          expect(result.context.interactionId, 'interaction_1');
          expect(result.context.generatedStateKey, '0.40|0.50|0.60|0.70');

          expect(result.diagnostics, isNotNull);
          expect(result.diagnostics!.decisionContext, isNotNull);
          expect(result.diagnostics!.decisionContext!.sessionId, 'session_1');
          expect(
            result.diagnostics!.decisionContext!.interactionId,
            'interaction_1',
          );
        });

    test('toString contains important fields', () {
      final text = runtimeEngine.toString();

      expect(text, contains('AdaptiveRuntimeEngine'));
      expect(text, contains('isValid: true'));
      expect(text, contains('policySize: 2'));
      expect(text, contains('loadedPolicy:'));
    });

    test('equality works for identical values', () {
      const anotherRuntimeEngine = AdaptiveRuntimeEngine(
        loadedPolicy: loadedPolicy,
        decisionEngine: decisionEngine,
      );

      expect(runtimeEngine, equals(anotherRuntimeEngine));
      expect(runtimeEngine.hashCode, equals(anotherRuntimeEngine.hashCode));
    });

    test('inequality works when decision engine differs', () {
      const differentDecisionEngine = DecisionEngine(
        indexedDecisions: indexedDecisions,
        metadata: metadata,
        enableDiagnostics: false,
      );

      const differentRuntimeEngine = AdaptiveRuntimeEngine(
        loadedPolicy: loadedPolicy,
        decisionEngine: differentDecisionEngine,
      );

      expect(runtimeEngine, isNot(equals(differentRuntimeEngine)));
    });

    test('loaded policy data remains accessible through runtime engine', () {
      expect(runtimeEngine.loadedPolicy.metadata.formatVersion, '1.0');
      expect(runtimeEngine.loadedPolicy.policySize, 2);
      expect(
        runtimeEngine.loadedPolicy.decisionForKey('0.40|0.50|0.60|0.70')
            ?.actionLabel,
        'hard_task',
      );
    });
  });
}