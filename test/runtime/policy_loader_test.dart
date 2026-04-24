import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PolicyLoader', () {
    test('loadFromJsonString loads valid normalized policy', () {
      final loader = PolicyLoader();

      final loadedPolicy = loader.loadFromJsonString('''
      {
        "metadata": {
          "formatVersion": "1.0",
          "policyType": "deterministic_lookup_table",
          "stateOrder": ["engagement", "motivation", "flow", "performance"],
          "stateDecimals": 2,
          "exportedStateCount": 2,
          "actionCount": 6
        },
        "entries": [
          {
            "stateKey": "0.10|0.20|0.30|0.40",
            "decision": {
              "nextDifficulty": 1,
              "source": "exact_match",
              "reason": "stable",
              "actionLabel": "easy_task"
            }
          },
          {
            "stateKey": "0.40|0.50|0.60|0.70",
            "decision": {
              "nextDifficulty": 3,
              "source": "exact_match",
              "reason": "increase challenge",
              "actionLabel": "hard_task"
            }
          }
        ]
      }
      ''');

      expect(loadedPolicy.isValid, isTrue);
      expect(loadedPolicy.policySize, 2);
      expect(loadedPolicy.metadata.formatVersion, '1.0');
      expect(
        loadedPolicy.decisionForKey('0.10|0.20|0.30|0.40')?.nextDifficulty,
        1,
      );
      expect(
        loadedPolicy.decisionForKey('0.40|0.50|0.60|0.70')?.actionLabel,
        'hard_task',
      );
    });

    test('loadFromMap loads valid normalized policy', () {
      final loader = PolicyLoader();

      final loadedPolicy = loader.loadFromMap(<String, dynamic>{
        'metadata': <String, dynamic>{
          'formatVersion': '1.0',
          'policyType': 'deterministic_lookup_table',
          'stateOrder': <dynamic>[
            'engagement',
            'motivation',
            'flow',
            'performance',
          ],
          'stateDecimals': 2,
          'exportedStateCount': 1,
          'actionCount': 6,
        },
        'entries': <dynamic>[
          <String, dynamic>{
            'stateKey': '0.10|0.20|0.30|0.40',
            'decision': <String, dynamic>{
              'nextDifficulty': 2,
              'source': 'exact_match',
              'reason': 'maintain',
              'actionLabel': 'medium_task',
            },
          },
        ],
      });

      expect(loadedPolicy.isValid, isTrue);
      expect(loadedPolicy.policySize, 1);
      expect(
        loadedPolicy.containsKey('0.10|0.20|0.30|0.40'),
        isTrue,
      );
    });

    test('loadFromMap loads valid python policy format', () {
      final loader = PolicyLoader();

      final loadedPolicy = loader.loadFromMap(<String, dynamic>{
        'metadata': <String, dynamic>{
          'format_version': '2.0',
          'policy_type': 'deterministic_lookup_table',
          'state_order': <dynamic>['eng', 'mot', 'flow', 'perf'],
          'state_decimals': 2,
          'num_exported_states': 1,
          'num_actions': 6,
        },
        'policy': <String, dynamic>{
          '0.20|0.30|0.40|0.50': <String, dynamic>{
            'state': <String, dynamic>{
              'eng': 0.2,
              'mot': 0.3,
              'flow': 0.4,
              'perf': 0.5,
            },
            'action': 4,
            'action_label': 'motivation_boost',
            'probs': <dynamic>[0.1, 0.1, 0.1, 0.1, 0.5, 0.1],
            'value': 0.9,
            'decision': <String, dynamic>{
              'reason': 'low motivation',
              'source_action_id': 4,
              'source_action_name': 'motivation_boost',
              'action_group': 'motivational_support',
              'decision_type': 'motivational_support',
              'difficulty_change': 'maintain',
              'difficulty_rank_before': 2,
              'difficulty_rank_after': 2,
              'difficulty_delta': 0,
              'current_difficulty': 'medium',
              'next_difficulty': 'medium',
              'support_strategy': 'encourage_persistence',
              'pedagogical_effect': 'motivational_reinforcement',
              'state_interpretation': <String, dynamic>{
                'eng': 0.2,
                'mot': 0.3,
              },
              'state_flags': <String, dynamic>{
                'low_motivation': true,
              },
            },
          },
        },
      });

      expect(loadedPolicy.isValid, isTrue);
      expect(loadedPolicy.policySize, 1);
      expect(loadedPolicy.metadata.formatVersion, '2.0');

      final decision =
      loadedPolicy.decisionForKey('0.20|0.30|0.40|0.50');
      expect(decision, isNotNull);
      expect(decision!.nextDifficulty, 2);
      expect(decision.actionLabel, 'motivation_boost');
      expect(decision.details, isNotNull);
      expect(decision.details!.supportStrategy, 'encourage_persistence');
    });

    test('loadFromJsonString throws when string is empty', () {
      final loader = PolicyLoader();

      expect(
            () => loader.loadFromJsonString('   '),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('loadFromJsonString throws when JSON is malformed', () {
      final loader = PolicyLoader();

      expect(
            () => loader.loadFromJsonString('{ bad json }'),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('loadFromJsonString throws when decoded JSON is not a map', () {
      final loader = PolicyLoader();

      expect(
            () => loader.loadFromJsonString('["not", "a", "map"]'),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('strictValidation true throws on invalid policy', () {
      final loader = PolicyLoader(
        config: const RuntimeConfig(
          strictValidation: true,
        ),
      );

      expect(
            () => loader.loadFromMap(<String, dynamic>{
          'metadata': <String, dynamic>{
            'stateOrder': <dynamic>[
              'engagement',
              'motivation',
              'flow',
              'performance',
            ],
          },
          'entries': <dynamic>[
            <String, dynamic>{
              'stateKey': '0.10|0.20|0.30|0.40',
              'decision': <String, dynamic>{
                'nextDifficulty': 1,
                'source': 'exact_match',
              },
            },
            <String, dynamic>{
              'stateKey': '0.10|0.20|0.30|0.40',
              'decision': <String, dynamic>{
                'nextDifficulty': 2,
                'source': 'exact_match',
              },
            },
          ],
        }),
        throwsA(isA<PolicyValidationException>()),
      );
    });

    test('strictValidation false does not throw on invalid policy', () {
      final loader = PolicyLoader(
        config: const RuntimeConfig(
          strictValidation: false,
        ),
      );

      final loadedPolicy = loader.loadFromMap(<String, dynamic>{
        'metadata': <String, dynamic>{
          'stateOrder': <dynamic>[
            'engagement',
            'motivation',
            'flow',
            'performance',
          ],
        },
        'entries': <dynamic>[
          <String, dynamic>{
            'stateKey': '0.10|0.20|0.30|0.40',
            'decision': <String, dynamic>{
              'nextDifficulty': 1,
              'source': 'exact_match',
            },
          },
          <String, dynamic>{
            'stateKey': '0.10|0.20|0.30|0.40',
            'decision': <String, dynamic>{
              'nextDifficulty': 2,
              'source': 'exact_match',
            },
          },
        ],
      });

      expect(loadedPolicy.isValid, isFalse);
      expect(loadedPolicy.validationResult.errors, isNotEmpty);
      expect(loadedPolicy.policySize, 1);
    });

    test('loadedPolicy indexes decisions by stateKey', () {
      final loader = PolicyLoader();

      final loadedPolicy = loader.loadFromMap(<String, dynamic>{
        'entries': <dynamic>[
          <String, dynamic>{
            'stateKey': '0.11|0.22|0.33|0.44',
            'decision': <String, dynamic>{
              'nextDifficulty': 1,
              'source': 'exact_match',
              'actionLabel': 'easy_task',
            },
          },
          <String, dynamic>{
            'stateKey': '0.55|0.66|0.77|0.88',
            'decision': <String, dynamic>{
              'nextDifficulty': 4,
              'source': 'exact_match',
              'actionLabel': 'hard_task',
            },
          },
        ],
      });

      expect(
        loadedPolicy.decisionForKey('0.11|0.22|0.33|0.44')?.actionLabel,
        'easy_task',
      );
      expect(
        loadedPolicy.decisionForKey('0.55|0.66|0.77|0.88')?.nextDifficulty,
        4,
      );
      expect(
        loadedPolicy.decisionForKey('missing'),
        isNull,
      );
    });

    test('non-strict loading preserves validation warnings', () {
      final loader = PolicyLoader(
        config: const RuntimeConfig(
          strictValidation: false,
          allowPartialMetadata: true,
        ),
      );

      final loadedPolicy = loader.loadFromMap(<String, dynamic>{
        'metadata': <String, dynamic>{
          'exportedStateCount': 99,
        },
        'entries': <dynamic>[
          <String, dynamic>{
            'stateKey': '0.10|0.20|0.30|0.40',
            'decision': <String, dynamic>{
              'nextDifficulty': -1,
              'source': '',
            },
          },
        ],
      });

      expect(loadedPolicy.validationResult.warnings, isNotEmpty);
      expect(
        loadedPolicy.validationResult.warnings.any(
              (w) => w.contains('negative nextDifficulty'),
        ),
        isTrue,
      );
    });

    test('python format derives nextDifficulty from before rank + delta', () {
      final loader = PolicyLoader();

      final loadedPolicy = loader.loadFromMap(<String, dynamic>{
        'policy': <String, dynamic>{
          '0.10|0.20|0.30|0.40': <String, dynamic>{
            'action_label': 'hard_task',
            'decision': <String, dynamic>{
              'difficulty_rank_before': 1,
              'difficulty_delta': 2,
            },
          },
        },
      });

      final decision =
      loadedPolicy.decisionForKey('0.10|0.20|0.30|0.40');

      expect(decision, isNotNull);
      expect(decision!.nextDifficulty, 3);
    });

    test('python format throws when nextDifficulty cannot be derived', () {
      final loader = PolicyLoader();

      expect(
            () => loader.loadFromMap(<String, dynamic>{
          'policy': <String, dynamic>{
            '0.10|0.20|0.30|0.40': <String, dynamic>{
              'decision': <String, dynamic>{
                'reason': 'missing ranks',
              },
            },
          },
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });
  });
}