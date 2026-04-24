import '../domain/decisions/adaptive_decision.dart';
import '../domain/decisions/adaptive_decision_details.dart';
import '../domain/policy/exported_policy.dart';
import '../domain/policy/policy_entry.dart';
import '../domain/policy/policy_metadata.dart';
import '../domain/policy/policy_validation_result.dart';
import '../exceptions/policy_format_exception.dart';
import 'policy_contract.dart';

/// Parses raw exported policy maps into typed [ExportedPolicy] objects.
///
/// Supported formats:
/// 1. Normalized exported format:
///    - `metadata`
///    - `entries`
///
/// 2. Python-style exported policy map:
///    - `metadata`
///    - `policy`
///
/// This parser is responsible only for structural conversion, not validation.
class PolicyExportParser {
  /// Creates a policy export parser.
  const PolicyExportParser();

  /// Parses a raw exported policy map into an [ExportedPolicy].
  ExportedPolicy parse(Map<String, dynamic> map) {
    final detectedFormat = PolicyContract.detectFormat(map);

    switch (detectedFormat) {
      case PolicyContract.normalizedEntriesFormat:
        return _parseNormalizedEntriesFormat(map);
      case PolicyContract.pythonPolicyMapFormat:
        return _parsePythonPolicyMapFormat(map);
      default:
        throw const PolicyFormatException(
          'Unsupported policy format. Expected either "entries" or "policy" at the top level.',
        );
    }
  }

  ExportedPolicy _parseNormalizedEntriesFormat(Map<String, dynamic> map) {
    return ExportedPolicy.fromMap(map);
  }

  ExportedPolicy _parsePythonPolicyMapFormat(Map<String, dynamic> map) {
    final metadataValue = map[PolicyContract.metadata];
    final policyValue = map[PolicyContract.policy];

    if (metadataValue != null && metadataValue is! Map<String, dynamic>) {
      throw PolicyFormatException(
        'Top-level field "${PolicyContract.metadata}" must be a Map<String, dynamic> when provided.',
        details: metadataValue.runtimeType,
      );
    }

    if (policyValue is! Map<String, dynamic>) {
      throw PolicyFormatException(
        'Top-level field "${PolicyContract.policy}" must be a Map<String, dynamic>.',
        details: policyValue.runtimeType,
      );
    }

    final metadata = metadataValue == null
        ? const PolicyMetadata()
        : PolicyMetadata.fromMap(metadataValue as Map<String, dynamic>);

    final entries = <PolicyEntry>[];

    for (final entry in policyValue.entries) {
      final stateKey = entry.key;
      final rawEntry = entry.value;

      if (rawEntry is! Map<String, dynamic>) {
        throw PolicyFormatException(
          'Each "${PolicyContract.policy}" entry must be a Map<String, dynamic>.',
          details: rawEntry.runtimeType,
        );
      }

      entries.add(
        _parsePythonPolicyEntry(
          stateKey,
          rawEntry,
        ),
      );
    }

    return ExportedPolicy(
      metadata: metadata,
      entries: List<PolicyEntry>.unmodifiable(entries),
      validationResult: PolicyValidationResult.valid(),
    );
  }

  PolicyEntry _parsePythonPolicyEntry(
      String stateKey,
      Map<String, dynamic> rawEntry,
      ) {
    final rawState = rawEntry[PolicyContract.pythonState];
    final rawActionId = rawEntry[PolicyContract.pythonAction];
    final rawActionLabel = rawEntry[PolicyContract.pythonActionLabel];
    final rawDecision = rawEntry[PolicyContract.pythonDecision];
    final rawProbabilities = rawEntry[PolicyContract.pythonProbabilities];
    final rawValueEstimate = rawEntry[PolicyContract.pythonValue];

    if (rawDecision != null && rawDecision is! Map<String, dynamic>) {
      throw PolicyFormatException(
        'Python-style policy entry field "${PolicyContract.pythonDecision}" must be a Map<String, dynamic> when provided.',
        details: rawDecision.runtimeType,
      );
    }

    if (rawState != null && rawState is! Map<String, dynamic>) {
      throw PolicyFormatException(
        'Python-style policy entry field "${PolicyContract.pythonState}" must be a Map<String, dynamic> when provided.',
        details: rawState.runtimeType,
      );
    }

    if (rawActionId != null && rawActionId is! num) {
      throw PolicyFormatException(
        'Python-style policy entry field "${PolicyContract.pythonAction}" must be numeric when provided.',
        details: rawActionId.runtimeType,
      );
    }

    if (rawActionLabel != null && rawActionLabel is! String) {
      throw PolicyFormatException(
        'Python-style policy entry field "${PolicyContract.pythonActionLabel}" must be a String when provided.',
        details: rawActionLabel.runtimeType,
      );
    }

    if (rawValueEstimate != null && rawValueEstimate is! num) {
      throw PolicyFormatException(
        'Python-style policy entry field "${PolicyContract.pythonValue}" must be numeric when provided.',
        details: rawValueEstimate.runtimeType,
      );
    }

    final typedDecisionMap = rawDecision as Map<String, dynamic>?;

    final details = _buildDecisionDetails(typedDecisionMap);

    final decision = _buildAdaptiveDecision(
      rawDecision: typedDecisionMap,
      fallbackActionLabel: rawActionLabel as String?,
      details: details,
    );

    return PolicyEntry(
      stateKey: stateKey,
      decision: decision,
      stateValues: _readDoubleMap(rawState),
      actionId: rawActionId == null ? null : (rawActionId as num).toInt(),
      actionLabel: rawActionLabel,
      probabilities: _readDoubleList(rawProbabilities),
      valueEstimate: rawValueEstimate == null
          ? null
          : (rawValueEstimate as num).toDouble(),
    );
  }

