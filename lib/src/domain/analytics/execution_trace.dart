import '../policy/policy_metadata.dart';
import 'decision_trace.dart';
import 'runtime_diagnostics.dart';

/// Represents a broader execution trace for one adaptive runtime cycle.
///
/// Unlike [DecisionTrace], which focuses on the decision event itself,
/// [ExecutionTrace] can capture a wider operational view of the runtime step,
/// including:
/// - diagnostics
/// - decision trace
/// - policy metadata
/// - execution phase labeling
/// - warnings and notes
class ExecutionTrace {
  /// Stable execution trace identifier.
  final String traceId;

  /// Optional semantic phase label.
  ///
  /// Examples:
  /// - `runtime_execution`
  /// - `recommendation_building`
  /// - `session_evaluation`
  final String? phase;

  /// Optional runtime diagnostics for this execution.
  final RuntimeDiagnostics? diagnostics;

  /// Optional decision trace produced during this execution.
  final DecisionTrace? decisionTrace;

  /// Optional policy metadata associated with the execution context.
  final PolicyMetadata? policyMetadata;

  /// Optional number of indexed policy entries available during execution.
  final int? indexedPolicySize;

  /// Optional execution duration in milliseconds.
  final int? durationMs;

  /// Optional non-fatal warnings associated with this execution.
  final List<String> warnings;

  /// Optional free-form execution note.
  final String? note;

  /// Optional timestamp for when the execution trace was recorded.
  final DateTime? timestamp;

  /// Creates an execution trace.
  const ExecutionTrace({
    required this.traceId,
    this.phase,
    this.diagnostics,
    this.decisionTrace,
    this.policyMetadata,
    this.indexedPolicySize,
    this.durationMs,
    this.warnings = const <String>[],
    this.note,
    this.timestamp,
  });

