import '../decisions/decision_context.dart';
import '../state/adaptive_state.dart';

/// Lightweight runtime diagnostics produced during adaptive execution.
///
/// This model is intended for:
/// - runtime observability
/// - debugging
/// - testing
/// - lightweight developer-facing diagnostics
///
/// It is intentionally lighter than full decision or execution traces.
class RuntimeDiagnostics {
  /// Original input state provided to the runtime.
  final AdaptiveState inputState;

  /// Normalized or processed state actually used during execution.
  final AdaptiveState normalizedState;

  /// Deterministic key generated for runtime lookup.
  final String generatedStateKey;

  /// Whether an exact policy match was used.
  final bool usedExactMatch;

  /// Whether fallback logic was used.
  final bool usedFallback;

  /// Optional fallback reason if fallback was triggered.
  final String? fallbackReason;

  /// Number of indexed policy entries available at runtime.
  final int indexedPolicySize;

  /// Optional warnings collected during execution.
  final List<String> warnings;

  /// Optional richer decision context associated with these diagnostics.
  final DecisionContext? decisionContext;

  /// Creates runtime diagnostics.
  const RuntimeDiagnostics({
    required this.inputState,
    required this.normalizedState,
    required this.generatedStateKey,
    required this.usedExactMatch,
    required this.usedFallback,
    required this.indexedPolicySize,
    this.fallbackReason,
    this.warnings = const <String>[],
    this.decisionContext,
  });

