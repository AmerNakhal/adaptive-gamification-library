import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/gamification/gamification_labels.dart';
import 'package:adaptive_gamification/src/gamification/recommendation_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecommendationBuilder', () {
    const builder = RecommendationBuilder();

    const baseInputState = AdaptiveState(
      engagement: 0.4,
      motivation: 0.5,
      flow: 0.6,
      performance: 0.7,
    );

    const baseContext = DecisionContext(
      inputState: baseInputState,
      normalizedState: baseInputState,
      generatedStateKey: '0.40|0.50|0.60|0.70',
      source: 'exact_match',
      warnings: <String>[],
    );

    test('build creates difficulty-adjustment recommendation from hard_task', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 3,
        source: 'exact_match',
        reason: 'increase challenge',
        actionLabel: 'hard_task',
      );

      final recommendation = builder.build(
        decision,
        context: baseContext,
        currentDifficultyRank: 2,
      );

      expect(recommendation.id, contains('rec_exact_match_3_'));
      expect(
        recommendation.type,
        RecommendationType.difficultyAdjustment,
      );
      expect(
        recommendation.priority,
        RecommendationPriority.medium,
      );
      expect(recommendation.title, 'Increase challenge');
      expect(
        recommendation.message,
        contains('increase challenge'),
      );
      expect(recommendation.decision, decision);
      expect(recommendation.context, baseContext);
      expect(recommendation.transition, isNotNull);
      expect(recommendation.transition!.beforeRank, 2);
      expect(recommendation.transition!.afterRank, 3);
      expect(recommendation.transition!.changeType, 'increase');
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
      expect(recommendation.tags, contains('difficulty_adjustment'));
      expect(recommendation.tags, contains('hard_task'));
      expect(recommendation.tags, contains('increase'));
    });

    test('build creates recovery recommendation from rest action', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 1,
        source: 'exact_match',
        actionLabel: 'rest',
      );

      final recommendation = builder.build(
        decision,
        context: baseContext,
        currentDifficultyRank: 2,
      );

      expect(recommendation.type, RecommendationType.recovery);
      expect(recommendation.priority, RecommendationPriority.high);
      expect(recommendation.title, 'Recovery recommendation');
      expect(
        recommendation.message,
        contains('recovery-oriented'),
      );
      expect(
        recommendation.supportStrategy,
        GamificationLabels.provideRecovery,
      );
      expect(
        recommendation.actionGroup,
        GamificationLabels.recoveryGroup,
      );
      expect(
        recommendation.pedagogicalEffect,
        GamificationLabels.recoverySupport,
      );
    });

    test('build creates flow-alignment recommendation from flow_task', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        actionLabel: 'flow_task',
      );

      final recommendation = builder.build(
        decision,
        context: baseContext,
        currentDifficultyRank: 2,
      );

      expect(recommendation.type, RecommendationType.flowAlignment);
      expect(recommendation.title, 'Flow alignment recommendation');
      expect(
        recommendation.supportStrategy,
        GamificationLabels.restoreFlow,
      );
      expect(
        recommendation.actionGroup,
        GamificationLabels.flowRegulationGroup,
      );
      expect(
        recommendation.pedagogicalEffect,
        GamificationLabels.flowAlignment,
      );
    });

    test('build creates motivational-support recommendation from motivation_boost',
            () {
          const decision = AdaptiveDecision(
            nextDifficulty: 2,
            source: 'exact_match',
            actionLabel: 'motivation_boost',
          );

          final recommendation = builder.build(
            decision,
            context: baseContext,
            currentDifficultyRank: 2,
          );

          expect(
            recommendation.type,
            RecommendationType.motivationalSupport,
          );
          expect(
            recommendation.title,
            'Motivational support recommendation',
          );
          expect(
            recommendation.supportStrategy,
            GamificationLabels.encouragePersistence,
          );
          expect(
            recommendation.actionGroup,
            GamificationLabels.motivationalSupportGroup,
          );
          expect(
            recommendation.pedagogicalEffect,
            GamificationLabels.motivationalReinforcement,
          );
        });

    test('build creates maintenance recommendation when transition is maintain',
            () {
          const decision = AdaptiveDecision(
            nextDifficulty: 2,
            source: 'exact_match',
            actionLabel: 'medium_task',
          );

          final recommendation = builder.build(
            decision,
            context: baseContext,
            currentDifficultyRank: 2,
          );

          expect(recommendation.type, RecommendationType.maintenance);
          expect(recommendation.title, 'Maintain current challenge');
          expect(
            recommendation.supportStrategy,
            GamificationLabels.maintainChallenge,
          );
          expect(
            recommendation.pedagogicalEffect,
            GamificationLabels.difficultyMaintenance,
          );
          expect(recommendation.transition, isNotNull);
          expect(recommendation.transition!.isMaintain, isTrue);
        });

    test('build uses provided transition instead of deriving one', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 4,
        source: 'exact_match',
        actionLabel: 'hard_task',
      );

      const providedTransition = DifficultyTransition(
        beforeRank: 1,
        afterRank: 4,
        beforeLevel: 'easy',
        afterLevel: 'veryHard',
        changeType: 'increase',
        delta: 3,
      );

      final recommendation = builder.build(
        decision,
        context: baseContext,
        transition: providedTransition,
        currentDifficultyRank: 2,
      );

      expect(recommendation.transition, providedTransition);
      expect(recommendation.priority, RecommendationPriority.high);
      expect(recommendation.title, 'Increase challenge');
      expect(recommendation.tags, contains('veryHard'));
    });

    test('build uses supportStrategy and pedagogicalEffect from decision details',
            () {
          const decision = AdaptiveDecision(
            nextDifficulty: 2,
            source: 'exact_match',
            actionLabel: 'medium_task',
            details: AdaptiveDecisionDetails(
              supportStrategy: 'restore_flow',
              pedagogicalEffect: 'flow_alignment',
              actionGroup: 'flow_regulation',
              difficultyRankBefore: 1,
              difficultyRankAfter: 2,
            ),
          );

          final recommendation = builder.build(
            decision,
            context: baseContext,
          );

          expect(
            recommendation.supportStrategy,
            GamificationLabels.restoreFlow,
          );
          expect(
            recommendation.pedagogicalEffect,
            GamificationLabels.flowAlignment,
          );
          expect(recommendation.transition, isNotNull);
          expect(recommendation.transition!.beforeRank, 1);
          expect(recommendation.transition!.afterRank, 2);
        });

    test('build marks fallback decision as high priority', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'fallback',
        reason: 'missing_state_key',
        actionLabel: 'medium_task',
      );

      final recommendation = builder.build(
        decision,
        context: const DecisionContext(
          inputState: baseInputState,
          normalizedState: baseInputState,
          generatedStateKey: '0.99|0.99|0.99|0.99',
          source: 'fallback',
          fallbackReason: 'missing_state_key',
        ),
        currentDifficultyRank: 2,
      );

      expect(recommendation.priority, RecommendationPriority.high);
      expect(recommendation.tags, contains('fallback'));
      expect(recommendation.tags, contains('has_reason'));
      expect(
        recommendation.message,
        contains('missing_state_key'),
      );
    });

    test('build uses custom recommendationId when provided', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 1,
        source: 'exact_match',
        actionLabel: 'easy_task',
      );

      final recommendation = builder.build(
        decision,
        context: baseContext,
        recommendationId: 'custom_rec_id',
        currentDifficultyRank: 2,
      );

      expect(recommendation.id, 'custom_rec_id');
    });

    test('build works without context and without resolvable transition', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        actionLabel: 'medium_task',
      );

      final recommendation = builder.build(decision);

      expect(recommendation.context, isNull);
      expect(recommendation.transition, isNull);
      expect(recommendation.id, contains('unknown_state'));
      expect(
        recommendation.type,
        RecommendationType.difficultyAdjustment,
      );
    });

    test('build adds expected tags', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 3,
        source: 'exact_match',
        reason: 'increase challenge',
        actionLabel: 'hard_task',
      );

      final recommendation = builder.build(
        decision,
        context: baseContext,
        currentDifficultyRank: 1,
      );

      expect(recommendation.tags, contains('difficulty_adjustment'));
      expect(recommendation.tags, contains('high'));
      expect(recommendation.tags, contains('hard_task'));
      expect(recommendation.tags, contains('challenge_adjustment'));
      expect(recommendation.tags, contains('increase_challenge'));
      expect(recommendation.tags, contains('difficulty_increase'));
      expect(recommendation.tags, contains('exact_match'));
      expect(recommendation.tags, contains('increase'));
      expect(recommendation.tags, contains('easy'));
      expect(recommendation.tags, contains('hard'));
      expect(recommendation.tags, contains('has_reason'));
    });

    test('equality works for identical builders', () {
      const a = RecommendationBuilder();
      const b = RecommendationBuilder();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains important fields', () {
      const builder = RecommendationBuilder();

      final text = builder.toString();

      expect(text, contains('RecommendationBuilder'));
      expect(text, contains('transitionResolver:'));
      expect(text, contains('actionGroupMapper:'));
      expect(text, contains('supportStrategyMapper:'));
      expect(text, contains('pedagogicalEffectMapper:'));
    });
  });
}