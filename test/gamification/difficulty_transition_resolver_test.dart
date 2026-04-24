import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/gamification/difficulty_transition_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DifficultyTransitionResolver', () {
    const resolver = DifficultyTransitionResolver();

    test('resolve prefers detail ranks when available', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 4,
        source: 'exact_match',
        actionLabel: 'hard_task',
        details: AdaptiveDecisionDetails(
          difficultyRankBefore: 1,
          difficultyRankAfter: 3,
        ),
      );

      final transition = resolver.resolve(
        decision,
        currentDifficultyRank: 2,
      );

      expect(transition, isNotNull);
      expect(transition!.beforeRank, 1);
      expect(transition.afterRank, 3);
      expect(transition.changeType, DifficultyChangeType.increase);
      expect(transition.delta, 2);
      expect(transition.beforeLevel, DifficultyLevel.fromRank(1));
      expect(transition.afterLevel, DifficultyLevel.fromRank(3));
    });

    test('resolve uses currentDifficultyRank when details are absent', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 3,
        source: 'exact_match',
        actionLabel: 'hard_task',
      );

      final transition = resolver.resolve(
        decision,
        currentDifficultyRank: 1,
      );

      expect(transition, isNotNull);
      expect(transition!.beforeRank, 1);
      expect(transition.afterRank, 3);
      expect(transition.changeType, DifficultyChangeType.increase);
      expect(transition.delta, 2);
    });

    test('resolve returns maintain transition when before and after are equal', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        actionLabel: 'medium_task',
      );

      final transition = resolver.resolve(
        decision,
        currentDifficultyRank: 2,
      );

      expect(transition, isNotNull);
      expect(transition!.beforeRank, 2);
      expect(transition.afterRank, 2);
      expect(transition.changeType, DifficultyChangeType.maintain);
      expect(transition.delta, 0);
      expect(transition.isMaintain, isTrue);
    });

    test('resolve returns decrease transition when nextDifficulty is lower', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 1,
        source: 'exact_match',
        actionLabel: 'easy_task',
      );

      final transition = resolver.resolve(
        decision,
        currentDifficultyRank: 3,
      );

      expect(transition, isNotNull);
      expect(transition!.beforeRank, 3);
      expect(transition.afterRank, 1);
      expect(transition.changeType, DifficultyChangeType.decrease);
      expect(transition.delta, -2);
      expect(transition.isDecrease, isTrue);
    });

    test('resolve returns null when neither details nor currentDifficultyRank are available', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        actionLabel: 'medium_task',
      );

      final transition = resolver.resolve(decision);

      expect(transition, isNull);
    });

    test('resolve ignores partial detail ranks and falls back to currentDifficultyRank', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 4,
        source: 'exact_match',
        actionLabel: 'hard_task',
        details: AdaptiveDecisionDetails(
          difficultyRankBefore: 2,
        ),
      );

      final transition = resolver.resolve(
        decision,
        currentDifficultyRank: 1,
      );

      expect(transition, isNotNull);
      expect(transition!.beforeRank, 1);
      expect(transition.afterRank, 4);
      expect(transition.changeType, DifficultyChangeType.increase);
    });

    test('resolveFromRanks builds expected transition', () {
      final transition = resolver.resolveFromRanks(
        beforeRank: 4,
        afterRank: 2,
      );

      expect(transition.beforeRank, 4);
      expect(transition.afterRank, 2);
      expect(transition.changeType, DifficultyChangeType.decrease);
      expect(transition.delta, -2);
      expect(transition.beforeLevel, DifficultyLevel.fromRank(4));
      expect(transition.afterLevel, DifficultyLevel.fromRank(2));
    });

    test('canResolve returns true when detail ranks are available', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        details: AdaptiveDecisionDetails(
          difficultyRankBefore: 1,
          difficultyRankAfter: 2,
        ),
      );

      expect(
        resolver.canResolve(decision),
        isTrue,
      );
    });

    test('canResolve returns true when currentDifficultyRank is provided', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
      );

      expect(
        resolver.canResolve(
          decision,
          currentDifficultyRank: 1,
        ),
        isTrue,
      );
    });

    test('canResolve returns false when no transition source exists', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
      );

      expect(
        resolver.canResolve(decision),
        isFalse,
      );
    });

    test('equality works for identical resolvers', () {
      const a = DifficultyTransitionResolver();
      const b = DifficultyTransitionResolver();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString returns readable type name', () {
      const resolver = DifficultyTransitionResolver();

      expect(
        resolver.toString(),
        contains('DifficultyTransitionResolver'),
      );
    });
  });
}