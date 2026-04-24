import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveRecommendation', () {
    const baseDecision = AdaptiveDecision(
      nextDifficulty: 2,
      source: 'exact_match',
      reason: 'stable progression',
      actionLabel: 'medium_task',
    );

    const baseTransition = DifficultyTransition(
      beforeRank: 1,
      afterRank: 2,
      beforeLevel: 'easy',
      afterLevel: 'medium',
      changeType: 'increase',
      delta: 1,
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

    test('constructs with required values only', () {
      const recommendation = AdaptiveRecommendation(
        id: 'rec_1',
        type: 'difficulty_adjustment',
        priority: 'medium',
        title: 'Increase challenge',
        message: 'A higher difficulty level is recommended.',
        decision: baseDecision,
      );

      expect(recommendation.id, 'rec_1');
      expect(recommendation.type, 'difficulty_adjustment');
      expect(recommendation.priority, 'medium');
      expect(recommendation.title, 'Increase challenge');
      expect(
        recommendation.message,
        'A higher difficulty level is recommended.',
      );
      expect(recommendation.decision, baseDecision);
      expect(recommendation.transition, isNull);
      expect(recommendation.context, isNull);
      expect(recommendation.supportStrategy, isNull);
      expect(recommendation.actionGroup, isNull);
      expect(recommendation.pedagogicalEffect, isNull);
      expect(recommendation.tags, isEmpty);

      expect(recommendation.hasTransition, isFalse);
      expect(recommendation.hasContext, isFalse);
      expect(recommendation.hasTags, isFalse);
    });

    test('constructs with all optional values', () {
      const recommendation = AdaptiveRecommendation(
        id: 'rec_2',
        type: 'flow_alignment',
        priority: 'high',
        title: 'Restore flow',
        message: 'A flow-supporting step is recommended.',
        decision: baseDecision,
        transition: baseTransition,
        context: baseContext,
        supportStrategy: 'restore_flow',
        actionGroup: 'flow_regulation',
        pedagogicalEffect: 'flow_alignment',
        tags: <String>[
          'flow_alignment',
          'high',
          'flow_task',
        ],
      );

      expect(recommendation.transition, baseTransition);
      expect(recommendation.context, baseContext);
      expect(recommendation.supportStrategy, 'restore_flow');
      expect(recommendation.actionGroup, 'flow_regulation');
      expect(recommendation.pedagogicalEffect, 'flow_alignment');
      expect(
        recommendation.tags,
        <String>['flow_alignment', 'high', 'flow_task'],
      );

      expect(recommendation.hasTransition, isTrue);
      expect(recommendation.hasContext, isTrue);
      expect(recommendation.hasTags, isTrue);
    });

    test('fromMap reads minimal valid map', () {
      final recommendation = AdaptiveRecommendation.fromMap(<String, dynamic>{
        'id': 'rec_min',
        'title': 'Adaptive recommendation',
        'message': 'Recommendation message.',
        'decision': <String, dynamic>{
          'nextDifficulty': 2,
          'source': 'exact_match',
        },
      });

      expect(recommendation.id, 'rec_min');
      expect(
        recommendation.type,
        RecommendationType.difficultyAdjustment,
      );
      expect(
        recommendation.priority,
        RecommendationPriority.medium,
      );
      expect(recommendation.title, 'Adaptive recommendation');
      expect(recommendation.message, 'Recommendation message.');
      expect(recommendation.decision.nextDifficulty, 2);
      expect(recommendation.transition, isNull);
      expect(recommendation.context, isNull);
      expect(recommendation.tags, isEmpty);
    });

    test('fromMap reads full valid map', () {
      final recommendation = AdaptiveRecommendation.fromMap(<String, dynamic>{
        'id': 'rec_full',
        'type': 'motivational_support',
        'priority': 'high',
        'title': 'Motivational support recommendation',
        'message': 'A motivational support step is recommended.',
        'decision': <String, dynamic>{
          'nextDifficulty': 3,
          'source': 'fallback',
          'reason': 'missing_state_key',
          'actionLabel': 'motivation_boost',
          'details': <String, dynamic>{
            'sourceActionId': 4,
            'sourceActionName': 'motivation_boost',
            'actionGroup': 'motivational_support',
          },
        },
        'transition': <String, dynamic>{
          'beforeRank': 2,
          'afterRank': 3,
          'beforeLevel': 'medium',
          'afterLevel': 'hard',
          'changeType': 'increase',
          'delta': 1,
        },
        'context': <String, dynamic>{
          'inputState': <String, dynamic>{
            'engagement': 0.2,
            'motivation': 0.3,
            'flow': 0.4,
            'performance': 0.5,
          },
          'normalizedState': <String, dynamic>{
            'engagement': 0.2,
            'motivation': 0.3,
            'flow': 0.4,
            'performance': 0.5,
          },
          'generatedStateKey': '0.20|0.30|0.40|0.50',
          'source': 'fallback',
          'fallbackReason': 'missing_state_key',
          'warnings': <dynamic>['warn_1'],
        },
        'supportStrategy': 'encourage_persistence',
        'actionGroup': 'motivational_support',
        'pedagogicalEffect': 'motivational_reinforcement',
        'tags': <dynamic>[
          'motivational_support',
          'high',
          'motivation_boost',
        ],
      });

      expect(recommendation.id, 'rec_full');
      expect(recommendation.type, 'motivational_support');
      expect(recommendation.priority, 'high');
      expect(recommendation.title, 'Motivational support recommendation');
      expect(
        recommendation.message,
        'A motivational support step is recommended.',
      );
      expect(recommendation.decision.source, 'fallback');
      expect(recommendation.transition, isNotNull);
      expect(recommendation.context, isNotNull);
      expect(recommendation.supportStrategy, 'encourage_persistence');
      expect(recommendation.actionGroup, 'motivational_support');
      expect(
        recommendation.pedagogicalEffect,
        'motivational_reinforcement',
      );
      expect(
        recommendation.tags,
        <String>[
          'motivational_support',
          'high',
          'motivation_boost',
        ],
      );
    });

    test('fromMap normalizes unsupported type and priority', () {
      final recommendation = AdaptiveRecommendation.fromMap(<String, dynamic>{
        'id': 'rec_norm',
        'type': 'bad_type',
        'priority': 'bad_priority',
        'title': 'Title',
        'message': 'Message',
        'decision': <String, dynamic>{
          'nextDifficulty': 1,
          'source': 'exact_match',
        },
      });

      expect(
        recommendation.type,
        RecommendationType.difficultyAdjustment,
      );
      expect(
        recommendation.priority,
        RecommendationPriority.medium,
      );
    });

    test('fromMap throws when id is missing', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when title is missing', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when message is missing', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when decision is missing', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'message': 'Message',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when id is not a string', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 123,
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when title is not a string', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 123,
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when message is not a string', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'message': 123,
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when decision is not a map', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'message': 'Message',
          'decision': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when type is not a string', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'type': 123,
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when priority is not a string', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'priority': 123,
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when supportStrategy is not a string', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
          'supportStrategy': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when actionGroup is not a string', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
          'actionGroup': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when pedagogicalEffect is not a string', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
          'pedagogicalEffect': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when transition is not a map', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
          'transition': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when context is not a map', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
          'context': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when tags is not a list', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
          'tags': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when tags contain non-string value', () {
      expect(
            () => AdaptiveRecommendation.fromMap(<String, dynamic>{
          'id': 'rec',
          'title': 'Title',
          'message': 'Message',
          'decision': <String, dynamic>{
            'nextDifficulty': 1,
            'source': 'exact_match',
          },
          'tags': <dynamic>['ok', 123],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toMap returns expected values', () {
      const recommendation = AdaptiveRecommendation(
        id: 'rec_map',
        type: 'difficulty_adjustment',
        priority: 'medium',
        title: 'Maintain challenge',
        message: 'Keep the current challenge level.',
        decision: baseDecision,
        transition: baseTransition,
        context: baseContext,
        supportStrategy: 'maintain_challenge',
        actionGroup: 'challenge_adjustment',
        pedagogicalEffect: 'difficulty_maintenance',
        tags: <String>['difficulty_adjustment', 'medium'],
      );

      final map = recommendation.toMap();

      expect(map['id'], 'rec_map');
      expect(map['type'], 'difficulty_adjustment');
      expect(map['priority'], 'medium');
      expect(map['title'], 'Maintain challenge');
      expect(map['message'], 'Keep the current challenge level.');
      expect(map['decision'], isA<Map<String, dynamic>>());
      expect(map['transition'], isA<Map<String, dynamic>>());
      expect(map['context'], isA<Map<String, dynamic>>());
      expect(map['supportStrategy'], 'maintain_challenge');
      expect(map['actionGroup'], 'challenge_adjustment');
      expect(map['pedagogicalEffect'], 'difficulty_maintenance');
      expect(map['tags'], <String>['difficulty_adjustment', 'medium']);
    });

    test('copyWith replaces only provided values', () {
      const original = AdaptiveRecommendation(
        id: 'rec_original',
        type: 'difficulty_adjustment',
        priority: 'medium',
        title: 'Original title',
        message: 'Original message',
        decision: baseDecision,
      );

      final updated = original.copyWith(
        priority: 'high',
        title: 'Updated title',
        message: 'Updated message',
        supportStrategy: 'increase_challenge',
      );

      expect(updated.id, 'rec_original');
      expect(updated.type, 'difficulty_adjustment');
      expect(updated.priority, 'high');
      expect(updated.title, 'Updated title');
      expect(updated.message, 'Updated message');
      expect(updated.decision, baseDecision);
      expect(updated.supportStrategy, 'increase_challenge');
    });

    test('equality works for identical values', () {
      const a = AdaptiveRecommendation(
        id: 'rec_equal',
        type: 'flow_alignment',
        priority: 'high',
        title: 'Restore flow',
        message: 'Flow support recommended.',
        decision: baseDecision,
        transition: baseTransition,
        context: baseContext,
        supportStrategy: 'restore_flow',
        actionGroup: 'flow_regulation',
        pedagogicalEffect: 'flow_alignment',
        tags: <String>['flow_alignment', 'high'],
      );

      const b = AdaptiveRecommendation(
        id: 'rec_equal',
        type: 'flow_alignment',
        priority: 'high',
        title: 'Restore flow',
        message: 'Flow support recommended.',
        decision: baseDecision,
        transition: baseTransition,
        context: baseContext,
        supportStrategy: 'restore_flow',
        actionGroup: 'flow_regulation',
        pedagogicalEffect: 'flow_alignment',
        tags: <String>['flow_alignment', 'high'],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains important fields', () {
      const recommendation = AdaptiveRecommendation(
        id: 'rec_text',
        type: 'recovery',
        priority: 'high',
        title: 'Recovery recommendation',
        message: 'A recovery-oriented step is recommended.',
        decision: baseDecision,
      );

      final text = recommendation.toString();

      expect(text, contains('AdaptiveRecommendation'));
      expect(text, contains('id: rec_text'));
      expect(text, contains('type: recovery'));
      expect(text, contains('priority: high'));
      expect(text, contains('title: Recovery recommendation'));
      expect(
        text,
        contains('message: A recovery-oriented step is recommended.'),
      );
    });
  });
}