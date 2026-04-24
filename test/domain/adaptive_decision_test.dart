import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('AdaptiveDecision', () {
    test('constructs with required values only', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
      );

      expect(decision.nextDifficulty, 2);
      expect(decision.source, 'exact_match');
      expect(decision.reason, isNull);
      expect(decision.actionLabel, isNull);
      expect(decision.details, isNull);
      expect(decision.hasDetails, isFalse);
      expect(decision.isExactMatch, isTrue);
      expect(decision.isFallback, isFalse);
    });

    test('constructs with optional values', () {
      const details = AdaptiveDecisionDetails(
        sourceActionId: 1,
        sourceActionName: 'medium_task',
        actionGroup: 'challenge_adjustment',
      );

      const decision = AdaptiveDecision(
        nextDifficulty: 3,
        source: 'fallback',
        reason: 'missing_state_key',
        actionLabel: 'medium_task',
        details: details,
      );

      expect(decision.nextDifficulty, 3);
      expect(decision.source, 'fallback');
      expect(decision.reason, 'missing_state_key');
      expect(decision.actionLabel, 'medium_task');
      expect(decision.details, details);
      expect(decision.hasDetails, isTrue);
      expect(decision.isExactMatch, isFalse);
      expect(decision.isFallback, isTrue);
    });

    test('fromMap reads minimal valid map', () {
      final decision = AdaptiveDecision.fromMap(<String, dynamic>{
        'nextDifficulty': 2,
      });

      expect(decision.nextDifficulty, 2);
      expect(decision.source, DecisionSource.exactMatch);
      expect(decision.reason, isNull);
      expect(decision.actionLabel, isNull);
      expect(decision.details, isNull);
    });

    test('fromMap reads full valid map', () {
      final decision = AdaptiveDecision.fromMap(<String, dynamic>{
        'nextDifficulty': 4,
        'source': 'fallback',
        'reason': 'no_exact_match',
        'actionLabel': 'hard_task',
        'details': <String, dynamic>{
          'sourceActionId': 3,
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
            'eng': 0.4,
            'mot': 0.7,
          },
          'stateFlags': <String, dynamic>{
            'low_engagement': true,
          },
          'actionProbabilities': <dynamic>[0.1, 0.2, 0.7],
          'valueEstimate': 0.85,
        },
      });

      expect(decision.nextDifficulty, 4);
      expect(decision.source, DecisionSource.fallback);
      expect(decision.reason, 'no_exact_match');
      expect(decision.actionLabel, 'hard_task');
      expect(decision.details, isNotNull);
      expect(decision.details!.sourceActionId, 3);
      expect(decision.details!.sourceActionName, 'hard_task');
      expect(decision.details!.difficultyDelta, 2);
      expect(decision.details!.hasActionProbabilities, isTrue);
      expect(decision.details!.hasValueEstimate, isTrue);
    });

    test('fromMap normalizes unsupported source to exact_match', () {
      final decision = AdaptiveDecision.fromMap(<String, dynamic>{
        'nextDifficulty': 1,
        'source': 'something_unknown',
      });

      expect(decision.source, DecisionSource.exactMatch);
    });

    test('fromMap throws when nextDifficulty is missing', () {
      expect(
            () => AdaptiveDecision.fromMap(<String, dynamic>{
          'source': 'exact_match',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when nextDifficulty is not numeric', () {
      expect(
            () => AdaptiveDecision.fromMap(<String, dynamic>{
          'nextDifficulty': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when source is not a string', () {
      expect(
            () => AdaptiveDecision.fromMap(<String, dynamic>{
          'nextDifficulty': 1,
          'source': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when reason is not a string', () {
      expect(
            () => AdaptiveDecision.fromMap(<String, dynamic>{
          'nextDifficulty': 1,
          'reason': 999,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when actionLabel is not a string', () {
      expect(
            () => AdaptiveDecision.fromMap(<String, dynamic>{
          'nextDifficulty': 1,
          'actionLabel': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when details is not a map', () {
      expect(
            () => AdaptiveDecision.fromMap(<String, dynamic>{
          'nextDifficulty': 1,
          'details': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toMap returns expected map without details', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        reason: 'ok',
        actionLabel: 'medium_task',
      );

      expect(decision.toMap(), <String, dynamic>{
        'nextDifficulty': 2,
        'source': 'exact_match',
        'reason': 'ok',
        'actionLabel': 'medium_task',
        'details': null,
      });
    });

    test('toMap returns expected map with details', () {
      const details = AdaptiveDecisionDetails(
        sourceActionId: 1,
        sourceActionName: 'easy_task',
        actionGroup: 'challenge_adjustment',
        decisionType: 'difficulty_adjustment',
      );

      const decision = AdaptiveDecision(
        nextDifficulty: 1,
        source: 'exact_match',
        reason: 'stable',
        actionLabel: 'easy_task',
        details: details,
      );

      final map = decision.toMap();

      expect(map['nextDifficulty'], 1);
      expect(map['source'], 'exact_match');
      expect(map['reason'], 'stable');
      expect(map['actionLabel'], 'easy_task');
      expect(map['details'], isA<Map<String, dynamic>>());
      expect(
        (map['details'] as Map<String, dynamic>)['sourceActionId'],
        1,
      );
    });

    test('copyWith replaces only provided values', () {
      const original = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        reason: 'initial',
        actionLabel: 'medium_task',
      );

      final updated = original.copyWith(
        nextDifficulty: 4,
        source: 'fallback',
        reason: 'updated',
      );

      expect(updated.nextDifficulty, 4);
      expect(updated.source, 'fallback');
      expect(updated.reason, 'updated');
      expect(updated.actionLabel, 'medium_task');
    });

    test('copyWith preserves details when not replaced', () {
      const details = AdaptiveDecisionDetails(
        sourceActionId: 2,
        sourceActionName: 'flow_task',
      );

      const original = AdaptiveDecision(
        nextDifficulty: 3,
        source: 'exact_match',
        details: details,
      );

      final updated = original.copyWith(
        reason: 'new_reason',
      );

      expect(updated.details, details);
      expect(updated.reason, 'new_reason');
    });

    test('equality works for identical values', () {
      const details = AdaptiveDecisionDetails(
        sourceActionId: 1,
        sourceActionName: 'medium_task',
      );

      const a = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        reason: 'same',
        actionLabel: 'medium_task',
        details: details,
      );

      const b = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        reason: 'same',
        actionLabel: 'medium_task',
        details: details,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains important fields', () {
      const decision = AdaptiveDecision(
        nextDifficulty: 2,
        source: 'exact_match',
        reason: 'stable',
        actionLabel: 'medium_task',
      );

      final text = decision.toString();

      expect(text, contains('AdaptiveDecision'));
      expect(text, contains('nextDifficulty: 2'));
      expect(text, contains('source: exact_match'));
      expect(text, contains('reason: stable'));
      expect(text, contains('actionLabel: medium_task'));
    });
  });
}