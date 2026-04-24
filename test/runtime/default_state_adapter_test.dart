import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultStateAdapter', () {
    test('adapt maps valid input into AdaptiveState', () {
      const adapter = DefaultStateAdapter();

      final state = adapter.adapt(<String, dynamic>{
        'engagement': 0.2,
        'motivation': 0.4,
        'flow': 0.6,
        'performance': 0.8,
      });

      expect(state.engagement, 0.2);
      expect(state.motivation, 0.4);
      expect(state.flow, 0.6);
      expect(state.performance, 0.8);
    });

    test('adapt clamps values when clampValues is true', () {
      const adapter = DefaultStateAdapter(
        clampValues: true,
      );

      final state = adapter.adapt(<String, dynamic>{
        'engagement': -1,
        'motivation': 2,
        'flow': 0.5,
        'performance': 3,
      });

      expect(state.engagement, 0.0);
      expect(state.motivation, 1.0);
      expect(state.flow, 0.5);
      expect(state.performance, 1.0);
      expect(state.isNormalized, isTrue);
    });

    test('adapt does not clamp values when clampValues is false', () {
      const adapter = DefaultStateAdapter(
        clampValues: false,
      );

      final state = adapter.adapt(<String, dynamic>{
        'engagement': -1,
        'motivation': 2,
        'flow': 0.5,
        'performance': 3,
      });

      expect(state.engagement, -1.0);
      expect(state.motivation, 2.0);
      expect(state.flow, 0.5);
      expect(state.performance, 3.0);
      expect(state.isNormalized, isFalse);
    });

    test('adapt throws when a required field is missing', () {
      const adapter = DefaultStateAdapter();

      expect(
            () => adapter.adapt(<String, dynamic>{
          'engagement': 0.2,
          'motivation': 0.4,
          'flow': 0.6,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('adapt throws when a field type is invalid', () {
      const adapter = DefaultStateAdapter();

      expect(
            () => adapter.adapt(<String, dynamic>{
          'engagement': 'bad',
          'motivation': 0.4,
          'flow': 0.6,
          'performance': 0.8,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toString contains important fields', () {
      const adapter = DefaultStateAdapter(
        clampValues: false,
      );

      final text = adapter.toString();

      expect(text, contains('DefaultStateAdapter'));
      expect(text, contains('clampValues: false'));
    });

    test('equality works for identical adapters', () {
      const a = DefaultStateAdapter(
        clampValues: true,
      );
      const b = DefaultStateAdapter(
        clampValues: true,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality works for different clampValues', () {
      const a = DefaultStateAdapter(
        clampValues: true,
      );
      const b = DefaultStateAdapter(
        clampValues: false,
      );

      expect(a, isNot(equals(b)));
    });
  });
}