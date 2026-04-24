import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/analytics/execution_trace_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExecutionTraceFormatter', () {
    const formatter = ExecutionTraceFormatter();

    const inputState = AdaptiveState(
      engagement: 0.4,
      motivation: 0.5,
      flow: 0.6,
      performance: 0.7,
    );

    const normalizedState = AdaptiveState(
      engagement: 0.4,
      motivation: 0.5,
      flow: 0.6,
      performance: 0.7,
    );

    const context = DecisionContext(
      inputState: inputState,
      normalizedState: normalizedState,
      generatedStateKey: '0.40|0.50|0.60|0.70',
      source: 'exact_match',
      warnings: <String>[],
    );

    const decision = AdaptiveDecision(
      nextDifficulty: 3,
      source: 'exact_match',
      reason: 'increase challenge',
      actionLabel: 'hard_task',
    );

    const transition = DifficultyTransition(
      beforeRank: 2,
      afterRank: 3,
      beforeLevel: 'medium',
      afterLevel: 'hard',
      changeType: 'increase',
      delta: 1,
    );

    const recommendation = AdaptiveRecommendation(
      id: 'rec_1',
      type: 'difficulty_adjustment',
      priority: 'medium',
      title: 'Increase challenge',
      message: 'A higher difficulty level is recommended.',
      decision: decision,
      transition: transition,
      context: context,
      supportStrategy: 'increase_challenge',
      actionGroup: 'challenge_adjustment',
      pedagogicalEffect: 'difficulty_increase',
      tags: <String>['difficulty_adjustment', 'medium'],
    );

    const diagnostics = RuntimeDiagnostics(
      inputState: inputState,
      normalizedState: normalizedState,
      generatedStateKey: '0.40|0.50|0.60|0.70',
      usedExactMatch: true,
      usedFallback: false,
      indexedPolicySize: 2,
      warnings: <String>[],
      decisionContext: context,
    );

    const metadata = PolicyMetadata(
      formatVersion: '1.0',
      policyType: 'deterministic_lookup_table',
      exportMode: 'deterministic_policy_lookup_export',
      stateOrder: <String>[
        'engagement',
        'motivation',
        'flow',
        'performance',
      ],
      stateDecimals: 2,
    );

    test('formatDecisionTrace formats all important fields', () {
      final trace = DecisionTrace(
        traceId: 'trace_1',
        decision: decision,
        context: context,
        transition: transition,
        recommendation: recommendation,
        warnings: const <String>['warning_1', 'warning_2'],
        note: 'decision note',
        timestamp: DateTime.parse('2026-01-01T12:00:00Z'),
      );

      final text = formatter.formatDecisionTrace(trace);

      expect(text, contains('DecisionTrace'));
      expect(text, contains('traceId: trace_1'));
      expect(text, contains('source: exact_match'));
      expect(text, contains('nextDifficulty: 3'));
      expect(text, contains('actionLabel: hard_task'));
      expect(text, contains('reason: increase challenge'));
      expect(text, contains('generatedStateKey: 0.40|0.50|0.60|0.70'));
      expect(text, contains('usedFallback: false'));
      expect(text, contains('timestamp: 2026-01-01T12:00:00.000Z'));

      expect(text, contains('transition:'));
      expect(text, contains('beforeRank: 2'));
      expect(text, contains('afterRank: 3'));
      expect(text, contains('beforeLevel: medium'));
      expect(text, contains('afterLevel: hard'));
      expect(text, contains('changeType: increase'));
      expect(text, contains('delta: 1'));

      expect(text, contains('recommendation:'));
      expect(text, contains('id: rec_1'));
      expect(text, contains('type: difficulty_adjustment'));
      expect(text, contains('priority: medium'));
      expect(text, contains('title: Increase challenge'));
      expect(text, contains('message: A higher difficulty level is recommended.'));

      expect(text, contains('warnings:'));
      expect(text, contains('- warning_1'));
      expect(text, contains('- warning_2'));
      expect(text, contains('note: decision note'));
    });

    test('formatDecisionTrace handles minimal trace safely', () {
      final trace = const DecisionTrace(
        traceId: 'trace_min',
        decision: decision,
        context: context,
      );

      final text = formatter.formatDecisionTrace(trace);

      expect(text, contains('DecisionTrace'));
      expect(text, contains('traceId: trace_min'));
      expect(text, contains('source: exact_match'));
      expect(text, contains('nextDifficulty: 3'));
      expect(text, contains('actionLabel: hard_task'));
      expect(text, contains('reason: increase challenge'));
      expect(text, contains('generatedStateKey: 0.40|0.50|0.60|0.70'));
      expect(text, contains('usedFallback: false'));
      expect(text, contains('timestamp: n/a'));

      expect(text, isNot(contains('transition:')));
      expect(text, isNot(contains('recommendation:')));
      expect(text, isNot(contains('warnings:')));
      expect(text, isNot(contains('note:')));
    });

    test('formatExecutionTrace formats all important fields', () {
      final decisionTrace = DecisionTrace(
        traceId: 'trace_1',
        decision: decision,
        context: context,
        transition: transition,
        recommendation: recommendation,
        warnings: const <String>['decision_warning'],
        note: 'decision note',
        timestamp: DateTime.parse('2026-01-01T12:00:00Z'),
      );

      final executionTrace = ExecutionTrace(
        traceId: 'exec_1',
        phase: 'runtime_execution',
        diagnostics: diagnostics,
        decisionTrace: decisionTrace,
        policyMetadata: metadata,
        indexedPolicySize: 2,
        durationMs: 15,
        warnings: const <String>['exec_warning'],
        note: 'execution note',
        timestamp: DateTime.parse('2026-01-01T12:01:00Z'),
      );

      final text = formatter.formatExecutionTrace(executionTrace);

      expect(text, contains('ExecutionTrace'));
      expect(text, contains('traceId: exec_1'));
      expect(text, contains('phase: runtime_execution'));
      expect(text, contains('indexedPolicySize: 2'));
      expect(text, contains('durationMs: 15'));
      expect(text, contains('timestamp: 2026-01-01T12:01:00.000Z'));

      expect(text, contains('policyMetadata:'));
      expect(text, contains('formatVersion: 1.0'));
      expect(text, contains('policyType: deterministic_lookup_table'));
      expect(text, contains('exportMode: deterministic_policy_lookup_export'));

      expect(text, contains('diagnostics:'));
      expect(text, contains('generatedStateKey: 0.40|0.50|0.60|0.70'));
      expect(text, contains('usedExactMatch: true'));
      expect(text, contains('usedFallback: false'));
      expect(text, contains('fallbackReason: n/a'));

      expect(text, contains('decisionTrace:'));
      expect(text, contains('DecisionTrace'));
      expect(text, contains('traceId: trace_1'));

      expect(text, contains('warnings:'));
      expect(text, contains('- exec_warning'));
      expect(text, contains('note: execution note'));
    });

    test('formatExecutionTrace handles minimal execution trace safely', () {
      final executionTrace = const ExecutionTrace(
        traceId: 'exec_min',
      );

      final text = formatter.formatExecutionTrace(executionTrace);

      expect(text, contains('ExecutionTrace'));
      expect(text, contains('traceId: exec_min'));
      expect(text, contains('phase: n/a'));
      expect(text, contains('indexedPolicySize: n/a'));
      expect(text, contains('durationMs: n/a'));
      expect(text, contains('timestamp: n/a'));

      expect(text, isNot(contains('policyMetadata:')));
      expect(text, isNot(contains('diagnostics:')));
      expect(text, isNot(contains('decisionTrace:')));
      expect(text, isNot(contains('warnings:')));
      expect(text, isNot(contains('note:')));
    });

    test('formatExecutionTrace indents embedded decision trace', () {
      final decisionTrace = const DecisionTrace(
        traceId: 'trace_indent',
        decision: decision,
        context: context,
      );

      final executionTrace = ExecutionTrace(
        traceId: 'exec_indent',
        decisionTrace: decisionTrace,
      );

      final text = formatter.formatExecutionTrace(executionTrace);

      expect(text, contains('  decisionTrace:'));
      expect(text, contains('    DecisionTrace'));
      expect(text, contains('      traceId: trace_indent'));
    });

    test('toString returns readable type name', () {
      expect(
        formatter.toString(),
        contains('ExecutionTraceFormatter'),
      );
    });

    test('equality works for identical formatters', () {
      const a = ExecutionTraceFormatter();
      const b = ExecutionTraceFormatter();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}