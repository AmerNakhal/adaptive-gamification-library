/// Represents metadata associated with an exported adaptive policy.
///
/// This metadata describes how the policy was exported and how it should be
/// interpreted by the runtime library.
class PolicyMetadata {
  /// Export format version.
  final String? formatVersion;

  /// Policy type label.
  ///
  /// Example:
  /// - `deterministic_lookup_table`
  final String? policyType;

  /// Export mode label.
  ///
  /// Example:
  /// - `deterministic_policy_lookup_export`
  final String? exportMode;

  /// Ordered list of state dimensions used in the exported policy.
  final List<String> stateOrder;

  /// Optional human-readable state-key format description.
  ///
  /// Example:
  /// - `eng=0.00|mot=0.00|flow=0.00|perf=0.00`
  final String? stateKeyFormat;

  /// Number of decimal places used in state-key formatting.
  final int? stateDecimals;

  /// Optional export resolution used during policy discretization.
  final double? exportResolution;

  /// Number of state dimensions.
  final int? stateDimensionCount;

  /// Number of exported states.
  final int? exportedStateCount;

  /// Number of supported actions.
  final int? actionCount;

  /// Mapping of action identifiers to human-readable action names.
  final Map<String, String> actionNames;

  /// Optional action-selection description.
  final String? actionSelection;

  /// Optional decision-mapping description.
  final String? decisionMapping;

  /// Optional source label or exporter identifier.
  final String? source;

  /// Optional free-form description.
  final String? description;

  /// Optional exporter notes.
  final String? notes;

  /// Optional export timestamp.
  final String? exportedAt;

  /// Creates policy metadata.
  const PolicyMetadata({
    this.formatVersion,
    this.policyType,
    this.exportMode,
    this.stateOrder = const <String>[],
    this.stateKeyFormat,
    this.stateDecimals,
    this.exportResolution,
    this.stateDimensionCount,
    this.exportedStateCount,
    this.actionCount,
    this.actionNames = const <String, String>{},
    this.actionSelection,
    this.decisionMapping,
    this.source,
    this.description,
    this.notes,
    this.exportedAt,
  });

