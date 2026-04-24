import '../state/adaptive_state.dart';
import 'decision_source.dart';

/// Represents the execution context in which an adaptive decision was produced.
///
/// This model captures the runtime information surrounding decision generation,
/// including:
/// - the input state
/// - the normalized state actually used
/// - the generated deterministic state key
/// - the decision source
/// - optional fallback information
/// - optional runtime warnings
class DecisionContext {
  /// The original input state provided to the library.
  final AdaptiveState inputState;

  /// The normalized or processed state actually used during execution.
  final AdaptiveState normalizedState;

  /// The deterministic state key generated from the normalized state.
  final String generatedStateKey;

  /// Canonical decision source label.
  ///
  /// See [DecisionSource].
  final String source;

  /// Optional fallback reason when fallback was used.
  final String? fallbackReason;

  /// Optional session identifier associated with the decision context.
  final String? sessionId;

  /// Optional interaction identifier associated with the decision context.
  final String? interactionId;

  /// Optional non-fatal warnings collected during execution.
  final List<String> warnings;

  /// Creates a decision context.
  const DecisionContext({
    required this.inputState,
    required this.normalizedState,
    required this.generatedStateKey,
    required this.source,
    this.fallbackReason,
    this.sessionId,
    this.interactionId,
    this.warnings = const <String>[],
  });

  /// Creates a decision context from a generic map.
  ///
  /// Expected keys:
  /// - `inputState` (required)
  /// - `normalizedState` (required)
  /// - `generatedStateKey` (required)
  /// - `source` (optional, defaults to `exact_match`)
  /// - `fallbackReason` (optional)
  /// - `sessionId` (optional)
  /// - `interactionId` (optional)
  /// - `warnings` (optional)
  factory DecisionContext.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('inputState')) {
      throw const FormatException(
        'Missing required DecisionContext field: inputState',
      );
    }

    if (!map.containsKey('normalizedState')) {
      throw const FormatException(
        'Missing required DecisionContext field: normalizedState',
      );
    }

    if (!map.containsKey('generatedStateKey')) {
      throw const FormatException(
        'Missing required DecisionContext field: generatedStateKey',
      );
    }

    final inputStateValue = map['inputState'];
    final normalizedStateValue = map['normalizedState'];
    final generatedStateKeyValue = map['generatedStateKey'];
    final sourceValue = map['source'];
    final fallbackReasonValue = map['fallbackReason'];
    final sessionIdValue = map['sessionId'];
    final interactionIdValue = map['interactionId'];
    final warningsValue = map['warnings'];

    if (inputStateValue is! Map<String, dynamic>) {
      throw FormatException(
        'DecisionContext field "inputState" must be a Map<String, dynamic>, '
            'but got ${inputStateValue.runtimeType}.',
      );
    }

    if (normalizedStateValue is! Map<String, dynamic>) {
      throw FormatException(
        'DecisionContext field "normalizedState" must be a Map<String, dynamic>, '
            'but got ${normalizedStateValue.runtimeType}.',
      );
    }

    if (generatedStateKeyValue is! String) {
      throw FormatException(
        'DecisionContext field "generatedStateKey" must be a String, '
            'but got ${generatedStateKeyValue.runtimeType}.',
      );
    }

    if (sourceValue != null && sourceValue is! String) {
      throw FormatException(
        'DecisionContext field "source" must be a String when provided, '
            'but got ${sourceValue.runtimeType}.',
      );
    }

    if (fallbackReasonValue != null && fallbackReasonValue is! String) {
      throw FormatException(
        'DecisionContext field "fallbackReason" must be a String when provided, '
            'but got ${fallbackReasonValue.runtimeType}.',
      );
    }

    if (sessionIdValue != null && sessionIdValue is! String) {
      throw FormatException(
        'DecisionContext field "sessionId" must be a String when provided, '
            'but got ${sessionIdValue.runtimeType}.',
      );
    }

    if (interactionIdValue != null && interactionIdValue is! String) {
      throw FormatException(
        'DecisionContext field "interactionId" must be a String when provided, '
            'but got ${interactionIdValue.runtimeType}.',
      );
    }

    return DecisionContext(
      inputState: AdaptiveState.fromMap(inputStateValue),
      normalizedState: AdaptiveState.fromMap(normalizedStateValue),
      generatedStateKey: generatedStateKeyValue,
      source: DecisionSource.normalize(sourceValue as String?),
      fallbackReason: fallbackReasonValue as String?,
      sessionId: sessionIdValue as String?,
      interactionId: interactionIdValue as String?,
      warnings: _readStringList(
        warningsValue,
        fieldName: 'warnings',
      ),
    );
  }

  /// Returns this context as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'inputState': inputState.toMap(),
      'normalizedState': normalizedState.toMap(),
      'generatedStateKey': generatedStateKey,
      'source': source,
      'fallbackReason': fallbackReason,
      'sessionId': sessionId,
      'interactionId': interactionId,
      'warnings': warnings,
    };
  }

  /// Returns whether fallback was used.
  bool get usedFallback => source == DecisionSource.fallback;

  /// Returns whether an exact match was used.
  bool get usedExactMatch => source == DecisionSource.exactMatch;

  /// Returns whether this context contains warnings.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Returns a copy of this context with selected values replaced.
  DecisionContext copyWith({
    AdaptiveState? inputState,
    AdaptiveState? normalizedState,
    String? generatedStateKey,
    String? source,
    String? fallbackReason,
    String? sessionId,
    String? interactionId,
    List<String>? warnings,
  }) {
    return DecisionContext(
      inputState: inputState ?? this.inputState,
      normalizedState: normalizedState ?? this.normalizedState,
      generatedStateKey: generatedStateKey ?? this.generatedStateKey,
      source: source ?? this.source,
      fallbackReason: fallbackReason ?? this.fallbackReason,
      sessionId: sessionId ?? this.sessionId,
      interactionId: interactionId ?? this.interactionId,
      warnings: warnings ?? this.warnings,
    );
  }

  @override
  String toString() {
    return 'DecisionContext('
        'inputState: $inputState, '
        'normalizedState: $normalizedState, '
        'generatedStateKey: $generatedStateKey, '
        'source: $source, '
        'fallbackReason: $fallbackReason, '
        'sessionId: $sessionId, '
        'interactionId: $interactionId, '
        'warnings: $warnings'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DecisionContext &&
            other.inputState == inputState &&
            other.normalizedState == normalizedState &&
            other.generatedStateKey == generatedStateKey &&
            other.source == source &&
            other.fallbackReason == fallbackReason &&
            other.sessionId == sessionId &&
            other.interactionId == interactionId &&
            _listEquals(other.warnings, warnings));
  }

  @override
  int get hashCode {
    return Object.hash(
      inputState,
      normalizedState,
      generatedStateKey,
      source,
      fallbackReason,
      sessionId,
      interactionId,
      Object.hashAll(warnings),
    );
  }

  static List<String> _readStringList(
      dynamic value, {
        required String fieldName,
      }) {
    if (value == null) return const <String>[];

    if (value is! List) {
      throw FormatException(
        'DecisionContext field "$fieldName" must be a List when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'DecisionContext field "$fieldName" must contain only String values, '
              'but found ${item.runtimeType}.',
        );
      }
      result.add(item);
    }

    return List<String>.unmodifiable(result);
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}