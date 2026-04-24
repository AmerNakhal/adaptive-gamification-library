import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveDecisionDetails', () {
    test('constructs with default empty collections', () {
      const details = AdaptiveDecisionDetails();

      expect(details.sourceActionId, isNull);
      expect(details.sourceActionName, isNull);
      expect(details.actionGroup, isNull);
      expect(details.decisionType, isNull);
      expect(details.difficultyChange, isNull);
      expect(details.difficultyRankBefore, isNull);
      expect(details.difficultyRankAfter, isNull);
      expect(details.difficultyDelta, isNull);
      expect(details.currentDifficulty, isNull);
      expect(details.nextDifficultyLabel, isNull);
      expect(details.supportStrategy, isNull);
      expect(details.pedagogicalEffect, isNull);
      expect(details.stateInterpretation, isEmpty);
      expect(details.stateFlags, isEmpty);
      expect(details.actionProbabilities, isEmpty);
      expect(details.valueEstimate, isNull);

      expect(details.hasStateInterpretation, isFalse);
      expect(details.hasStateFlags, isFalse);
      expect(details.hasActionProbabilities, isFalse);
      expect(details.hasValueEstimate, isFalse);
    });

    test('constructs with full values', () {
      const details = AdaptiveDecisionDetails(
        sourceActionId: 2,
        sourceActionName: 'flow_task',
        actionGroup: 'flow_regulation',
        decisionType: 'flow_alignment',
        difficultyChange: 'increase',
        difficultyRankBefore: 1,
        difficultyRankAfter: 3,
        difficultyDelta: 2,
        currentDifficulty: 'easy',
        nextDifficultyLabel: 'hard',
        supportStrategy: 'restore_flow',
        pedagogicalEffect: 'flow_alignment',
        stateInterpretation: <String, double>{
          'eng': 0.4,
          'mot': 0.7,
        },
        stateFlags: <String, bool>{
          'low_engagement': true,
          'high_motivation': false,
        },
        actionProbabilities: <double>[0.1, 0.2, 0.7],
        valueEstimate: 0.91,
      );

      expect(details.sourceActionId, 2);
      expect(details.sourceActionName, 'flow_task');
      expect(details.actionGroup, 'flow_regulation');
      expect(details.decisionType, 'flow_alignment');
      expect(details.difficultyChange, 'increase');
      expect(details.difficultyRankBefore, 1);
      expect(details.difficultyRankAfter, 3);
      expect(details.difficultyDelta, 2);
      expect(details.currentDifficulty, 'easy');
      expect(details.nextDifficultyLabel, 'hard');
      expect(details.supportStrategy, 'restore_flow');
      expect(details.pedagogicalEffect, 'flow_alignment');
      expect(details.stateInterpretation['eng'], 0.4);
      expect(details.stateFlags['low_engagement'], isTrue);
      expect(details.actionProbabilities, <double>[0.1, 0.2, 0.7]);
      expect(details.valueEstimate, 0.91);

      expect(details.hasStateInterpretation, isTrue);
      expect(details.hasStateFlags, isTrue);
      expect(details.hasActionProbabilities, isTrue);
      expect(details.hasValueEstimate, isTrue);
    });

    test('fromMap reads valid minimal map', () {
      final details = AdaptiveDecisionDetails.fromMap(<String, dynamic>{});

      expect(details, const AdaptiveDecisionDetails());
    });

    test('fromMap reads full valid map', () {
      final details = AdaptiveDecisionDetails.fromMap(<String, dynamic>{
        'sourceActionId': 4,
        'sourceActionName': 'hard_task',
        'actionGroup': 'challenge_adjustment',
        'decisionType': 'difficulty_adjustment',
        'difficultyChange': 'increase',
        'difficultyRankBefore': 2,
        'difficultyRankAfter': 4,
        'difficultyDelta': 2,
        'currentDifficulty': 'medium',
        'nextDifficultyLabel': 'veryHard',
        'supportStrategy': 'increase_challenge',
        'pedagogicalEffect': 'difficulty_increase',
        'stateInterpretation': <String, dynamic>{
          'eng': 0.2,
          'mot': 0.8,
        },
        'stateFlags': <String, dynamic>{
          'low_engagement': true,
          'high_motivation': true,
        },
        'actionProbabilities': <dynamic>[0.05, 0.15, 0.80],
        'valueEstimate': 0.77,
      });

      expect(details.sourceActionId, 4);
      expect(details.sourceActionName, 'hard_task');
      expect(details.actionGroup, 'challenge_adjustment');
      expect(details.decisionType, 'difficulty_adjustment');
      expect(details.difficultyChange, 'increase');
      expect(details.difficultyRankBefore, 2);
      expect(details.difficultyRankAfter, 4);
      expect(details.difficultyDelta, 2);
      expect(details.currentDifficulty, 'medium');
      expect(details.nextDifficultyLabel, 'veryHard');
      expect(details.supportStrategy, 'increase_challenge');
      expect(details.pedagogicalEffect, 'difficulty_increase');
      expect(details.stateInterpretation, <String, double>{
        'eng': 0.2,
        'mot': 0.8,
      });
      expect(details.stateFlags, <String, bool>{
        'low_engagement': true,
        'high_motivation': true,
      });
      expect(details.actionProbabilities, <double>[0.05, 0.15, 0.80]);
      expect(details.valueEstimate, 0.77);
    });

    test('fromMap throws when sourceActionId is invalid', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'sourceActionId': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when sourceActionName is invalid', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'sourceActionName': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when actionGroup is invalid', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'actionGroup': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when decisionType is invalid', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'decisionType': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when difficultyChange is invalid', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'difficultyChange': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when difficulty ranks are invalid', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'difficultyRankBefore': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'difficultyRankAfter': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'difficultyDelta': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when currentDifficulty or nextDifficultyLabel is invalid',
            () {
          expect(
                () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
              'currentDifficulty': 999,
            }),
            throwsA(isA<FormatException>()),
          );

          expect(
                () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
              'nextDifficultyLabel': 999,
            }),
            throwsA(isA<FormatException>()),
          );
        });

    test('fromMap throws when supportStrategy or pedagogicalEffect is invalid',
            () {
          expect(
                () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
              'supportStrategy': 999,
            }),
            throwsA(isA<FormatException>()),
          );

          expect(
                () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
              'pedagogicalEffect': 999,
            }),
            throwsA(isA<FormatException>()),
          );
        });

    test('fromMap throws when valueEstimate is invalid', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'valueEstimate': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when stateInterpretation is not a map', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'stateInterpretation': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when stateInterpretation keys/values are invalid', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'stateInterpretation': <dynamic, dynamic>{
            1: 0.5,
          },
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'stateInterpretation': <String, dynamic>{
            'eng': 'bad',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when stateFlags is not a map', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'stateFlags': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when stateFlags keys/values are invalid', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'stateFlags': <dynamic, dynamic>{
            1: true,
          },
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'stateFlags': <String, dynamic>{
            'low_engagement': 'bad',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when actionProbabilities is not a list', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'actionProbabilities': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when actionProbabilities contains invalid item', () {
      expect(
            () => AdaptiveDecisionDetails.fromMap(<String, dynamic>{
          'actionProbabilities': <dynamic>[0.1, 'bad'],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toMap returns expected values', () {
      const details = AdaptiveDecisionDetails(
        sourceActionId: 1,
        sourceActionName: 'easy_task',
        actionGroup: 'challenge_adjustment',
        decisionType: 'difficulty_adjustment',
        difficultyChange: 'decrease',
        difficultyRankBefore: 2,
        difficultyRankAfter: 1,
        difficultyDelta: -1,
        currentDifficulty: 'medium',
        nextDifficultyLabel: 'easy',
        supportStrategy: 'reduce_pressure',
        pedagogicalEffect: 'difficulty_reduction',
        stateInterpretation: <String, double>{
          'eng': 0.3,
        },
        stateFlags: <String, bool>{
          'low_engagement': true,
        },
        actionProbabilities: <double>[0.8, 0.2],
        valueEstimate: 0.66,
      );

      final map = details.toMap();

      expect(map['sourceActionId'], 1);
      expect(map['sourceActionName'], 'easy_task');
      expect(map['actionGroup'], 'challenge_adjustment');
      expect(map['decisionType'], 'difficulty_adjustment');
      expect(map['difficultyChange'], 'decrease');
      expect(map['difficultyRankBefore'], 2);
      expect(map['difficultyRankAfter'], 1);
      expect(map['difficultyDelta'], -1);
      expect(map['currentDifficulty'], 'medium');
      expect(map['nextDifficultyLabel'], 'easy');
      expect(map['supportStrategy'], 'reduce_pressure');
      expect(map['pedagogicalEffect'], 'difficulty_reduction');
      expect(map['stateInterpretation'], <String, double>{'eng': 0.3});
      expect(map['stateFlags'], <String, bool>{'low_engagement': true});
      expect(map['actionProbabilities'], <double>[0.8, 0.2]);
      expect(map['valueEstimate'], 0.66);
    });

    test('copyWith replaces only provided fields', () {
      const original = AdaptiveDecisionDetails(
        sourceActionId: 1,
        sourceActionName: 'medium_task',
        actionGroup: 'challenge_adjustment',
        difficultyDelta: 1,
        valueEstimate: 0.5,
      );

      final updated = original.copyWith(
        sourceActionName: 'hard_task',
        difficultyDelta: 2,
        valueEstimate: 0.9,
      );

      expect(updated.sourceActionId, 1);
      expect(updated.sourceActionName, 'hard_task');
      expect(updated.actionGroup, 'challenge_adjustment');
      expect(updated.difficultyDelta, 2);
      expect(updated.valueEstimate, 0.9);
    });

    test('equality works for identical values', () {
      const a = AdaptiveDecisionDetails(
        sourceActionId: 2,
        sourceActionName: 'flow_task',
        actionGroup: 'flow_regulation',
        stateInterpretation: <String, double>{'eng': 0.4},
        stateFlags: <String, bool>{'low_engagement': true},
        actionProbabilities: <double>[0.1, 0.9],
        valueEstimate: 0.8,
      );

      const b = AdaptiveDecisionDetails(
        sourceActionId: 2,
        sourceActionName: 'flow_task',
        actionGroup: 'flow_regulation',
        stateInterpretation: <String, double>{'eng': 0.4},
        stateFlags: <String, bool>{'low_engagement': true},
        actionProbabilities: <double>[0.1, 0.9],
        valueEstimate: 0.8,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains important fields', () {
      const details = AdaptiveDecisionDetails(
        sourceActionId: 3,
        sourceActionName: 'hard_task',
        actionGroup: 'challenge_adjustment',
      );

      final text = details.toString();

      expect(text, contains('AdaptiveDecisionDetails'));
      expect(text, contains('sourceActionId: 3'));
      expect(text, contains('sourceActionName: hard_task'));
      expect(text, contains('actionGroup: challenge_adjustment'));
    });
  });
}