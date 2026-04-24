import 'dart:convert';

import '../config/runtime_config.dart';
import '../domain/decisions/adaptive_decision.dart';
import '../exceptions/policy_format_exception.dart';
import '../exceptions/policy_validation_exception.dart';
import 'loaded_policy.dart';
import 'policy_export_parser.dart';
import 'policy_validator.dart';

/// Loads exported policies into runtime-ready [LoadedPolicy] objects.
///
/// Responsibilities:
/// - decode JSON strings
/// - delegate structural parsing to [PolicyExportParser]
/// - delegate logical validation to [PolicyValidator]
/// - build runtime-indexed [LoadedPolicy]
class PolicyLoader {
  /// Creates a policy loader.
  PolicyLoader({
    this.config = const RuntimeConfig(),
    PolicyExportParser? parser,
    PolicyValidator? validator,
  })  : parser = parser ?? const PolicyExportParser(),
        validator = validator ?? PolicyValidator(config: config);

  /// Runtime configuration used during loading.
  final RuntimeConfig config;

  /// Parser used to convert raw exported maps into typed domain policies.
  final PolicyExportParser parser;

  /// Validator used after parsing.
  final PolicyValidator validator;

  /// Loads a policy from a JSON string.
  LoadedPolicy loadFromJsonString(String jsonString) {
    final trimmed = jsonString.trim();
    if (trimmed.isEmpty) {
      throw const PolicyFormatException(
        'Policy JSON string cannot be empty.',
      );
    }

    dynamic decoded;
    try {
      decoded = json.decode(trimmed);
    } catch (error) {
      throw PolicyFormatException(
        'Failed to decode policy JSON string.',
        details: error,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw PolicyFormatException(
        'Top-level policy JSON must decode to a Map<String, dynamic>.',
        details: decoded.runtimeType,
      );
    }

    return loadFromMap(decoded);
  }

  /// Loads a policy from a raw map.
  LoadedPolicy loadFromMap(Map<String, dynamic> map) {
    final exportedPolicy = parser.parse(map);
    final validationResult = validator.validate(exportedPolicy);

    if (config.strictValidation && !validationResult.isValid) {
      throw PolicyValidationException(
        'Policy validation failed.',
        errors: validationResult.errors,
        warnings: validationResult.warnings,
        validationResult: validationResult,
      );
    }

    final finalExportedPolicy = exportedPolicy.copyWith(
      validationResult: validationResult,
    );

    final indexedDecisions = <String, AdaptiveDecision>{};
    for (final entry in finalExportedPolicy.entries) {
      indexedDecisions[entry.stateKey] = entry.decision;
    }

    return LoadedPolicy(
      exportedPolicy: finalExportedPolicy,
      indexedDecisions: Map<String, AdaptiveDecision>.unmodifiable(
        indexedDecisions,
      ),
    );
  }
}