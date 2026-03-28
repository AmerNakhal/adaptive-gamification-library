import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveGamification', () {
    test('initFromString loads structured policy and decides using exact key', () {
      const policyJson = '''
      {
        "metadata": {
          "format_version": "2.0",
          "policy_type": "deterministic_lookup_table",
          "state_order": ["eng", "mot", "flow", "perf"],
          "state_key_format": "eng=<v>|mot=<v>|flow=<v>|perf=<v>",
          "state_decimals": 2,
          "grid_resolution": 0.25
        },
        "policy": {
          "eng=0.50|mot=0.50|flow=0.75|perf=0.50": {
            "state": {
              "eng": 0.50,
              "mot": 0.50,
              "flow": 0.75,
              "perf": 0.50
            },
            "action": 2,
            "decision": {
              "next_difficulty": "hard",
              "reason": "policy_match",
              "support_strategy": "balanced_progression",
              "source_action_name": "medium_task"
            },
            "probs": [0.05, 0.10, 0.70, 0.10, 0.03, 0.02],
            "value": 0.91
          }
        }
      }
      ''';

      final engine = AdaptiveEngine();
      engine.initFromString(policyJson);

      const state = UserState(
        currentDifficultyIndex: 2,
        accuracy: 0.50,
        responseTime: 1.00,
        correctStreak: 2,
      );

      final decision = engine.decide(state);

      expect(engine.isInitialized, isTrue);
      expect(engine.isStructuredFormat, isTrue);
      expect(engine.policySize, equals(1));

      expect(decision.nextDifficulty, equals('hard'));
      expect(decision.reason, equals('policy_match'));
      expect(decision.supportStrategy, equals('balanced_progression'));
      expect(decision.sourceActionName, equals('medium_task'));
      expect(decision.lookupKey, equals('eng=0.50|mot=0.50|flow=0.75|perf=0.50'));
      expect(decision.foundExactMatch, isTrue);
    });

    test('fallback triggers when key is not found', () {
      const policyJson = '''
      {
        "metadata": {
          "format_version": "2.0",
          "state_decimals": 2,
          "grid_resolution": 0.25
        },
        "policy": {}
      }
      ''';

      final engine = AdaptiveEngine();
      engine.initFromString(policyJson);

      const state = UserState(
        currentDifficultyIndex: 0,
        accuracy: 0.20,
        responseTime: 2.0,
        correctStreak: 0,
      );

      final decision = engine.decide(state);

      expect(decision.nextDifficulty, equals('easy'));
      expect(decision.reason, contains('fallback'));
      expect(decision.foundExactMatch, isFalse);
    });

    test('throws if decide is called before initialization', () {
      final engine = AdaptiveEngine();

      expect(
            () => engine.decide(
          const UserState(
            currentDifficultyIndex: 0,
            accuracy: 0.5,
            responseTime: 1.0,
            correctStreak: 1,
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}