  /// Creates policy metadata from a generic map.
  factory PolicyMetadata.fromMap(Map<String, dynamic> map) {
    final formatVersionValue = map['formatVersion'] ?? map['format_version'];
    final policyTypeValue = map['policyType'] ?? map['policy_type'];
    final exportModeValue = map['exportMode'] ?? map['export_mode'];
    final stateOrderValue = map['stateOrder'] ?? map['state_order'];
    final stateKeyFormatValue =
        map['stateKeyFormat'] ?? map['state_key_format'];
    final stateDecimalsValue = map['stateDecimals'] ?? map['state_decimals'];
    final exportResolutionValue =
        map['exportResolution'] ?? map['export_resolution'];
    final stateDimensionCountValue =
        map['stateDimensionCount'] ?? map['state_dim'];
    final exportedStateCountValue =
        map['exportedStateCount'] ?? map['num_exported_states'];
    final actionCountValue = map['actionCount'] ?? map['num_actions'];
    final actionNamesValue = map['actionNames'] ?? map['action_names'];
    final actionSelectionValue =
        map['actionSelection'] ?? map['action_selection'];
    final decisionMappingValue =
        map['decisionMapping'] ?? map['decision_mapping'];
    final sourceValue = map['source'];
    final descriptionValue = map['description'];
    final notesValue = map['notes'];
    final exportedAtValue = map['exportedAt'] ?? map['exported_at'];

    if (formatVersionValue != null && formatVersionValue is! String) {
      throw FormatException(
        'PolicyMetadata field "formatVersion" must be a String when provided, '
            'but got ${formatVersionValue.runtimeType}.',
      );
    }

    if (policyTypeValue != null && policyTypeValue is! String) {
      throw FormatException(
        'PolicyMetadata field "policyType" must be a String when provided, '
            'but got ${policyTypeValue.runtimeType}.',
      );
    }

    if (exportModeValue != null && exportModeValue is! String) {
      throw FormatException(
        'PolicyMetadata field "exportMode" must be a String when provided, '
            'but got ${exportModeValue.runtimeType}.',
      );
    }

    if (stateKeyFormatValue != null && stateKeyFormatValue is! String) {
      throw FormatException(
        'PolicyMetadata field "stateKeyFormat" must be a String when provided, '
            'but got ${stateKeyFormatValue.runtimeType}.',
      );
    }

    if (stateDecimalsValue != null && stateDecimalsValue is! num) {
      throw FormatException(
        'PolicyMetadata field "stateDecimals" must be numeric when provided, '
            'but got ${stateDecimalsValue.runtimeType}.',
      );
    }

    if (exportResolutionValue != null && exportResolutionValue is! num) {
      throw FormatException(
        'PolicyMetadata field "exportResolution" must be numeric when provided, '
            'but got ${exportResolutionValue.runtimeType}.',
      );
    }

    if (stateDimensionCountValue != null && stateDimensionCountValue is! num) {
      throw FormatException(
        'PolicyMetadata field "stateDimensionCount" must be numeric when provided, '
            'but got ${stateDimensionCountValue.runtimeType}.',
      );
    }

    if (exportedStateCountValue != null && exportedStateCountValue is! num) {
      throw FormatException(
        'PolicyMetadata field "exportedStateCount" must be numeric when provided, '
            'but got ${exportedStateCountValue.runtimeType}.',
      );
    }

    if (actionCountValue != null && actionCountValue is! num) {
      throw FormatException(
        'PolicyMetadata field "actionCount" must be numeric when provided, '
            'but got ${actionCountValue.runtimeType}.',
      );
    }

    if (actionSelectionValue != null && actionSelectionValue is! String) {
      throw FormatException(
        'PolicyMetadata field "actionSelection" must be a String when provided, '
            'but got ${actionSelectionValue.runtimeType}.',
      );
    }

    if (decisionMappingValue != null && decisionMappingValue is! String) {
      throw FormatException(
        'PolicyMetadata field "decisionMapping" must be a String when provided, '
            'but got ${decisionMappingValue.runtimeType}.',
      );
    }

    if (sourceValue != null && sourceValue is! String) {
      throw FormatException(
        'PolicyMetadata field "source" must be a String when provided, '
            'but got ${sourceValue.runtimeType}.',
      );
    }

    if (descriptionValue != null && descriptionValue is! String) {
      throw FormatException(
        'PolicyMetadata field "description" must be a String when provided, '
            'but got ${descriptionValue.runtimeType}.',
      );
    }

    if (notesValue != null && notesValue is! String) {
      throw FormatException(
        'PolicyMetadata field "notes" must be a String when provided, '
            'but got ${notesValue.runtimeType}.',
      );
    }

    if (exportedAtValue != null && exportedAtValue is! String) {
      throw FormatException(
        'PolicyMetadata field "exportedAt" must be a String when provided, '
            'but got ${exportedAtValue.runtimeType}.',
      );
    }

    return PolicyMetadata(
      formatVersion: formatVersionValue as String?,
      policyType: policyTypeValue as String?,
      exportMode: exportModeValue as String?,
      stateOrder: _readStringList(
        stateOrderValue,
        fieldName: 'stateOrder',
      ),
      stateKeyFormat: stateKeyFormatValue as String?,
      stateDecimals: stateDecimalsValue == null
          ? null
          : (stateDecimalsValue as num).toInt(),
      exportResolution: exportResolutionValue == null
          ? null
          : (exportResolutionValue as num).toDouble(),
      stateDimensionCount: stateDimensionCountValue == null
          ? null
          : (stateDimensionCountValue as num).toInt(),
      exportedStateCount: exportedStateCountValue == null
          ? null
          : (exportedStateCountValue as num).toInt(),
      actionCount: actionCountValue == null
          ? null
          : (actionCountValue as num).toInt(),
      actionNames: _readStringMap(
        actionNamesValue,
        fieldName: 'actionNames',
      ),
      actionSelection: actionSelectionValue as String?,
      decisionMapping: decisionMappingValue as String?,
      source: sourceValue as String?,
      description: descriptionValue as String?,
      notes: notesValue as String?,
      exportedAt: exportedAtValue as String?,
    );
  }

