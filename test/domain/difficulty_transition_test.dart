import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DifficultyTransition', () {
    test('constructs with explicit values', () {
      const transition = DifficultyTransition(
        beforeRank: 1,
        afterRank: 3,
        beforeLevel: 'easy',
        afterLevel: 'hard',
        changeType: 'increase',
        delta: 2,
      );

      expect(transition.beforeRank, 1);
      expect(transition.afterRank, 3);
      expect(transition.beforeLevel, 'easy');
      expect(transition.afterLevel, 'hard');
      expect(transition.changeType, 'increase');
      expect(transition.delta, 2);
      expect(transition.isIncrease, isTrue);
      expect(transition.isDecrease, isFalse);
      expect(transition.isMaintain, isFalse);
    });

    test('fromRanks builds increase transition', () {
      final transition = DifficultyTransition.fromRanks(
        beforeRank: 1,
        afterRank: 3,
      );

      expect(transition.beforeRank, 1);
      expect(transition.afterRank, 3);
      expect(transition.delta, 2);
      expect(transition.changeType, DifficultyChangeType.increase);
      expect(transition.beforeLevel, DifficultyLevel.fromRank(1));
      expect(transition.afterLevel, DifficultyLevel.fromRank(3));
      expect(transition.isIncrease, isTrue);
    });

    test('fromRanks builds decrease transition', () {
      final transition = DifficultyTransition.fromRanks(
        beforeRank: 4,
        afterRank: 2,
      );

      expect(transition.delta, -2);
      expect(transition.changeType, DifficultyChangeType.decrease);
      expect(transition.isDecrease, isTrue);
      expect(transition.isIncrease, isFalse);
      expect(transition.isMaintain, isFalse);
    });

    test('fromRanks builds maintain transition', () {
      final transition = DifficultyTransition.fromRanks(
        beforeRank: 2,
        afterRank: 2,
      );

      expect(transition.delta, 0);
      expect(transition.changeType, DifficultyChangeType.maintain);
      expect(transition.isMaintain, isTrue);
      expect(transition.isIncrease, isFalse);
      expect(transition.isDecrease, isFalse);
    });

    test('fromMap reads minimal valid map and derives semantic values', () {
      final transition = DifficultyTransition.fromMap(<String, dynamic>{
        'beforeRank': 1,
        'afterRank': 2,
      });

      expect(transition.beforeRank, 1);
      expect(transition.afterRank, 2);
      expect(transition.beforeLevel, DifficultyLevel.fromRank(1));
      expect(transition.afterLevel, DifficultyLevel.fromRank(2));
      expect(transition.delta, 1);
      expect(transition.changeType, DifficultyChangeType.increase);
    });

    test('fromMap reads full valid map', () {
      final transition = DifficultyTransition.fromMap(<String, dynamic>{
        'beforeRank': 2,
        'afterRank': 4,
        'beforeLevel': 'medium',
        'afterLevel': 'veryHard',
        'changeType': 'increase',
        'delta': 2,
      });

      expect(transition.beforeRank, 2);
      expect(transition.afterRank, 4);
      expect(transition.beforeLevel, 'medium');
      expect(transition.afterLevel, 'veryHard');
      expect(transition.changeType, 'increase');
      expect(transition.delta, 2);
    });

    test('fromMap normalizes unsupported levels and changeType', () {
      final transition = DifficultyTransition.fromMap(<String, dynamic>{
        'beforeRank': 2,
        'afterRank': 2,
        'beforeLevel': 'unknown_before',
        'afterLevel': 'unknown_after',
        'changeType': 'weird_type',
      });

      expect(transition.beforeLevel, DifficultyLevel.medium);
      expect(transition.afterLevel, DifficultyLevel.medium);
      expect(transition.changeType, DifficultyChangeType.maintain);
      expect(transition.delta, 0);
    });

    test('fromMap derives changeType from delta when omitted', () {
      final increaseTransition = DifficultyTransition.fromMap(<String, dynamic>{
        'beforeRank': 1,
        'afterRank': 3,
      });

      final decreaseTransition = DifficultyTransition.fromMap(<String, dynamic>{
        'beforeRank': 3,
        'afterRank': 1,
      });

      final maintainTransition = DifficultyTransition.fromMap(<String, dynamic>{
        'beforeRank': 2,
        'afterRank': 2,
      });

      expect(
        increaseTransition.changeType,
        DifficultyChangeType.increase,
      );
      expect(
        decreaseTransition.changeType,
        DifficultyChangeType.decrease,
      );
      expect(
        maintainTransition.changeType,
        DifficultyChangeType.maintain,
      );
    });

    test('fromMap throws when beforeRank is missing', () {
      expect(
            () => DifficultyTransition.fromMap(<String, dynamic>{
          'afterRank': 2,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when afterRank is missing', () {
      expect(
            () => DifficultyTransition.fromMap(<String, dynamic>{
          'beforeRank': 2,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when beforeRank is not numeric', () {
      expect(
            () => DifficultyTransition.fromMap(<String, dynamic>{
          'beforeRank': 'bad',
          'afterRank': 2,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when afterRank is not numeric', () {
      expect(
            () => DifficultyTransition.fromMap(<String, dynamic>{
          'beforeRank': 1,
          'afterRank': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when beforeLevel is not a string', () {
      expect(
            () => DifficultyTransition.fromMap(<String, dynamic>{
          'beforeRank': 1,
          'afterRank': 2,
          'beforeLevel': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when afterLevel is not a string', () {
      expect(
            () => DifficultyTransition.fromMap(<String, dynamic>{
          'beforeRank': 1,
          'afterRank': 2,
          'afterLevel': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when changeType is not a string', () {
      expect(
            () => DifficultyTransition.fromMap(<String, dynamic>{
          'beforeRank': 1,
          'afterRank': 2,
          'changeType': 123,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when delta is not numeric', () {
      expect(
            () => DifficultyTransition.fromMap(<String, dynamic>{
          'beforeRank': 1,
          'afterRank': 2,
          'delta': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toMap returns expected map', () {
      const transition = DifficultyTransition(
        beforeRank: 1,
        afterRank: 3,
        beforeLevel: 'easy',
        afterLevel: 'hard',
        changeType: 'increase',
        delta: 2,
      );

      expect(transition.toMap(), <String, dynamic>{
        'beforeRank': 1,
        'afterRank': 3,
        'beforeLevel': 'easy',
        'afterLevel': 'hard',
        'changeType': 'increase',
        'delta': 2,
      });
    });

    test('copyWith replaces only provided values', () {
      const original = DifficultyTransition(
        beforeRank: 1,
        afterRank: 2,
        beforeLevel: 'easy',
        afterLevel: 'medium',
        changeType: 'increase',
        delta: 1,
      );

      final updated = original.copyWith(
        afterRank: 4,
        afterLevel: 'veryHard',
        delta: 3,
      );

      expect(updated.beforeRank, 1);
      expect(updated.afterRank, 4);
      expect(updated.beforeLevel, 'easy');
      expect(updated.afterLevel, 'veryHard');
      expect(updated.changeType, 'increase');
      expect(updated.delta, 3);
    });

    test('equality works for identical values', () {
      const a = DifficultyTransition(
        beforeRank: 2,
        afterRank: 3,
        beforeLevel: 'medium',
        afterLevel: 'hard',
        changeType: 'increase',
        delta: 1,
      );

      const b = DifficultyTransition(
        beforeRank: 2,
        afterRank: 3,
        beforeLevel: 'medium',
        afterLevel: 'hard',
        changeType: 'increase',
        delta: 1,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains important fields', () {
      const transition = DifficultyTransition(
        beforeRank: 1,
        afterRank: 3,
        beforeLevel: 'easy',
        afterLevel: 'hard',
        changeType: 'increase',
        delta: 2,
      );

      final text = transition.toString();

      expect(text, contains('DifficultyTransition'));
      expect(text, contains('beforeRank: 1'));
      expect(text, contains('afterRank: 3'));
      expect(text, contains('beforeLevel: easy'));
      expect(text, contains('afterLevel: hard'));
      expect(text, contains('changeType: increase'));
      expect(text, contains('delta: 2'));
    });
  });
}