import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizStateAdapter', () {
    test('adapt maps common quiz telemetry into AdaptiveState', () {
      const adapter = QuizStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'correctness': 0.8,
        'responseTime': 15.0,
        'streak': 4.0,
        'completion': 0.9,
      });

      expect(state.performance, closeTo(0.8, 1e-9));
      expect(state.engagement, closeTo((0.75 * 0.9) + (0.25 * 0.4), 1e-9));
      expect(state.motivation, closeTo((0.60 * 0.4) + (0.40 * 0.9), 1e-9));

      final expectedResponseAlignment = 1.0 - (15.0 / 60.0);
      final expectedFlow =
          (0.40 * 0.8) + (0.30 * 0.9) + (0.30 * expectedResponseAlignment);

      expect(state.flow, closeTo(expectedFlow, 1e-9));
      expect(state.isNormalized, isTrue);
    });

    test('adapt supports alias keys accuracy and completionRate', () {
      const adapter = QuizStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'accuracy': 0.7,
        'response_time': 20.0,
        'current_streak': 5.0,
        'completionRate': 0.8,
      });

      expect(state.performance, closeTo(0.7, 1e-9));
      expect(state.engagement, isNotNull);
      expect(state.motivation, isNotNull);
      expect(state.flow, isNotNull);
      expect(state.isNormalized, isTrue);
    });

    test('adapt uses defaults when optional telemetry is missing', () {
      const adapter = QuizStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'correctness': 0.6,
      });

      expect(state.performance, 0.6);
      expect(state.engagement, closeTo((0.75 * 0.6) + (0.25 * 0.0), 1e-9));
      expect(state.motivation, closeTo((0.60 * 0.0) + (0.40 * 0.6), 1e-9));

      final expectedFlow = (0.40 * 0.6) + (0.30 * 0.6) + (0.30 * 0.5);
      expect(state.flow, closeTo(expectedFlow, 1e-9));
    });

    test('adapt clamps correctness and completion into [0,1]', () {
      const adapter = QuizStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'correctness': 2.0,
        'responseTime': 5.0,
        'streak': 20.0,
        'completion': -1.0,
      });

      expect(state.performance, 1.0);
      expect(state.engagement, inInclusiveRange(0.0, 1.0));
      expect(state.motivation, inInclusiveRange(0.0, 1.0));
      expect(state.flow, inInclusiveRange(0.0, 1.0));
      expect(state.isNormalized, isTrue);
    });

    test('adapt uses custom maxResponseTime and maxStreak', () {
      const adapter = QuizStateAdapter(
        maxResponseTime: 100.0,
        maxStreak: 20.0,
      );

      final state = adapter.adapt(<String, dynamic>{
        'correctness': 0.5,
        'responseTime': 50.0,
        'streak': 10.0,
        'completion': 0.5,
      });

      expect(state.performance, 0.5);
      expect(state.engagement, closeTo((0.75 * 0.5) + (0.25 * 0.5), 1e-9));
      expect(state.motivation, closeTo((0.60 * 0.5) + (0.40 * 0.5), 1e-9));

      final expectedFlow = (0.40 * 0.5) + (0.30 * 0.5) + (0.30 * 0.5);
      expect(state.flow, closeTo(expectedFlow, 1e-9));
    });

    test('adapt handles responseTime absence by using neutral alignment', () {
      const adapter = QuizStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'correctness': 0.5,
        'streak': 2.0,
        'completion': 0.5,
      });

      final expectedFlow = (0.40 * 0.5) + (0.30 * 0.5) + (0.30 * 0.5);
      expect(state.flow, closeTo(expectedFlow, 1e-9));
    });

    test('adapt works with score as correctness fallback', () {
      const adapter = QuizStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'score': 0.9,
        'duration': 12.0,
        'streak': 3.0,
      });

      expect(state.performance, 0.9);
      expect(state.isNormalized, isTrue);
    });

    test('adapt throws when provided numeric field is invalid', () {
      const adapter = QuizStateAdapter();

      expect(
            () => adapter.adapt(<String, dynamic>{
          'correctness': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => adapter.adapt(<String, dynamic>{
          'accuracy': 0.5,
          'responseTime': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => adapter.adapt(<String, dynamic>{
          'accuracy': 0.5,
          'streak': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => adapter.adapt(<String, dynamic>{
          'accuracy': 0.5,
          'completion': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toString contains important fields', () {
      const adapter = QuizStateAdapter(
        clampValues: false,
        maxResponseTime: 100.0,
        maxStreak: 20.0,
      );

      final text = adapter.toString();

      expect(text, contains('QuizStateAdapter'));
      expect(text, contains('clampValues: false'));
      expect(text, contains('maxResponseTime: 100.0'));
      expect(text, contains('maxStreak: 20.0'));
    });

    test('equality works for identical adapters', () {
      const a = QuizStateAdapter(
        clampValues: true,
        maxResponseTime: 60.0,
        maxStreak: 10.0,
      );
      const b = QuizStateAdapter(
        clampValues: true,
        maxResponseTime: 60.0,
        maxStreak: 10.0,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality works for different config values', () {
      const a = QuizStateAdapter(
        clampValues: true,
        maxResponseTime: 60.0,
        maxStreak: 10.0,
      );
      const b = QuizStateAdapter(
        clampValues: false,
        maxResponseTime: 100.0,
        maxStreak: 20.0,
      );

      expect(a, isNot(equals(b)));
    });
  });
}