  /// Returns this metadata as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'formatVersion': formatVersion,
      'policyType': policyType,
      'exportMode': exportMode,
      'stateOrder': stateOrder,
      'stateKeyFormat': stateKeyFormat,
      'stateDecimals': stateDecimals,
      'exportResolution': exportResolution,
      'stateDimensionCount': stateDimensionCount,
      'exportedStateCount': exportedStateCount,
      'actionCount': actionCount,
      'actionNames': actionNames,
      'actionSelection': actionSelection,
      'decisionMapping': decisionMapping,
      'source': source,
      'description': description,
      'notes': notes,
      'exportedAt': exportedAt,
    };
  }

  /// Returns whether state-order information is available.
  bool get hasStateOrder => stateOrder.isNotEmpty;

  /// Returns whether action-name information is available.
  bool get hasActionNames => actionNames.isNotEmpty;

  /// Returns whether export resolution is available.
  bool get hasExportResolution => exportResolution != null;

  /// Returns a copy of this metadata with selected values replaced.
  PolicyMetadata copyWith({
    String? formatVersion,
    String? policyType,
    String? exportMode,
    List<String>? stateOrder,
    String? stateKeyFormat,
    int? stateDecimals,
    double? exportResolution,
    int? stateDimensionCount,
    int? exportedStateCount,
    int? actionCount,
    Map<String, String>? actionNames,
    String? actionSelection,
    String? decisionMapping,
    String? source,
    String? description,
    String? notes,
    String? exportedAt,
  }) {
    return PolicyMetadata(
      formatVersion: formatVersion ?? this.formatVersion,
      policyType: policyType ?? this.policyType,
      exportMode: exportMode ?? this.exportMode,
      stateOrder: stateOrder ?? this.stateOrder,
      stateKeyFormat: stateKeyFormat ?? this.stateKeyFormat,
      stateDecimals: stateDecimals ?? this.stateDecimals,
      exportResolution: exportResolution ?? this.exportResolution,
      stateDimensionCount: stateDimensionCount ?? this.stateDimensionCount,
      exportedStateCount: exportedStateCount ?? this.exportedStateCount,
      actionCount: actionCount ?? this.actionCount,
      actionNames: actionNames ?? this.actionNames,
      actionSelection: actionSelection ?? this.actionSelection,
      decisionMapping: decisionMapping ?? this.decisionMapping,
      source: source ?? this.source,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      exportedAt: exportedAt ?? this.exportedAt,
    );
  }

  @override
  String toString() {
    return 'PolicyMetadata('
        'formatVersion: $formatVersion, '
        'policyType: $policyType, '
        'exportMode: $exportMode, '
        'stateOrder: $stateOrder, '
        'stateKeyFormat: $stateKeyFormat, '
        'stateDecimals: $stateDecimals, '
        'exportResolution: $exportResolution, '
        'stateDimensionCount: $stateDimensionCount, '
        'exportedStateCount: $exportedStateCount, '
        'actionCount: $actionCount, '
        'actionNames: $actionNames, '
        'actionSelection: $actionSelection, '
        'decisionMapping: $decisionMapping, '
        'source: $source, '
        'description: $description, '
        'notes: $notes, '
        'exportedAt: $exportedAt'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PolicyMetadata &&
            other.formatVersion == formatVersion &&
            other.policyType == policyType &&
            other.exportMode == exportMode &&
            _listEquals(other.stateOrder, stateOrder) &&
            other.stateKeyFormat == stateKeyFormat &&
            other.stateDecimals == stateDecimals &&
            other.exportResolution == exportResolution &&
            other.stateDimensionCount == stateDimensionCount &&
            other.exportedStateCount == exportedStateCount &&
            other.actionCount == actionCount &&
            _mapEquals(other.actionNames, actionNames) &&
            other.actionSelection == actionSelection &&
            other.decisionMapping == decisionMapping &&
            other.source == source &&
            other.description == description &&
            other.notes == notes &&
            other.exportedAt == exportedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      formatVersion,
      policyType,
      exportMode,
      Object.hashAll(stateOrder),
      stateKeyFormat,
      stateDecimals,
      exportResolution,
      stateDimensionCount,
      exportedStateCount,
      actionCount,
      Object.hashAll(
        actionNames.entries.map(
              (entry) => Object.hash(entry.key, entry.value),
        ),
      ),
      actionSelection,
      decisionMapping,
      source,
      description,
      notes,
      exportedAt,
    );
  }

  static List<String> _readStringList(
      dynamic value, {
        required String fieldName,
      }) {
    if (value == null) return const <String>[];

    if (value is! List) {
      throw FormatException(
        'PolicyMetadata field "$fieldName" must be a List when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'PolicyMetadata field "$fieldName" must contain only String values, '
              'but found ${item.runtimeType}.',
        );
      }
      result.add(item);
    }

    return List<String>.unmodifiable(result);
  }

  static Map<String, String> _readStringMap(
      dynamic value, {
        required String fieldName,
      }) {
    if (value == null) return const <String, String>{};

    if (value is! Map) {
      throw FormatException(
        'PolicyMetadata field "$fieldName" must be a Map when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String, String>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! String) {
        throw FormatException(
          'PolicyMetadata field "$fieldName" must map String keys to String values.',
        );
      }
      result[entry.key as String] = entry.value as String;
    }

    return Map<String, String>.unmodifiable(result);
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}