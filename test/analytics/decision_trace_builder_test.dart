import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/analytics/decision_trace_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecisionTraceBuilder', () {
    const builder = DecisionTraceBuilder();

    const baseDecision = AdaptiveDecision(
      nextDifficulty: 3,
      source: 'exact_match',
      reason: 'increase challenge',
      actionLabel: 'hard_task',
    );

    const baseContext = DecisionContext(
      inputState: AdaptiveState(
        engagement: 0.4,
        motivation: 0.5,
        flow: 0.6,
        performance: 0.7,
      ),
      normalizedState: AdaptiveState(
        engagement: 0.4,
        motivation: 0.5,
        flow: 0.6,
        performance: 0.7,
      ),
      generatedStateKey: '0.40|0.50|0.60|0.70',
      source: 'exact_match',
      warnings: <String>[],
    );

    const providedTransition = DifficultyTransition(
      beforeRank: 2,
      afterRank: 3,
      beforeLevel: 'medium',
      afterLevel: 'hard',
      changeType: 'increase',
      delta: 1,
    );

    const providedRecommendation = AdaptiveRecommendation(
      id: 'rec_custom',
      type: 'difficulty_adjustment',
      priority: 'medium',
      title: 'Increase challenge',
      message: 'A higher difficulty level is recommended.',
      decision: baseDecision,
      transition: providedTransition,
      context: baseContext,
      supportStrategy: 'increase_challenge',
      actionGroup: 'challenge_adjustment',
      pedagogicalEffect: 'difficulty_increase',
      tags: <String>['difficulty_adjustment', 'medium'],
    );

    test('build creates trace with derived transition and recommendation', () {
      final trace = builder.build(
        decision: baseDecision,
        context: baseContext,
        currentDifficultyRank: 2,
      );

      expect(trace.traceId, contains('trace_exact_match_3_'));
      expect(trace.decision, baseDecision);
      expect(trace.context, baseContext);

      expect(trace.transition, isNotNull);
      expect(trace.transition!.beforeRank, 2);
      expect(trace.transition!.afterRank, 3);
      expect(trace.transition!.changeType, DifficultyChangeType.increase);

      expect(trace.recommendation, isNotNull);
      expect(
        trace.recommendation!.type,
        RecommendationType.difficultyAdjustment,
      );
      expect(trace.recommendation!.decision, baseDecision);
      expect(trace.recommendation!.context, baseContext);

      expect(trace.warnings, isEmpty);
      expect(trace.note, isNull);
      expect(trace.timestamp, isNull);

      expect(trace.hasTransition, isTrue);
      expect(trace.hasRecommendation, isTrue);
      expect(trace.hasWarnings, isFalse);
      expect(trace.usedExactMatch, isTrue);
      expect(trace.usedFallback, isFalse);
    });

    test('build uses provided transition when supplied', () {
      final trace = builder.build(
        decision: baseDecision,
        context: baseContext,
        transition: providedTransition,
        currentDifficultyRank: 1,
      );

      expect(trace.transition, providedTransition);
      expect(trace.transition!.beforeRank, 2);
      expect(trace.transition!.afterRank, 3);
    });

    test('build uses provided recommendation when supplied', () {
      final trace = builder.build(
        decision: baseDecision,
        context: baseContext,
        transition: providedTransition,
        recommendation: providedRecommendation,
      );

      expect(trace.recommendation, providedRecommendation);
      expect(trace.recommendation!.id, 'rec_custom');
    });

    test('build uses provided traceId, warnings, note, and timestamp', () {
      final timestamp = DateTime.parse('2026-01-01T12:00:00Z');

      final trace = builder.build(
        decision: baseDecision,
        context: baseContext,
        traceId: 'custom_trace_id',
        warnings: const <String>['warning_1', 'warning_2'],
        note: 'trace note',
        timestamp: timestamp,
      );

      expect(trace.traceId, 'custom_trace_id');
      expect(trace.warnings, <String>['warning_1', 'warning_2']);
      expect(trace.note, 'trace note');
      expect(trace.timestamp, timestamp);
      expect(trace.hasWarnings, isTrue);
    });

    test('build works without resolvable transition', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        actionLabel: 'medium_task',
      );

      final trace = builder.build(
        decision: decision,
        context: baseContext,
      );

      expect(trace.transition, isNull);
      expect(trace.recommendation, isNotNull);
      expect(
        trace.recommendation!.type,
        RecommendationType.difficultyAdjustment,
      );
    });

    test('build reflects fallback usage from context', () {
      const fallbackDecision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'fallback',
        reason: 'missing_state_key',
        actionLabel: 'medium_task',
      );

      const fallbackContext = DecisionContext(
        inputState: AdaptiveState(
          engagement: 0.9,
          motivation: 0.9,
          flow: 0.9,
          performance: 0.9,
        ),
        normalizedState: AdaptiveState(
          engagement: 0.9,
          motivation: 0.9,
          flow: 0.9,
          performance: 0.9,
        ),
        generatedStateKey: '0.90|0.90|0.90|0.90',
        source: 'fallback',
        fallbackReason: 'missing_state_key',
      );

      final trace = builder.build(
        decision: fallbackDecision,
        context: fallbackContext,
        currentDifficultyRank: 2,
      );

      expect(trace.usedFallback, isTrue);
      expect(trace.usedExactMatch, isFalse);
      expect(trace.context.fallbackReason, 'missing_state_key');
      expect(trace.recommendation, isNotNull);
      expect(trace.recommendation!.priority, RecommendationPriority.high);
    });

    test('toString contains important fields', () {
      final text = builder.toString();

      expect(text, contains('DecisionTraceBuilder'));
      expect(text, contains('transitionResolver:'));
      expect(text, contains('recommendationBuilder:'));
    });

    test('equality works for identical builders', () {
      const a = DecisionTraceBuilder();
      const b = DecisionTraceBuilder();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}