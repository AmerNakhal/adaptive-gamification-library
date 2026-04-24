import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PolicyValidator', () {
    const validator = PolicyValidator();

    ExportedPolicy buildValidPolicy({
      PolicyMetadata metadata = const PolicyMetadata(
        formatVersion: '1.0',
        policyType: 'deterministic_lookup_table',
        stateOrder: <String>[
          'engagement',
          'motivation',
          'flow',
          'performance',
        ],
        stateDecimals: 2,
        exportedStateCount: 2,
        actionCount: 6,
      ),
      List<PolicyEntry>? entries,
    }) {
      return ExportedPolicy(
        metadata: metadata,
        entries: entries ??
            const <PolicyEntry>[
              PolicyEntry(
                stateKey: '0.10|0.20|0.30|0.40',
                decision: AdaptiveDecision(
                  nextDifficulty: 1,
                  source: 'exact_match',
                  reason: 'stable',
                  actionLabel: 'easy_task',
                ),
              ),
              PolicyEntry(
                stateKey: '0.40|0.50|0.60|0.70',
                decision: AdaptiveDecision(
                  nextDifficulty: 3,
                  source: 'exact_match',
                  reason: 'increase challenge',
                  actionLabel: 'hard_task',
                ),
              ),
            ],
        validationResult: PolicyValidationResult.valid(),
      );
    }

    test('validate returns valid result for well-formed policy', () {
      final policy = buildValidPolicy();

      final result = validator.validate(policy);

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
    });

    test('validate returns error for empty entries', () {
      final policy = buildValidPolicy(
        entries: const <PolicyEntry>[],
      );

      final result = validator.validate(policy);

      expect(result.isValid, isFalse);
      expect(result.errors, isNotEmpty);
      expect(
        result.errors.first,
        contains('at least one policy entry'),
      );
    });

    test('validate returns error for empty stateKey', () {
      final policy = buildValidPolicy(
        entries: const <PolicyEntry>[
          PolicyEntry(
            stateKey: '',
            decision: AdaptiveDecision(
              nextDifficulty: 1,
              source: 'exact_match',
            ),
          ),
        ],
      );

      final result = validator.validate(policy);

      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.contains('empty stateKey')),
        isTrue,
      );
    });

    test('validate returns warning for negative nextDifficulty', () {
      final policy = buildValidPolicy(
        entries: const <PolicyEntry>[
          PolicyEntry(
            stateKey: '0.10|0.20|0.30|0.40',
            decision: AdaptiveDecision(
              nextDifficulty: -1,
              source: 'exact_match',
            ),
          ),
        ],
      );

      final result = validator.validate(policy);

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(
        result.warnings.any((w) => w.contains('negative nextDifficulty')),
        isTrue,
      );
    });

    test('validate returns warning for empty decision source', () {
      final policy = buildValidPolicy(
        entries: const <PolicyEntry>[
          PolicyEntry(
            stateKey: '0.10|0.20|0.30|0.40',
            decision: AdaptiveDecision(
              nextDifficulty: 1,
              source: '',
            ),
          ),
        ],
      );

      final result = validator.validate(policy);

      expect(result.isValid, isTrue);
      expect(
        result.warnings.any((w) => w.contains('empty decision source')),
        isTrue,
      );
    });

    test('validate returns warning for non-positive probability sum', () {
      final policy = buildValidPolicy(
        entries: const <PolicyEntry>[
          PolicyEntry(
            stateKey: '0.10|0.20|0.30|0.40',
            decision: AdaptiveDecision(
              nextDifficulty: 1,
              source: 'exact_match',
            ),
            probabilities: <double>[0.0, 0.0, 0.0],
          ),
        ],
      );

      final result = validator.validate(policy);

      expect(result.isValid, isTrue);
      expect(
        result.warnings.any((w) => w.contains('non-positive probability sum')),
        isTrue,
      );
    });

    test('validate returns error for duplicate state keys', () {
      final policy = buildValidPolicy(
        entries: const <PolicyEntry>[
          PolicyEntry(
            stateKey: '0.10|0.20|0.30|0.40',
            decision: AdaptiveDecision(
              nextDifficulty: 1,
              source: 'exact_match',
            ),
          ),
          PolicyEntry(
            stateKey: '0.10|0.20|0.30|0.40',
            decision: AdaptiveDecision(
              nextDifficulty: 2,
              source: 'exact_match',
            ),
          ),
        ],
      );

      final result = validator.validate(policy);

      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.contains('Duplicate stateKey')),
        isTrue,
      );
    });

    test('validate returns warning when metadata is missing stateOrder and partial metadata is allowed', () {
      const validator = PolicyValidator(
        config: RuntimeConfig(
          allowPartialMetadata: true,
        ),
      );

      final policy = buildValidPolicy(
        metadata: const PolicyMetadata(
          formatVersion: '1.0',
          policyType: 'deterministic_lookup_table',
        ),
      );

      final result = validator.validate(policy);

      expect(result.isValid, isTrue);
      expect(
        result.warnings.any((w) => w.contains('missing stateOrder')),
        isTrue,
      );
    });

    test('validate returns error when metadata is missing stateOrder and partial metadata is not allowed', () {
      const validator = PolicyValidator(
        config: RuntimeConfig(
          allowPartialMetadata: false,
        ),
      );

      final policy = buildValidPolicy(
        metadata: const PolicyMetadata(
          formatVersion: '1.0',
          policyType: 'deterministic_lookup_table',
        ),
      );

      final result = validator.validate(policy);

      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.contains('missing stateOrder')),
        isTrue,
      );
    });

    test('validate returns error when stateOrder length is not 4', () {
      final policy = buildValidPolicy(
        metadata: const PolicyMetadata(
          stateOrder: <String>['engagement', 'motivation'],
        ),
      );

      final result = validator.validate(policy);

      expect(result.isValid, isFalse);
      expect(
        result.errors.any(
              (e) => e.contains('must contain exactly 4 dimensions'),
        ),
        isTrue,
      );
    });

    test('validate returns warning for non-canonical stateOrder label', () {
      final policy = buildValidPolicy(
        metadata: const PolicyMetadata(
          stateOrder: <String>[
            'engagement',
            'motivation',
            'weird_label',
            'performance',
          ],
        ),
      );

      final result = validator.validate(policy);

      expect(result.isValid, isTrue);
      expect(
        result.warnings.any(
              (w) => w.contains('non-canonical label'),
        ),
        isTrue,
      );
    });

    test('validate returns warning when stateOrder differs from canonical order', () {
      final policy = buildValidPolicy(
        metadata: const PolicyMetadata(
          stateOrder: <String>[
            'motivation',
            'engagement',
            'flow',
            'performance',
          ],
        ),
      );

      final result = validator.validate(policy);

      expect(result.isValid, isTrue);
      expect(
        result.warnings.any(
              (w) => w.contains('differs from canonical library order'),
        ),
        isTrue,
      );
    });

    test('validate accepts short aliases eng mot flow perf in stateOrder', () {
      final policy = buildValidPolicy(
        metadata: const PolicyMetadata(
          stateOrder: <String>[
            'eng',
            'mot',
            'flow',
            'perf',
          ],
        ),
      );

      final result = validator.validate(policy);

      expect(result.isValid, isTrue);
      expect(
        result.warnings.any((w) => w.contains('non-canonical label')),
        isFalse,
      );
    });

    test('validate returns warning when exportedStateCount mismatches actual entry count', () {
      final policy = buildValidPolicy(
        metadata: const PolicyMetadata(
          stateOrder: <String>[
            'engagement',
            'motivation',
            'flow',
            'performance',
          ],
          exportedStateCount: 99,
        ),
      );

      final result = validator.validate(policy);

      expect(result.isValid, isTrue);
      expect(
        result.warnings.any(
              (w) => w.contains('does not match actual entry count'),
        ),
        isTrue,
      );
    });

    test('validate returns error when actionCount is negative', () {
      final policy = buildValidPolicy(
        metadata: const PolicyMetadata(
          stateOrder: <String>[
            'engagement',
            'motivation',
            'flow',
            'performance',
          ],
          actionCount: -1,
        ),
      );

      final result = validator.validate(policy);

      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.contains('actionCount cannot be negative')),
        isTrue,
      );
    });

    test('validate returns error when stateDecimals is negative', () {
      final policy = buildValidPolicy(
        metadata: const PolicyMetadata(
          stateOrder: <String>[
            'engagement',
            'motivation',
            'flow',
            'performance',
          ],
          stateDecimals: -2,
        ),
      );

      final result = validator.validate(policy);

      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.contains('stateDecimals cannot be negative')),
        isTrue,
      );
    });

    test('validate returns warning when exportResolution is non-positive', () {
      final policy = buildValidPolicy(
        metadata: const PolicyMetadata(
          stateOrder: <String>[
            'engagement',
            'motivation',
            'flow',
            'performance',
          ],
          exportResolution: 0.0,
        ),
      );

      final result = validator.validate(policy);

      expect(result.isValid, isTrue);
      expect(
        result.warnings.any(
              (w) => w.contains('exportResolution should usually be positive'),
        ),
        isTrue,
      );
    });

    test('validateMap validates via parser callback', () {
      final raw = <String, dynamic>{
        'entries': <dynamic>[
          <String, dynamic>{
            'stateKey': '0.10|0.20|0.30|0.40',
            'decision': <String, dynamic>{
              'nextDifficulty': 1,
              'source': 'exact_match',
            },
          },
        ],
      };

      final result = validator.validateMap(
        raw,
            (map) => ExportedPolicy.fromMap(map),
      );

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });
  });
}