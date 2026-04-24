import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/runtime/state_key_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StateKeyBuilder', () {
    test('build produces canonical key with default settings', () {
      const builder = StateKeyBuilder();

      const state = AdaptiveState(
        engagement: 0.7,
        motivation: 0.6,
        flow: 0.5,
        performance: 0.8,
      );

      final key = builder.build(state);

      expect(key, '0.70|0.60|0.50|0.80');
    });

    test('build uses custom decimals', () {
      const builder = StateKeyBuilder(
        decimals: 3,
      );

      const state = AdaptiveState(
        engagement: 0.7123,
        motivation: 0.6456,
        flow: 0.5012,
        performance: 0.8999,
      );

      final key = builder.build(state);

      expect(key, '0.712|0.646|0.501|0.900');
    });

    test('build uses custom delimiter', () {
      const builder = StateKeyBuilder(
        delimiter: ',',
      );

      const state = AdaptiveState(
        engagement: 0.1,
        motivation: 0.2,
        flow: 0.3,
        performance: 0.4,
      );

      final key = builder.build(state);

      expect(key, '0.10,0.20,0.30,0.40');
    });

    test('build clamps values when clampValues is true', () {
      const builder = StateKeyBuilder(
        clampValues: true,
      );

      const state = AdaptiveState(
        engagement: -0.5,
        motivation: 1.8,
        flow: 0.5,
        performance: 2.0,
      );

      final key = builder.build(state);

      expect(key, '0.00|1.00|0.50|1.00');
    });

    test('build does not clamp values when clampValues is false', () {
      const builder = StateKeyBuilder(
        clampValues: false,
      );

      const state = AdaptiveState(
        engagement: -0.5,
        motivation: 1.8,
        flow: 0.5,
        performance: 2.0,
      );

      final key = builder.build(state);

      expect(key, '-0.50|1.80|0.50|2.00');
    });

    test('normalizeState clamps values when enabled', () {
      const builder = StateKeyBuilder(
        clampValues: true,
      );

      const state = AdaptiveState(
        engagement: -1.0,
        motivation: 2.0,
        flow: 0.4,
        performance: 1.5,
      );

      final normalized = builder.normalizeState(state);

      expect(normalized.engagement, 0.0);
      expect(normalized.motivation, 1.0);
      expect(normalized.flow, 0.4);
      expect(normalized.performance, 1.0);
    });

    test('normalizeState returns original values when clamping disabled', () {
      const builder = StateKeyBuilder(
        clampValues: false,
      );

      const state = AdaptiveState(
        engagement: -1.0,
        motivation: 2.0,
        flow: 0.4,
        performance: 1.5,
      );

      final normalized = builder.normalizeState(state);

      expect(normalized.engagement, -1.0);
      expect(normalized.motivation, 2.0);
      expect(normalized.flow, 0.4);
      expect(normalized.performance, 1.5);
    });

    test('copyWith replaces only provided values', () {
      const builder = StateKeyBuilder(
        decimals: 2,
        clampValues: true,
        delimiter: '|',
      );

      final updated = builder.copyWith(
        decimals: 4,
        delimiter: ',',
      );

      expect(updated.decimals, 4);
      expect(updated.clampValues, isTrue);
      expect(updated.delimiter, ',');
    });

    test('toString contains important fields', () {
      const builder = StateKeyBuilder(
        decimals: 3,
        clampValues: false,
        delimiter: ',',
      );

      final text = builder.toString();

      expect(text, contains('StateKeyBuilder'));
      expect(text, contains('decimals: 3'));
      expect(text, contains('clampValues: false'));
      expect(text, contains('delimiter: ,'));
    });

    test('equality works for identical values', () {
      const a = StateKeyBuilder(
        decimals: 2,
        clampValues: true,
        delimiter: '|',
      );

      const b = StateKeyBuilder(
        decimals: 2,
        clampValues: true,
        delimiter: '|',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('rounding behavior is stable at decimal boundary', () {
      const builder = StateKeyBuilder(
        decimals: 2,
      );

      const state = AdaptiveState(
        engagement: 0.125,
        motivation: 0.135,
        flow: 0.145,
        performance: 0.155,
      );

      final key = builder.build(state);

      expect(key, '0.13|0.14|0.14|0.16');
    });
  });
}