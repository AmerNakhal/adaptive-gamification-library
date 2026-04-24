import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/mappers/state_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStateAdapter extends StateAdapter<Map<String, dynamic>> {
  const _FakeStateAdapter();

  @override
  AdaptiveState adapt(Map<String, dynamic> input) {
    return const AdaptiveState(
      engagement: 0.9,
      motivation: 0.8,
      flow: 0.7,
      performance: 0.6,
    );
  }
}

void main() {
  group('StateMapper', () {
    test('fromMap uses default adapter to build AdaptiveState', () {
      const mapper = StateMapper();

      final state = mapper.fromMap(<String, dynamic>{
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

    test('fromMap respects default adapter configuration', () {
      const mapper = StateMapper(
        defaultAdapter: DefaultStateAdapter(
          clampValues: false,
        ),
      );

      final state = mapper.fromMap(<String, dynamic>{
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

    test('fromMap throws when default adapter input is invalid', () {
      const mapper = StateMapper();

      expect(
            () => mapper.fromMap(<String, dynamic>{
          'engagement': 'bad',
          'motivation': 0.4,
          'flow': 0.6,
          'performance': 0.8,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('mapWith uses provided adapter instead of default adapter', () {
      const mapper = StateMapper();
      const adapter = _FakeStateAdapter();

      final state = mapper.mapWith<Map<String, dynamic>>(
        <String, dynamic>{
          'engagement': 0.1,
          'motivation': 0.2,
          'flow': 0.3,
          'performance': 0.4,
        },
        adapter,
      );

      expect(state.engagement, 0.9);
      expect(state.motivation, 0.8);
      expect(state.flow, 0.7);
      expect(state.performance, 0.6);
    });

    test('mapWith works with quiz state adapter', () {
      const mapper = StateMapper();
      const adapter = QuizStateAdapter();

      final state = mapper.mapWith<Map<String, dynamic>>(
        <String, dynamic>{
          'correctness': 0.8,
          'responseTime': 15.0,
          'streak': 4.0,
          'completion': 0.9,
        },
        adapter,
      );

      expect(state.performance, closeTo(0.8, 1e-9));
      expect(state.engagement, inInclusiveRange(0.0, 1.0));
      expect(state.motivation, inInclusiveRange(0.0, 1.0));
      expect(state.flow, inInclusiveRange(0.0, 1.0));
    });

    test('mapWith works with task progression state adapter', () {
      const mapper = StateMapper();
      const adapter = TaskProgressionStateAdapter();

      final state = mapper.mapWith<Map<String, dynamic>>(
        <String, dynamic>{
          'completion': 0.8,
          'successRate': 0.7,
          'pace': 0.6,
          'retryCount': 2.0,
          'fatigue': 0.2,
        },
        adapter,
      );

      expect(state.performance, closeTo(0.7, 1e-9));
      expect(state.engagement, inInclusiveRange(0.0, 1.0));
      expect(state.motivation, inInclusiveRange(0.0, 1.0));
      expect(state.flow, inInclusiveRange(0.0, 1.0));
    });

    test('toString contains important fields', () {
      const mapper = StateMapper(
        defaultAdapter: DefaultStateAdapter(
          clampValues: false,
        ),
      );

      final text = mapper.toString();

      expect(text, contains('StateMapper'));
      expect(text, contains('defaultAdapter:'));
    });

    test('equality works for identical mappers', () {
      const a = StateMapper(
        defaultAdapter: DefaultStateAdapter(
          clampValues: true,
        ),
      );
      const b = StateMapper(
        defaultAdapter: DefaultStateAdapter(
          clampValues: true,
        ),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality works for different default adapters', () {
      const a = StateMapper(
        defaultAdapter: DefaultStateAdapter(
          clampValues: true,
        ),
      );
      const b = StateMapper(
        defaultAdapter: DefaultStateAdapter(
          clampValues: false,
        ),
      );

      expect(a, isNot(equals(b)));
    });
  });
}