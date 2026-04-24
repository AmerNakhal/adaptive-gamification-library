import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveState', () {
    test('constructs with provided values', () {
      const state = AdaptiveState(
        engagement: 0.8,
        motivation: 0.7,
        flow: 0.6,
        performance: 0.9,
      );

      expect(state.engagement, 0.8);
      expect(state.motivation, 0.7);
      expect(state.flow, 0.6);
      expect(state.performance, 0.9);
    });

    test('clamped constructor clamps values into [0, 1]', () {
      final state = AdaptiveState.clamped(
        engagement: 1.5,
        motivation: -0.2,
        flow: 0.5,
        performance: double.infinity,
      );

      expect(state.engagement, 1.0);
      expect(state.motivation, 0.0);
      expect(state.flow, 0.5);
      expect(state.performance, 1.0);
    });

    test('fromMap reads valid numeric fields', () {
      final state = AdaptiveState.fromMap(<String, dynamic>{
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

    test('fromMap with clampValues clamps values', () {
      final state = AdaptiveState.fromMap(
        <String, dynamic>{
          'engagement': -1,
          'motivation': 2,
          'flow': 0.5,
          'performance': 3,
        },
        clampValues: true,
      );

      expect(state.engagement, 0.0);
      expect(state.motivation, 1.0);
      expect(state.flow, 0.5);
      expect(state.performance, 1.0);
    });

    test('fromMap throws when required field is missing', () {
      expect(
            () => AdaptiveState.fromMap(<String, dynamic>{
          'engagement': 0.1,
          'motivation': 0.2,
          'flow': 0.3,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromMap throws when field type is invalid', () {
      expect(
            () => AdaptiveState.fromMap(<String, dynamic>{
          'engagement': 'bad',
          'motivation': 0.2,
          'flow': 0.3,
          'performance': 0.4,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toMap returns expected map', () {
      const state = AdaptiveState(
        engagement: 0.1,
        motivation: 0.2,
        flow: 0.3,
        performance: 0.4,
      );

      expect(state.toMap(), <String, double>{
        'engagement': 0.1,
        'motivation': 0.2,
        'flow': 0.3,
        'performance': 0.4,
      });
    });

    test('toList returns values in canonical order', () {
      const state = AdaptiveState(
        engagement: 0.1,
        motivation: 0.2,
        flow: 0.3,
        performance: 0.4,
      );

      expect(state.toList(), <double>[0.1, 0.2, 0.3, 0.4]);
    });

    test('isNormalized returns true only when all values are within [0,1]', () {
      const goodState = AdaptiveState(
        engagement: 0.0,
        motivation: 0.5,
        flow: 1.0,
        performance: 0.7,
      );

      const badState = AdaptiveState(
        engagement: 1.2,
        motivation: 0.5,
        flow: 0.4,
        performance: 0.7,
      );

      expect(goodState.isNormalized, isTrue);
      expect(badState.isNormalized, isFalse);
    });

    test('clamped returns clamped copy', () {
      const state = AdaptiveState(
        engagement: -0.3,
        motivation: 1.4,
        flow: 0.5,
        performance: 2.0,
      );

      final clamped = state.clamped();

      expect(clamped.engagement, 0.0);
      expect(clamped.motivation, 1.0);
      expect(clamped.flow, 0.5);
      expect(clamped.performance, 1.0);
    });

    test('rounded returns rounded copy', () {
      const state = AdaptiveState(
        engagement: 0.1234,
        motivation: 0.5678,
        flow: 0.9999,
        performance: 0.1111,
      );

      final rounded = state.rounded(2);

      expect(rounded.engagement, 0.12);
      expect(rounded.motivation, 0.57);
      expect(rounded.flow, 1.0);
      expect(rounded.performance, 0.11);
    });

    test('copyWith replaces only provided fields', () {
      const state = AdaptiveState(
        engagement: 0.2,
        motivation: 0.3,
        flow: 0.4,
        performance: 0.5,
      );

      final updated = state.copyWith(
        motivation: 0.9,
        performance: 0.8,
      );

      expect(updated.engagement, 0.2);
      expect(updated.motivation, 0.9);
      expect(updated.flow, 0.4);
      expect(updated.performance, 0.8);
    });

    test('equality works for identical values', () {
      const a = AdaptiveState(
        engagement: 0.2,
        motivation: 0.3,
        flow: 0.4,
        performance: 0.5,
      );

      const b = AdaptiveState(
        engagement: 0.2,
        motivation: 0.3,
        flow: 0.4,
        performance: 0.5,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}