import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/runtime/policy_contract.dart';
import 'package:adaptive_gamification/src/runtime/policy_export_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PolicyExportParser', () {
    const parser = PolicyExportParser();

    test('parses normalized entries format correctly', () {
      final exportedPolicy = parser.parse(<String, dynamic>{
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
          'exportedStateCount': 2,
          'actionCount': 6,
        },
        'entries': <dynamic>[
          <String, dynamic>{
            'stateKey': '0.10|0.20|0.30|0.40',
            'decision': <String, dynamic>{
              'nextDifficulty': 1,
              'source': 'exact_match',
              'reason': 'stable',
              'actionLabel': 'easy_task',
            },
            'stateValues': <String, dynamic>{
              'eng': 0.1,
              'mot': 0.2,
              'flow': 0.3,
              'perf': 0.4,
            },
            'actionId': 1,
            'actionLabel': 'easy_task',
            'probabilities': <dynamic>[0.7, 0.2, 0.1],
            'valueEstimate': 0.8,
          },
          <String, dynamic>{
            'stateKey': '0.40|0.50|0.60|0.70',
            'decision': <String, dynamic>{
              'nextDifficulty': 3,
              'source': 'exact_match',
              'reason': 'increase challenge',
              'actionLabel': 'hard_task',
            },
          },
        ],
      });

      expect(exportedPolicy.metadata.formatVersion, '1.0');
      expect(exportedPolicy.metadata.policyType, 'deterministic_lookup_table');
      expect(exportedPolicy.entryCount, 2);
      expect(exportedPolicy.entries.first.stateKey, '0.10|0.20|0.30|0.40');
      expect(exportedPolicy.entries.first.decision.nextDifficulty, 1);
      expect(exportedPolicy.entries.first.actionId, 1);
      expect(exportedPolicy.entries.first.actionLabel, 'easy_task');
      expect(exportedPolicy.entries.first.valueEstimate, 0.8);
      expect(exportedPolicy.validationResult.isValid, isTrue);
    });

    test('parses python policy map format correctly', () {
      final exportedPolicy = parser.parse(<String, dynamic>{
        'metadata': <String, dynamic>{
          'format_version': '2.0',
          'policy_type': 'deterministic_lookup_table',
          'state_order': <dynamic>['eng', 'mot', 'flow', 'perf'],
          'state_decimals': 2,
          'num_exported_states': 1,
          'num_actions': 6,
          'action_names': <String, dynamic>{
            '0': 'rest',
            '1': 'easy_task',
            '2': 'medium_task',
            '3': 'hard_task',
            '4': 'motivation_boost',
            '5': 'flow_task',
          },
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
            'probs': <dynamic>[0.05, 0.1, 0.15, 0.2, 0.45, 0.05],
            'value': 0.91,
            'decision': <String, dynamic>{
              'reason': 'low motivation detected',
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

      expect(exportedPolicy.metadata.formatVersion, '2.0');
      expect(exportedPolicy.metadata.stateDecimals, 2);
      expect(exportedPolicy.metadata.actionCount, 6);
      expect(exportedPolicy.entryCount, 1);

      final entry = exportedPolicy.entries.first;
      expect(entry.stateKey, '0.20|0.30|0.40|0.50');
      expect(entry.actionId, 4);
      expect(entry.actionLabel, 'motivation_boost');
      expect(entry.probabilities.length, 6);
      expect(entry.valueEstimate, 0.91);

      final decision = entry.decision;
      expect(decision.nextDifficulty, 2);
      expect(decision.source, DecisionSource.exactMatch);
      expect(decision.reason, 'low motivation detected');
      expect(decision.actionLabel, 'motivation_boost');
      expect(decision.details, isNotNull);
      expect(decision.details!.sourceActionId, 4);
      expect(decision.details!.supportStrategy, 'encourage_persistence');
      expect(decision.details!.pedagogicalEffect, 'motivational_reinforcement');
      expect(decision.details!.stateFlags['low_motivation'], isTrue);
    });

    test('parses python format and derives nextDifficulty from before + delta', () {
      final exportedPolicy = parser.parse(<String, dynamic>{
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

      expect(exportedPolicy.entryCount, 1);
      expect(exportedPolicy.entries.first.decision.nextDifficulty, 3);
    });

    test('throws when top-level format is unsupported', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'unknown': <String, dynamic>{},
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when python metadata is not a map', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': <String, dynamic>{},
          'metadata': 'bad',
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when python policy is not a map', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': 'bad',
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when python policy entry is not a map', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': <String, dynamic>{
            '0.10|0.20|0.30|0.40': 'bad',
          },
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when python decision field is not a map', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': <String, dynamic>{
            '0.10|0.20|0.30|0.40': <String, dynamic>{
              'decision': 'bad',
            },
          },
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when python state field is not a map', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': <String, dynamic>{
            '0.10|0.20|0.30|0.40': <String, dynamic>{
              'state': 'bad',
              'decision': <String, dynamic>{
                'difficulty_rank_after': 1,
              },
            },
          },
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when python action is not numeric', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': <String, dynamic>{
            '0.10|0.20|0.30|0.40': <String, dynamic>{
              'action': 'bad',
              'decision': <String, dynamic>{
                'difficulty_rank_after': 1,
              },
            },
          },
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when python action_label is not string', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': <String, dynamic>{
            '0.10|0.20|0.30|0.40': <String, dynamic>{
              'action_label': 123,
              'decision': <String, dynamic>{
                'difficulty_rank_after': 1,
              },
            },
          },
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when python value is not numeric', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': <String, dynamic>{
            '0.10|0.20|0.30|0.40': <String, dynamic>{
              'value': 'bad',
              'decision': <String, dynamic>{
                'difficulty_rank_after': 1,
              },
            },
          },
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when nextDifficulty cannot be derived', () {
      expect(
            () => parser.parse(<String, dynamic>{
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

    test('throws when probability list contains non-numeric value', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': <String, dynamic>{
            '0.10|0.20|0.30|0.40': <String, dynamic>{
              'probs': <dynamic>[0.1, 'bad'],
              'decision': <String, dynamic>{
                'difficulty_rank_after': 1,
              },
            },
          },
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when state_interpretation is invalid', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': <String, dynamic>{
            '0.10|0.20|0.30|0.40': <String, dynamic>{
              'decision': <String, dynamic>{
                'difficulty_rank_after': 1,
                'state_interpretation': <String, dynamic>{
                  'eng': 'bad',
                },
              },
            },
          },
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('throws when state_flags is invalid', () {
      expect(
            () => parser.parse(<String, dynamic>{
          'policy': <String, dynamic>{
            '0.10|0.20|0.30|0.40': <String, dynamic>{
              'decision': <String, dynamic>{
                'difficulty_rank_after': 1,
                'state_flags': <String, dynamic>{
                  'low_engagement': 'bad',
                },
              },
            },
          },
        }),
        throwsA(isA<PolicyFormatException>()),
      );
    });

    test('PolicyContract detects formats correctly', () {
      expect(
        PolicyContract.detectFormat(<String, dynamic>{
          'entries': <dynamic>[],
        }),
        PolicyContract.normalizedEntriesFormat,
      );

      expect(
        PolicyContract.detectFormat(<String, dynamic>{
          'policy': <String, dynamic>{},
        }),
        PolicyContract.pythonPolicyMapFormat,
      );

      expect(
        PolicyContract.detectFormat(<String, dynamic>{
          'somethingElse': true,
        }),
        isNull,
      );
    });
  });
}