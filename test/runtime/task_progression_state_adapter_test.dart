import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskProgressionStateAdapter', () {
    test('adapt maps common task progression telemetry into AdaptiveState', () {
      const adapter = TaskProgressionStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'completion': 0.8,
        'successRate': 0.7,
        'pace': 0.6,
        'retryCount': 2.0,
        'fatigue': 0.2,
      });

      expect(state.performance, closeTo(0.7, 1e-9));

      final expectedEngagement = (0.65 * 0.8) + (0.35 * 0.6);
      expect(state.engagement, closeTo(expectedEngagement, 1e-9));

      final normalizedRetryPressure = 2.0 / 5.0;
      final expectedMotivation =
          (0.55 * 0.8) + (0.25 * 0.7) + (0.20 * (1.0 - 0.2)) - (0.10 * normalizedRetryPressure);
      expect(state.motivation, closeTo(expectedMotivation, 1e-9));

      final expectedFlow =
          (0.40 * 0.8) + (0.35 * 0.7) + (0.25 * 0.6) - (0.10 * 0.2);
      expect(state.flow, closeTo(expectedFlow, 1e-9));

      expect(state.isNormalized, isTrue);
    });

    test('adapt supports alias keys completionRate and success', () {
      const adapter = TaskProgressionStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'completionRate': 0.9,
        'success': 0.8,
        'progressPace': 0.7,
        'retries': 1.0,
        'fatigueLevel': 0.1,
      });

      expect(state.performance, closeTo(0.8, 1e-9));
      expect(state.engagement, inInclusiveRange(0.0, 1.0));
      expect(state.motivation, inInclusiveRange(0.0, 1.0));
      expect(state.flow, inInclusiveRange(0.0, 1.0));
      expect(state.isNormalized, isTrue);
    });

    test('adapt uses defaults when optional telemetry is missing', () {
      const adapter = TaskProgressionStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'completion': 0.6,
      });

      expect(state.performance, 0.6);

      final expectedEngagement = (0.65 * 0.6) + (0.35 * 0.5);
      expect(state.engagement, closeTo(expectedEngagement, 1e-9));

      final expectedMotivation =
          (0.55 * 0.6) + (0.25 * 0.6) + (0.20 * 1.0) - (0.10 * 0.0);
      expect(state.motivation, closeTo(expectedMotivation, 1e-9));

      final expectedFlow =
          (0.40 * 0.6) + (0.35 * 0.6) + (0.25 * 0.5) - (0.10 * 0.0);
      expect(state.flow, closeTo(expectedFlow, 1e-9));
    });

    test('adapt clamps completion success pace and fatigue into [0,1]', () {
      const adapter = TaskProgressionStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'completion': 2.0,
        'successRate': -1.0,
        'pace': 3.0,
        'retryCount': 99.0,
        'fatigue': 2.0,
      });

      expect(state.performance, 0.0);
      expect(state.engagement, inInclusiveRange(0.0, 1.0));
      expect(state.motivation, inInclusiveRange(0.0, 1.0));
      expect(state.flow, inInclusiveRange(0.0, 1.0));
      expect(state.isNormalized, isTrue);
    });

    test('adapt uses custom maxRetryCount', () {
      const adapter = TaskProgressionStateAdapter(
        maxRetryCount: 10.0,
      );

      final state = adapter.adapt(<String, dynamic>{
        'completion': 0.5,
        'successRate': 0.5,
        'pace': 0.5,
        'retryCount': 5.0,
        'fatigue': 0.0,
      });

      final normalizedRetryPressure = 5.0 / 10.0;
      final expectedMotivation =
          (0.55 * 0.5) + (0.25 * 0.5) + (0.20 * 1.0) - (0.10 * normalizedRetryPressure);
      expect(state.motivation, closeTo(expectedMotivation, 1e-9));
    });

    test('adapt handles zero or negative maxRetryCount safely', () {
      const adapter = TaskProgressionStateAdapter(
        maxRetryCount: 0.0,
      );

      final state = adapter.adapt(<String, dynamic>{
        'completion': 0.5,
        'successRate': 0.5,
        'pace': 0.5,
        'retryCount': 5.0,
        'fatigue': 0.0,
      });

      final expectedMotivation =
          (0.55 * 0.5) + (0.25 * 0.5) + (0.20 * 1.0) - (0.10 * 0.0);
      expect(state.motivation, closeTo(expectedMotivation, 1e-9));
    });

    test('adapt throws when provided numeric field is invalid', () {
      const adapter = TaskProgressionStateAdapter();

      expect(
            () => adapter.adapt(<String, dynamic>{
          'completion': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => adapter.adapt(<String, dynamic>{
          'completion': 0.5,
          'successRate': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => adapter.adapt(<String, dynamic>{
          'completion': 0.5,
          'pace': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => adapter.adapt(<String, dynamic>{
          'completion': 0.5,
          'retryCount': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
            () => adapter.adapt(<String, dynamic>{
          'completion': 0.5,
          'fatigue': 'bad',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toString contains important fields', () {
      const adapter = TaskProgressionStateAdapter(
        clampValues: false,
        maxRetryCount: 8.0,
      );

      final text = adapter.toString();

      expect(text, contains('TaskProgressionStateAdapter'));
      expect(text, contains('clampValues: false'));
      expect(text, contains('maxRetryCount: 8.0'));
    });

    test('equality works for identical adapters', () {
      const a = TaskProgressionStateAdapter(
        clampValues: true,
        maxRetryCount: 5.0,
      );
      const b = TaskProgressionStateAdapter(
        clampValues: true,
        maxRetryCount: 5.0,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality works for different config values', () {
      const a = TaskProgressionStateAdapter(
        clampValues: true,
        maxRetryCount: 5.0,
      );
      const b = TaskProgressionStateAdapter(
        clampValues: false,
        maxRetryCount: 10.0,
      );

      expect(a, isNot(equals(b)));
    });
  });
}