  /// Creates an execution trace from a generic map.
  factory ExecutionTrace.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('traceId')) {
      throw const FormatException(
        'Missing required ExecutionTrace field: traceId',
      );
    }

    final traceIdValue = map['traceId'];
    final phaseValue = map['phase'];
    final diagnosticsValue = map['diagnostics'];
    final decisionTraceValue = map['decisionTrace'];
    final policyMetadataValue = map['policyMetadata'];
    final indexedPolicySizeValue = map['indexedPolicySize'];
    final durationMsValue = map['durationMs'];
    final warningsValue = map['warnings'];
    final noteValue = map['note'];
    final timestampValue = map['timestamp'];

    if (traceIdValue is! String) {
      throw FormatException(
        'ExecutionTrace field "traceId" must be a String, '
            'but got ${traceIdValue.runtimeType}.',
      );
    }

    if (phaseValue != null && phaseValue is! String) {
      throw FormatException(
        'ExecutionTrace field "phase" must be a String when provided, '
            'but got ${phaseValue.runtimeType}.',
      );
    }

    if (indexedPolicySizeValue != null && indexedPolicySizeValue is! num) {
      throw FormatException(
        'ExecutionTrace field "indexedPolicySize" must be numeric when provided, '
            'but got ${indexedPolicySizeValue.runtimeType}.',
      );
    }

    if (durationMsValue != null && durationMsValue is! num) {
      throw FormatException(
        'ExecutionTrace field "durationMs" must be numeric when provided, '
            'but got ${durationMsValue.runtimeType}.',
      );
    }

    if (noteValue != null && noteValue is! String) {
      throw FormatException(
        'ExecutionTrace field "note" must be a String when provided, '
            'but got ${noteValue.runtimeType}.',
      );
    }

    RuntimeDiagnostics? diagnostics;
    if (diagnosticsValue != null) {
      if (diagnosticsValue is! Map<String, dynamic>) {
        throw FormatException(
          'ExecutionTrace field "diagnostics" must be a Map<String, dynamic> when provided, '
              'but got ${diagnosticsValue.runtimeType}.',
        );
      }
      diagnostics = RuntimeDiagnostics.fromMap(diagnosticsValue);
    }

    DecisionTrace? decisionTrace;
    if (decisionTraceValue != null) {
      if (decisionTraceValue is! Map<String, dynamic>) {
        throw FormatException(
          'ExecutionTrace field "decisionTrace" must be a Map<String, dynamic> when provided, '
              'but got ${decisionTraceValue.runtimeType}.',
        );
      }
      decisionTrace = DecisionTrace.fromMap(decisionTraceValue);
    }

    PolicyMetadata? policyMetadata;
    if (policyMetadataValue != null) {
      if (policyMetadataValue is! Map<String, dynamic>) {
        throw FormatException(
          'ExecutionTrace field "policyMetadata" must be a Map<String, dynamic> when provided, '
              'but got ${policyMetadataValue.runtimeType}.',
        );
      }
      policyMetadata = PolicyMetadata.fromMap(policyMetadataValue);
    }

    DateTime? timestamp;
    if (timestampValue != null) {
      if (timestampValue is! String) {
        throw FormatException(
          'ExecutionTrace field "timestamp" must be a String when provided, '
              'but got ${timestampValue.runtimeType}.',
        );
      }

      timestamp = DateTime.tryParse(timestampValue);
      if (timestamp == null) {
        throw const FormatException(
          'ExecutionTrace field "timestamp" must be a valid ISO-8601 string.',
        );
      }
    }

    return ExecutionTrace(
      traceId: traceIdValue,
      phase: phaseValue as String?,
      diagnostics: diagnostics,
      decisionTrace: decisionTrace,
      policyMetadata: policyMetadata,
      indexedPolicySize: indexedPolicySizeValue == null
          ? null
          : (indexedPolicySizeValue as num).toInt(),
      durationMs: durationMsValue == null
          ? null
          : (durationMsValue as num).toInt(),
      warnings: _readStringList(
        warningsValue,
        fieldName: 'warnings',
      ),
      note: noteValue as String?,
      timestamp: timestamp,
    );
  }

  /// Returns this execution trace as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'traceId': traceId,
      'phase': phase,
      'diagnostics': diagnostics?.toMap(),
      'decisionTrace': decisionTrace?.toMap(),
      'policyMetadata': policyMetadata?.toMap(),
      'indexedPolicySize': indexedPolicySize,
      'durationMs': durationMs,
      'warnings': warnings,
      'note': note,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Returns whether diagnostics are attached.
  bool get hasDiagnostics => diagnostics != null;

  /// Returns whether a decision trace is attached.
  bool get hasDecisionTrace => decisionTrace != null;

  /// Returns whether policy metadata is attached.
  bool get hasPolicyMetadata => policyMetadata != null;

  /// Returns whether execution warnings are available.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Returns whether duration information is available.
  bool get hasDuration => durationMs != null;

  /// Returns a copy of this execution trace with selected values replaced.
  ExecutionTrace copyWith({
    String? traceId,
    String? phase,
    RuntimeDiagnostics? diagnostics,
    DecisionTrace? decisionTrace,
    PolicyMetadata? policyMetadata,
    int? indexedPolicySize,
    int? durationMs,
    List<String>? warnings,
    String? note,
    DateTime? timestamp,
  }) {
    return ExecutionTrace(
      traceId: traceId ?? this.traceId,
      phase: phase ?? this.phase,
      diagnostics: diagnostics ?? this.diagnostics,
      decisionTrace: decisionTrace ?? this.decisionTrace,
      policyMetadata: policyMetadata ?? this.policyMetadata,
      indexedPolicySize: indexedPolicySize ?? this.indexedPolicySize,
      durationMs: durationMs ?? this.durationMs,
      warnings: warnings ?? this.warnings,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'ExecutionTrace('
        'traceId: $traceId, '
        'phase: $phase, '
        'diagnostics: $diagnostics, '
        'decisionTrace: $decisionTrace, '
        'policyMetadata: $policyMetadata, '
        'indexedPolicySize: $indexedPolicySize, '
        'durationMs: $durationMs, '
        'warnings: $warnings, '
        'note: $note, '
        'timestamp: $timestamp'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ExecutionTrace &&
            other.traceId == traceId &&
            other.phase == phase &&
            other.diagnostics == diagnostics &&
            other.decisionTrace == decisionTrace &&
            other.policyMetadata == policyMetadata &&
            other.indexedPolicySize == indexedPolicySize &&
            other.durationMs == durationMs &&
            _listEquals(other.warnings, warnings) &&
            other.note == note &&
            other.timestamp == timestamp);
  }

  @override
  int get hashCode {
    return Object.hash(
      traceId,
      phase,
      diagnostics,
      decisionTrace,
      policyMetadata,
      indexedPolicySize,
      durationMs,
      Object.hashAll(warnings),
      note,
      timestamp,
    );
  }

  static List<String> _readStringList(
      dynamic value, {
        required String fieldName,
      }) {
    if (value == null) return const <String>[];

    if (value is! List) {
      throw FormatException(
        'ExecutionTrace field "$fieldName" must be a List when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'ExecutionTrace field "$fieldName" must contain only String values, '
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