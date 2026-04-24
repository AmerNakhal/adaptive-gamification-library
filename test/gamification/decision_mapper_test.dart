import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/gamification/gamification_labels.dart';
import 'package:adaptive_gamification/src/mappers/decision_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecisionMapper', () {
    const mapper = DecisionMapper();

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

    test('toTransition resolves transition from currentDifficultyRank', () {
      final transition = mapper.toTransition(
        baseDecision,
        currentDifficultyRank: 2,
      );

      expect(transition, isNotNull);
      expect(transition!.beforeRank, 2);
      expect(transition.afterRank, 3);
      expect(transition.changeType, DifficultyChangeType.increase);
      expect(transition.delta, 1);
      expect(transition.beforeLevel, DifficultyLevel.medium);
      expect(transition.afterLevel, DifficultyLevel.hard);
    });

    test('toTransition resolves from decision details when available', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 4,
        source: 'exact_match',
        actionLabel: 'hard_task',
        details: AdaptiveDecisionDetails(
          difficultyRankBefore: 1,
          difficultyRankAfter: 4,
        ),
      );

      final transition = mapper.toTransition(
        decision,
        currentDifficultyRank: 2,
      );

      expect(transition, isNotNull);
      expect(transition!.beforeRank, 1);
      expect(transition.afterRank, 4);
      expect(transition.changeType, DifficultyChangeType.increase);
      expect(transition.delta, 3);
    });

    test('toTransition returns null when no transition information exists', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        actionLabel: 'medium_task',
      );

      final transition = mapper.toTransition(decision);

      expect(transition, isNull);
    });

    test('toRecommendation builds recommendation from decision and context', () {
      final recommendation = mapper.toRecommendation(
        baseDecision,
        context: baseContext,
        currentDifficultyRank: 2,
      );

      expect(recommendation.id, contains('rec_exact_match_3_'));
      expect(
        recommendation.type,
        RecommendationType.difficultyAdjustment,
      );
      expect(recommendation.priority, RecommendationPriority.medium);
      expect(recommendation.decision, baseDecision);
      expect(recommendation.context, baseContext);
      expect(recommendation.transition, isNotNull);
      expect(recommendation.transition!.beforeRank, 2);
      expect(recommendation.transition!.afterRank, 3);
      expect(
        recommendation.supportStrategy,
        GamificationLabels.increaseChallenge,
      );
      expect(
        recommendation.actionGroup,
        GamificationLabels.challengeAdjustmentGroup,
      );
      expect(
        recommendation.pedagogicalEffect,
        GamificationLabels.difficultyIncrease,
      );
    });

    test('toRecommendation uses provided transition when supplied', () {
      final recommendation = mapper.toRecommendation(
        baseDecision,
        context: baseContext,
        transition: providedTransition,
        currentDifficultyRank: 1,
      );

      expect(recommendation.transition, providedTransition);
      expect(recommendation.transition!.beforeRank, 2);
      expect(recommendation.transition!.afterRank, 3);
    });

    test('toRecommendation uses custom recommendationId when provided', () {
      final recommendation = mapper.toRecommendation(
        baseDecision,
        context: baseContext,
        currentDifficultyRank: 2,
        recommendationId: 'custom_recommendation_id',
      );

      expect(recommendation.id, 'custom_recommendation_id');
    });

    test('toDecisionTrace builds trace with derived recommendation and transition',
            () {
          final trace = mapper.toDecisionTrace(
            decision: baseDecision,
            context: baseContext,
            currentDifficultyRank: 2,
            warnings: const <String>['warning_1'],
            note: 'trace note',
            timestamp: DateTime.parse('2026-01-01T12:00:00Z'),
          );

          expect(trace.traceId, contains('trace_exact_match_3_'));
          expect(trace.decision, baseDecision);
          expect(trace.context, baseContext);
          expect(trace.transition, isNotNull);
          expect(trace.transition!.beforeRank, 2);
          expect(trace.transition!.afterRank, 3);
          expect(trace.recommendation, isNotNull);
          expect(trace.recommendation!.decision, baseDecision);
          expect(trace.warnings, <String>['warning_1']);
          expect(trace.note, 'trace note');
          expect(trace.timestamp, DateTime.parse('2026-01-01T12:00:00Z'));
          expect(trace.usedExactMatch, isTrue);
          expect(trace.usedFallback, isFalse);
        });

    test('toDecisionTrace uses provided transition and recommendation', () {
      final trace = mapper.toDecisionTrace(
        decision: baseDecision,
        context: baseContext,
        transition: providedTransition,
        recommendation: providedRecommendation,
        currentDifficultyRank: 1,
        traceId: 'custom_trace_id',
      );

      expect(trace.traceId, 'custom_trace_id');
      expect(trace.transition, providedTransition);
      expect(trace.recommendation, providedRecommendation);
    });

    test('toDecisionTrace reflects fallback context correctly', () {
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

      final trace = mapper.toDecisionTrace(
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
      final text = mapper.toString();

      expect(text, contains('DecisionMapper'));
      expect(text, contains('transitionResolver:'));
      expect(text, contains('recommendationBuilder:'));
      expect(text, contains('decisionTraceBuilder:'));
    });

    test('equality works for identical mappers', () {
      const a = DecisionMapper();
      const b = DecisionMapper();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}