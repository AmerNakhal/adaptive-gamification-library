import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/mappers/recommendation_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecommendationMapper', () {
    const mapper = RecommendationMapper();

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

    const context = DecisionContext(
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
      tags: <String>[
        'difficulty_adjustment',
        'medium',
        'hard_task',
        'challenge_adjustment',
      ],
    );

    test('toMap returns full serializable recommendation map', () {
      final map = mapper.toMap(recommendation);

      expect(map['id'], 'rec_1');
      expect(map['type'], 'difficulty_adjustment');
      expect(map['priority'], 'medium');
      expect(map['title'], 'Increase challenge');
      expect(map['message'], 'A higher difficulty level is recommended.');
      expect(map['decision'], isA<Map<String, dynamic>>());
      expect(map['transition'], isA<Map<String, dynamic>>());
      expect(map['context'], isA<Map<String, dynamic>>());
      expect(map['supportStrategy'], 'increase_challenge');
      expect(map['actionGroup'], 'challenge_adjustment');
      expect(map['pedagogicalEffect'], 'difficulty_increase');
      expect(
        map['tags'],
        <String>[
          'difficulty_adjustment',
          'medium',
          'hard_task',
          'challenge_adjustment',
        ],
      );
    });

    test('toDisplayMap returns lightweight display-friendly map', () {
      final map = mapper.toDisplayMap(recommendation);

      expect(map['id'], 'rec_1');
      expect(map['type'], 'difficulty_adjustment');
      expect(map['priority'], 'medium');
      expect(map['title'], 'Increase challenge');
      expect(map['message'], 'A higher difficulty level is recommended.');
      expect(map['actionGroup'], 'challenge_adjustment');
      expect(map['supportStrategy'], 'increase_challenge');
      expect(map['pedagogicalEffect'], 'difficulty_increase');
      expect(map['nextDifficulty'], 3);
      expect(map['actionLabel'], 'hard_task');
      expect(map['source'], 'exact_match');
      expect(map['hasTransition'], isTrue);
      expect(
        map['tags'],
        <String>[
          'difficulty_adjustment',
          'medium',
          'hard_task',
          'challenge_adjustment',
        ],
      );
    });

    test('toDisplayMap handles recommendation without transition', () {
      const recommendationWithoutTransition = AdaptiveRecommendation(
        id: 'rec_no_transition',
        type: 'maintenance',
        priority: 'medium',
        title: 'Maintain current challenge',
        message: 'The current difficulty level is recommended to be maintained.',
        decision: AdaptiveDecision(
          nextDifficulty: 2,
          source: 'exact_match',
          actionLabel: 'medium_task',
        ),
      );

      final map = mapper.toDisplayMap(recommendationWithoutTransition);

      expect(map['id'], 'rec_no_transition');
      expect(map['hasTransition'], isFalse);
      expect(map['nextDifficulty'], 2);
      expect(map['actionLabel'], 'medium_task');
    });

    test('toSummary returns concise human-readable summary', () {
      final summary = mapper.toSummary(recommendation);

      expect(summary, contains('Increase challenge'));
      expect(summary, contains('A higher difficulty level is recommended.'));
      expect(summary, contains('nextDifficulty: 3'));
      expect(summary, contains('action: hard_task'));
    });

    test('toSummary omits action text when actionLabel is null or empty', () {
      const recommendationWithoutAction = AdaptiveRecommendation(
        id: 'rec_2',
        type: 'maintenance',
        priority: 'medium',
        title: 'Maintain challenge',
        message: 'Keep the current challenge level.',
        decision: AdaptiveDecision(
          nextDifficulty: 2,
          source: 'exact_match',
        ),
      );

      final summary = mapper.toSummary(recommendationWithoutAction);

      expect(summary, contains('Maintain challenge'));
      expect(summary, contains('Keep the current challenge level.'));
      expect(summary, contains('nextDifficulty: 2'));
      expect(summary, isNot(contains('action:')));
    });

    test('toDistinctTags removes duplicates and trims whitespace', () {
      const recommendationWithDuplicateTags = AdaptiveRecommendation(
        id: 'rec_tags',
        type: 'difficulty_adjustment',
        priority: 'medium',
        title: 'Increase challenge',
        message: 'A higher difficulty level is recommended.',
        decision: decision,
        tags: <String>[
          'difficulty_adjustment',
          ' medium ',
          'hard_task',
          'difficulty_adjustment',
          '',
          '   ',
          'hard_task',
        ],
      );

      final tags = mapper.toDistinctTags(recommendationWithDuplicateTags);

      expect(
        tags,
        <String>[
          'difficulty_adjustment',
          'medium',
          'hard_task',
        ],
      );
    });

    test('toDistinctTags returns empty list when recommendation has no tags', () {
      const recommendationWithoutTags = AdaptiveRecommendation(
        id: 'rec_no_tags',
        type: 'maintenance',
        priority: 'medium',
        title: 'Maintain challenge',
        message: 'Keep the current challenge level.',
        decision: decision,
      );

      final tags = mapper.toDistinctTags(recommendationWithoutTags);

      expect(tags, isEmpty);
    });

    test('toString returns readable type name', () {
      expect(
        mapper.toString(),
        contains('RecommendationMapper'),
      );
    });

    test('equality works for identical mappers', () {
      const a = RecommendationMapper();
      const b = RecommendationMapper();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}