  /// Creates runtime diagnostics from a generic map.
  factory RuntimeDiagnostics.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('inputState')) {
      throw const FormatException(
        'Missing required RuntimeDiagnostics field: inputState',
      );
    }

    if (!map.containsKey('normalizedState')) {
      throw const FormatException(
        'Missing required RuntimeDiagnostics field: normalizedState',
      );
    }

    if (!map.containsKey('generatedStateKey')) {
      throw const FormatException(
        'Missing required RuntimeDiagnostics field: generatedStateKey',
      );
    }

    if (!map.containsKey('usedExactMatch')) {
      throw const FormatException(
        'Missing required RuntimeDiagnostics field: usedExactMatch',
      );
    }

    if (!map.containsKey('usedFallback')) {
      throw const FormatException(
        'Missing required RuntimeDiagnostics field: usedFallback',
      );
    }

    if (!map.containsKey('indexedPolicySize')) {
      throw const FormatException(
        'Missing required RuntimeDiagnostics field: indexedPolicySize',
      );
    }

    final inputStateValue = map['inputState'];
    final normalizedStateValue = map['normalizedState'];
    final generatedStateKeyValue = map['generatedStateKey'];
    final usedExactMatchValue = map['usedExactMatch'];
    final usedFallbackValue = map['usedFallback'];
    final indexedPolicySizeValue = map['indexedPolicySize'];
    final fallbackReasonValue = map['fallbackReason'];
    final warningsValue = map['warnings'];
    final decisionContextValue = map['decisionContext'];

    if (inputStateValue is! Map<String, dynamic>) {
      throw FormatException(
        'RuntimeDiagnostics field "inputState" must be a Map<String, dynamic>, '
            'but got ${inputStateValue.runtimeType}.',
      );
    }

    if (normalizedStateValue is! Map<String, dynamic>) {
      throw FormatException(
        'RuntimeDiagnostics field "normalizedState" must be a Map<String, dynamic>, '
            'but got ${normalizedStateValue.runtimeType}.',
      );
    }

    if (generatedStateKeyValue is! String) {
      throw FormatException(
        'RuntimeDiagnostics field "generatedStateKey" must be a String, '
            'but got ${generatedStateKeyValue.runtimeType}.',
      );
    }

    if (usedExactMatchValue is! bool) {
      throw FormatException(
        'RuntimeDiagnostics field "usedExactMatch" must be a bool, '
            'but got ${usedExactMatchValue.runtimeType}.',
      );
    }

    if (usedFallbackValue is! bool) {
      throw FormatException(
        'RuntimeDiagnostics field "usedFallback" must be a bool, '
            'but got ${usedFallbackValue.runtimeType}.',
      );
    }

    if (indexedPolicySizeValue is! num) {
      throw FormatException(
        'RuntimeDiagnostics field "indexedPolicySize" must be numeric, '
            'but got ${indexedPolicySizeValue.runtimeType}.',
      );
    }

    if (fallbackReasonValue != null && fallbackReasonValue is! String) {
      throw FormatException(
        'RuntimeDiagnostics field "fallbackReason" must be a String when provided, '
            'but got ${fallbackReasonValue.runtimeType}.',
      );
    }

    DecisionContext? decisionContext;
    if (decisionContextValue != null) {
      if (decisionContextValue is! Map<String, dynamic>) {
        throw FormatException(
          'RuntimeDiagnostics field "decisionContext" must be a Map<String, dynamic> when provided, '
              'but got ${decisionContextValue.runtimeType}.',
        );
      }
      decisionContext = DecisionContext.fromMap(decisionContextValue);
    }

    return RuntimeDiagnostics(
      inputState: AdaptiveState.fromMap(inputStateValue),
      normalizedState: AdaptiveState.fromMap(normalizedStateValue),
      generatedStateKey: generatedStateKeyValue,
      usedExactMatch: usedExactMatchValue,
      usedFallback: usedFallbackValue,
      indexedPolicySize: indexedPolicySizeValue.toInt(),
      fallbackReason: fallbackReasonValue as String?,
      warnings: _readStringList(
        warningsValue,
        fieldName: 'warnings',
      ),
      decisionContext: decisionContext,
    );
  }

  /// Returns this diagnostics object as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'inputState': inputState.toMap(),
      'normalizedState': normalizedState.toMap(),
      'generatedStateKey': generatedStateKey,
      'usedExactMatch': usedExactMatch,
      'usedFallback': usedFallback,
      'indexedPolicySize': indexedPolicySize,
      'fallbackReason': fallbackReason,
      'warnings': warnings,
      'decisionContext': decisionContext?.toMap(),
    };
  }

  /// Returns whether this diagnostics object contains warnings.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Returns whether a richer decision context is attached.
  bool get hasDecisionContext => decisionContext != null;

  /// Returns a copy of this diagnostics object with selected values replaced.
  RuntimeDiagnostics copyWith({
    AdaptiveState? inputState,
    AdaptiveState? normalizedState,
    String? generatedStateKey,
    bool? usedExactMatch,
    bool? usedFallback,
    String? fallbackReason,
    int? indexedPolicySize,
    List<String>? warnings,
    DecisionContext? decisionContext,
  }) {
    return RuntimeDiagnostics(
      inputState: inputState ?? this.inputState,
      normalizedState: normalizedState ?? this.normalizedState,
      generatedStateKey: generatedStateKey ?? this.generatedStateKey,
      usedExactMatch: usedExactMatch ?? this.usedExactMatch,
      usedFallback: usedFallback ?? this.usedFallback,
      fallbackReason: fallbackReason ?? this.fallbackReason,
      indexedPolicySize: indexedPolicySize ?? this.indexedPolicySize,
      warnings: warnings ?? this.warnings,
      decisionContext: decisionContext ?? this.decisionContext,
    );
  }

  @override
  String toString() {
    return 'RuntimeDiagnostics('
        'inputState: $inputState, '
        'normalizedState: $normalizedState, '
        'generatedStateKey: $generatedStateKey, '
        'usedExactMatch: $usedExactMatch, '
        'usedFallback: $usedFallback, '
        'fallbackReason: $fallbackReason, '
        'indexedPolicySize: $indexedPolicySize, '
        'warnings: $warnings, '
        'decisionContext: $decisionContext'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RuntimeDiagnostics &&
            other.inputState == inputState &&
            other.normalizedState == normalizedState &&
            other.generatedStateKey == generatedStateKey &&
            other.usedExactMatch == usedExactMatch &&
            other.usedFallback == usedFallback &&
            other.fallbackReason == fallbackReason &&
            other.indexedPolicySize == indexedPolicySize &&
            _listEquals(other.warnings, warnings) &&
            other.decisionContext == decisionContext);
  }

  @override
  int get hashCode {
    return Object.hash(
      inputState,
      normalizedState,
      generatedStateKey,
      usedExactMatch,
      usedFallback,
      fallbackReason,
      indexedPolicySize,
      Object.hashAll(warnings),
      decisionContext,
    );
  }

  static List<String> _readStringList(
      dynamic value, {
        required String fieldName,
      }) {
    if (value == null) return const <String>[];

    if (value is! List) {
      throw FormatException(
        'RuntimeDiagnostics field "$fieldName" must be a List when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'RuntimeDiagnostics field "$fieldName" must contain only String values, '
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