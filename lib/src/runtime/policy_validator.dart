import '../config/runtime_config.dart';
import '../domain/policy/exported_policy.dart';
import '../domain/policy/policy_entry.dart';
import '../domain/policy/policy_metadata.dart';
import '../domain/policy/policy_validation_result.dart';
import '../domain/state/state_dimension_labels.dart';

/// Validates exported adaptive policies for runtime usage.
///
/// This validator focuses on logical and structural validity after parsing,
/// including:
/// - entry presence
/// - state-key consistency
/// - metadata consistency
/// - decision payload sanity
class PolicyValidator {
  /// Creates a policy validator.
  const PolicyValidator({
    this.config = const RuntimeConfig(),
  });

  /// Runtime configuration used during validation.
  final RuntimeConfig config;

  /// Validates a fully parsed [ExportedPolicy].
  PolicyValidationResult validate(ExportedPolicy policy) {
    final errors = <String>[];
    final warnings = <String>[];

    _validateEntries(policy.entries, errors, warnings);
    _validateMetadata(policy.metadata, policy.entries, errors, warnings);
    _validateStateKeyUniqueness(policy.entries, errors);

    final isValid = errors.isEmpty;
    return PolicyValidationResult(
      isValid: isValid,
      errors: List<String>.unmodifiable(errors),
      warnings: List<String>.unmodifiable(warnings),
    );
  }

  /// Validates a raw map by first converting it into an [ExportedPolicy].
  PolicyValidationResult validateMap(
      Map<String, dynamic> map,
      ExportedPolicy Function(Map<String, dynamic>) parser,
      ) {
    final policy = parser(map);
    return validate(policy);
  }

  void _validateEntries(
      List<PolicyEntry> entries,
      List<String> errors,
      List<String> warnings,
      ) {
    if (entries.isEmpty) {
      errors.add('Exported policy must contain at least one policy entry.');
      return;
    }

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];

      if (entry.stateKey.trim().isEmpty) {
        errors.add('Policy entry at index $i has an empty stateKey.');
      }

      if (entry.decision.nextDifficulty < 0) {
        warnings.add(
          'Policy entry at index $i has a negative nextDifficulty: '
              '${entry.decision.nextDifficulty}.',
        );
      }

      if (entry.decision.source.trim().isEmpty) {
        warnings.add(
          'Policy entry at index $i has an empty decision source.',
        );
      }

      if (entry.hasProbabilities) {
        final sum = entry.probabilities.fold<double>(
          0.0,
              (acc, value) => acc + value,
        );

        if (sum <= 0) {
          warnings.add(
            'Policy entry at index $i has non-positive probability sum.',
          );
        }
      }
    }
  }

  void _validateMetadata(
      PolicyMetadata metadata,
      List<PolicyEntry> entries,
      List<String> errors,
      List<String> warnings,
      ) {
    if (!metadata.hasStateOrder) {
      if (!config.allowPartialMetadata) {
        errors.add('Policy metadata is missing stateOrder.');
      } else {
        warnings.add('Policy metadata is missing stateOrder.');
      }
    } else {
      final stateOrder = metadata.stateOrder;

      if (stateOrder.length != 4) {
        errors.add(
          'Policy metadata stateOrder must contain exactly 4 dimensions.',
        );
      }

      for (final label in stateOrder) {
        if (!StateDimensionLabels.isSupported(label) &&
            label != 'eng' &&
            label != 'mot' &&
            label != 'perf') {
          warnings.add(
            'Policy metadata stateOrder contains a non-canonical label: $label.',
          );
        }
      }

      final canonicalOrder = StateDimensionLabels.ordered;
      if (_listEquals(stateOrder, canonicalOrder) == false) {
        warnings.add(
          'Policy metadata stateOrder differs from canonical library order.',
        );
      }
    }

    if (metadata.exportedStateCount != null &&
        metadata.exportedStateCount != entries.length) {
      warnings.add(
        'Policy metadata exportedStateCount '
            '(${metadata.exportedStateCount}) does not match actual entry count '
            '(${entries.length}).',
      );
    }

    if (metadata.actionCount != null && metadata.actionCount! < 0) {
      errors.add('Policy metadata actionCount cannot be negative.');
    }

    if (metadata.stateDecimals != null && metadata.stateDecimals! < 0) {
      errors.add('Policy metadata stateDecimals cannot be negative.');
    }

    if (metadata.exportResolution != null && metadata.exportResolution! <= 0) {
      warnings.add(
        'Policy metadata exportResolution should usually be positive.',
      );
    }
  }

  void _validateStateKeyUniqueness(
      List<PolicyEntry> entries,
      List<String> errors,
      ) {
    final seen = <String>{};

    for (final entry in entries) {
      if (!seen.add(entry.stateKey)) {
        errors.add(
          'Duplicate stateKey detected in exported policy: ${entry.stateKey}',
        );
      }
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}