  AdaptiveDecision _buildAdaptiveDecision({
    required Map<String, dynamic>? rawDecision,
    required String? fallbackActionLabel,
    required AdaptiveDecisionDetails details,
  }) {
    final nextDifficulty = _extractNextDifficulty(rawDecision);
    final reason = rawDecision == null
        ? null
        : _readString(rawDecision, PolicyContract.reason);

    return AdaptiveDecision(
      nextDifficulty: nextDifficulty,
      source: 'exact_match',
      reason: reason,
      actionLabel: fallbackActionLabel,
      details: details,
    );
  }

  AdaptiveDecisionDetails _buildDecisionDetails(
      Map<String, dynamic>? rawDecision,
      ) {
    if (rawDecision == null) {
      return const AdaptiveDecisionDetails();
    }

    final stateInterpretation = _readDoubleMap(
      rawDecision[PolicyContract.stateInterpretation],
    );
    final stateFlags = _readBoolMap(
      rawDecision[PolicyContract.stateFlags],
    );

    return AdaptiveDecisionDetails(
      sourceActionId: _readInt(rawDecision, PolicyContract.sourceActionId),
      sourceActionName:
      _readString(rawDecision, PolicyContract.sourceActionName),
      actionGroup: _readString(rawDecision, PolicyContract.actionGroup),
      decisionType: _readString(rawDecision, PolicyContract.decisionType),
      difficultyChange:
      _readString(rawDecision, PolicyContract.difficultyChange),
      difficultyRankBefore:
      _readInt(rawDecision, PolicyContract.difficultyRankBefore),
      difficultyRankAfter:
      _readInt(rawDecision, PolicyContract.difficultyRankAfter),
      difficultyDelta:
      _readInt(rawDecision, PolicyContract.difficultyDelta),
      currentDifficulty:
      _readString(rawDecision, PolicyContract.currentDifficulty),
      nextDifficultyLabel:
      _readString(rawDecision, PolicyContract.nextDifficultyLabel),
      supportStrategy:
      _readString(rawDecision, PolicyContract.supportStrategy),
      pedagogicalEffect:
      _readString(rawDecision, PolicyContract.pedagogicalEffect),
      stateInterpretation: stateInterpretation,
      stateFlags: stateFlags,
    );
  }

  int _extractNextDifficulty(Map<String, dynamic>? rawDecision) {
    if (rawDecision == null) {
      throw const PolicyFormatException(
        'Python-style policy entry is missing a "decision" object.',
      );
    }

    final afterRank = rawDecision[PolicyContract.difficultyRankAfter];
    if (afterRank is num) {
      return afterRank.toInt();
    }

    final delta = rawDecision[PolicyContract.difficultyDelta];
    final beforeRank = rawDecision[PolicyContract.difficultyRankBefore];

    if (delta is num && beforeRank is num) {
      return beforeRank.toInt() + delta.toInt();
    }

    throw const PolicyFormatException(
      'Unable to derive nextDifficulty from Python-style decision payload.',
    );
  }

  String? _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;

    if (value is! String) {
      throw PolicyFormatException(
        'Field "$key" must be a String when provided.',
        details: value.runtimeType,
      );
    }

    return value;
  }

  int? _readInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;

    if (value is! num) {
      throw PolicyFormatException(
        'Field "$key" must be numeric when provided.',
        details: value.runtimeType,
      );
    }

    return value.toInt();
  }

  Map<String, double> _readDoubleMap(dynamic value) {
    if (value == null) return const <String, double>{};

    if (value is! Map) {
      throw PolicyFormatException(
        'Expected a Map for numeric value mapping.',
        details: value.runtimeType,
      );
    }

    final result = <String, double>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! num) {
        throw const PolicyFormatException(
          'Expected a string-to-numeric map.',
        );
      }
      result[entry.key as String] = (entry.value as num).toDouble();
    }

    return Map<String, double>.unmodifiable(result);
  }

  Map<String, bool> _readBoolMap(dynamic value) {
    if (value == null) return const <String, bool>{};

    if (value is! Map) {
      throw PolicyFormatException(
        'Expected a Map for boolean value mapping.',
        details: value.runtimeType,
      );
    }

    final result = <String, bool>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! bool) {
        throw const PolicyFormatException(
          'Expected a string-to-bool map.',
        );
      }
      result[entry.key as String] = entry.value as bool;
    }

    return Map<String, bool>.unmodifiable(result);
  }

  List<double> _readDoubleList(dynamic value) {
    if (value == null) return const <double>[];

    if (value is! List) {
      throw PolicyFormatException(
        'Expected a List for probability values.',
        details: value.runtimeType,
      );
    }

    final result = <double>[];
    for (final item in value) {
      if (item is! num) {
        throw PolicyFormatException(
          'Probability values must be numeric.',
          details: item.runtimeType,
        );
      }
      result.add(item.toDouble());
    }

    return List<double>.unmodifiable(result);
  }
}