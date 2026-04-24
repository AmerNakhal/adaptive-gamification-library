import '../decisions/adaptive_decision.dart';

/// Represents a single typed entry in an exported adaptive policy.
///
/// A policy entry typically corresponds to one deterministic state-key lookup
/// result. In richer exported formats, it may also carry additional metadata
/// such as:
/// - raw state values
/// - action identifier
/// - action label
/// - probability distribution
/// - value estimate
class PolicyEntry {
  /// Deterministic state key used for runtime lookup.
  final String stateKey;

  /// The core adaptive decision associated with this state key.
  final AdaptiveDecision decision;

  /// Optional raw state values associated with this policy entry.
  ///
  /// Example:
  /// `{ "eng": 0.5, "mot": 0.75, "flow": 0.25, "perf": 0.5 }`
  final Map<String, double> stateValues;

  /// Optional source action identifier.
  final int? actionId;

  /// Optional source action label.
  final String? actionLabel;

  /// Optional action probability distribution.
  final List<double> probabilities;

  /// Optional value estimate associated with this entry.
  final double? valueEstimate;

  /// Creates a typed policy entry.
  const PolicyEntry({
    required this.stateKey,
    required this.decision,
    this.stateValues = const <String, double>{},
    this.actionId,
    this.actionLabel,
    this.probabilities = const <double>[],
    this.valueEstimate,
  });

  /// Creates a policy entry from a generic map.
  ///
  /// Expected keys:
  /// - `stateKey` (required)
  /// - `decision` (required)
  /// - `stateValues` (optional)
  /// - `actionId` (optional)
  /// - `actionLabel` (optional)
  /// - `probabilities` (optional)
  /// - `valueEstimate` (optional)
  factory PolicyEntry.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('stateKey')) {
      throw const FormatException(
        'Missing required PolicyEntry field: stateKey',
      );
    }

    if (!map.containsKey('decision')) {
      throw const FormatException(
        'Missing required PolicyEntry field: decision',
      );
    }

    final stateKeyValue = map['stateKey'];
    final decisionValue = map['decision'];
    final stateValuesValue = map['stateValues'];
    final actionIdValue = map['actionId'];
    final actionLabelValue = map['actionLabel'];
    final probabilitiesValue = map['probabilities'];
    final valueEstimateValue = map['valueEstimate'];

    if (stateKeyValue is! String) {
      throw FormatException(
        'PolicyEntry field "stateKey" must be a String, '
            'but got ${stateKeyValue.runtimeType}.',
      );
    }

    if (decisionValue is! Map<String, dynamic>) {
      throw FormatException(
        'PolicyEntry field "decision" must be a Map<String, dynamic>, '
            'but got ${decisionValue.runtimeType}.',
      );
    }

    if (actionIdValue != null && actionIdValue is! num) {
      throw FormatException(
        'PolicyEntry field "actionId" must be numeric when provided, '
            'but got ${actionIdValue.runtimeType}.',
      );
    }

    if (actionLabelValue != null && actionLabelValue is! String) {
      throw FormatException(
        'PolicyEntry field "actionLabel" must be a String when provided, '
            'but got ${actionLabelValue.runtimeType}.',
      );
    }

    if (valueEstimateValue != null && valueEstimateValue is! num) {
      throw FormatException(
        'PolicyEntry field "valueEstimate" must be numeric when provided, '
            'but got ${valueEstimateValue.runtimeType}.',
      );
    }

    return PolicyEntry(
      stateKey: stateKeyValue,
      decision: AdaptiveDecision.fromMap(decisionValue),
      stateValues: _readDoubleMap(
        stateValuesValue,
        fieldName: 'stateValues',
      ),
      actionId: actionIdValue == null ? null : (actionIdValue as num).toInt(),
      actionLabel: actionLabelValue as String?,
      probabilities: _readDoubleList(
        probabilitiesValue,
        fieldName: 'probabilities',
      ),
      valueEstimate: valueEstimateValue == null
          ? null
          : (valueEstimateValue as num).toDouble(),
    );
  }

  /// Returns this entry as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'stateKey': stateKey,
      'decision': decision.toMap(),
      'stateValues': stateValues,
      'actionId': actionId,
      'actionLabel': actionLabel,
      'probabilities': probabilities,
      'valueEstimate': valueEstimate,
    };
  }

  /// Returns whether raw state values are attached.
  bool get hasStateValues => stateValues.isNotEmpty;

  /// Returns whether action probabilities are attached.
  bool get hasProbabilities => probabilities.isNotEmpty;

  /// Returns whether a value estimate is attached.
  bool get hasValueEstimate => valueEstimate != null;

  /// Returns a copy of this entry with selected values replaced.
  PolicyEntry copyWith({
    String? stateKey,
    AdaptiveDecision? decision,
    Map<String, double>? stateValues,
    int? actionId,
    String? actionLabel,
    List<double>? probabilities,
    double? valueEstimate,
  }) {
    return PolicyEntry(
      stateKey: stateKey ?? this.stateKey,
      decision: decision ?? this.decision,
      stateValues: stateValues ?? this.stateValues,
      actionId: actionId ?? this.actionId,
      actionLabel: actionLabel ?? this.actionLabel,
      probabilities: probabilities ?? this.probabilities,
      valueEstimate: valueEstimate ?? this.valueEstimate,
    );
  }

  @override
  String toString() {
    return 'PolicyEntry('
        'stateKey: $stateKey, '
        'decision: $decision, '
        'stateValues: $stateValues, '
        'actionId: $actionId, '
        'actionLabel: $actionLabel, '
        'probabilities: $probabilities, '
        'valueEstimate: $valueEstimate'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PolicyEntry &&
            other.stateKey == stateKey &&
            other.decision == decision &&
            _doubleMapEquals(other.stateValues, stateValues) &&
            other.actionId == actionId &&
            other.actionLabel == actionLabel &&
            _doubleListEquals(other.probabilities, probabilities) &&
            other.valueEstimate == valueEstimate);
  }

  @override
  int get hashCode {
    return Object.hash(
      stateKey,
      decision,
      Object.hashAll(
        stateValues.entries.map(
              (entry) => Object.hash(entry.key, entry.value),
        ),
      ),
      actionId,
      actionLabel,
      Object.hashAll(probabilities),
      valueEstimate,
    );
  }

  static Map<String, double> _readDoubleMap(
      dynamic value, {
        required String fieldName,
      }) {
    if (value == null) return const <String, double>{};

    if (value is! Map) {
      throw FormatException(
        'PolicyEntry field "$fieldName" must be a Map when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String, double>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! num) {
        throw FormatException(
          'PolicyEntry field "$fieldName" must map String keys to numeric values.',
        );
      }
      result[entry.key as String] = (entry.value as num).toDouble();
    }

    return Map<String, double>.unmodifiable(result);
  }

  static List<double> _readDoubleList(
      dynamic value, {
        required String fieldName,
      }) {
    if (value == null) return const <double>[];

    if (value is! List) {
      throw FormatException(
        'PolicyEntry field "$fieldName" must be a List when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <double>[];
    for (final item in value) {
      if (item is! num) {
        throw FormatException(
          'PolicyEntry field "$fieldName" must contain only numeric values, '
              'but found ${item.runtimeType}.',
        );
      }
      result.add(item.toDouble());
    }

    return List<double>.unmodifiable(result);
  }

  static bool _doubleMapEquals(Map<String, double> a, Map<String, double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  static bool _doubleListEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}