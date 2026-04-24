import '../decisions/adaptive_decision.dart';
import '../decisions/decision_context.dart';
import '../recommendations/adaptive_recommendation.dart';
import '../transitions/difficulty_transition.dart';

/// Represents a rich trace for a single adaptive decision event.
///
/// A decision trace captures:
/// - the decision itself
/// - its runtime context
/// - any derived difficulty transition
/// - any derived recommendation
/// - optional warnings and notes
///
/// This model is intended for:
/// - explainability
/// - debugging
/// - analytics
/// - decision replay
/// - research-oriented tracing
class DecisionTrace {
  /// Stable trace identifier.
  final String traceId;

  /// The adaptive decision produced during execution.
  final AdaptiveDecision decision;

  /// The execution context associated with the decision.
  final DecisionContext context;

  /// Optional difficulty transition derived from the decision.
  final DifficultyTransition? transition;

  /// Optional adaptive recommendation derived from the decision.
  final AdaptiveRecommendation? recommendation;

  /// Optional warnings associated with this trace.
  final List<String> warnings;

  /// Optional free-form note.
  final String? note;

  /// Optional timestamp associated with the trace.
  final DateTime? timestamp;

  /// Creates a decision trace.
  const DecisionTrace({
    required this.traceId,
    required this.decision,
    required this.context,
    this.transition,
    this.recommendation,
    this.warnings = const <String>[],
    this.note,
    this.timestamp,
  });

  /// Creates a decision trace from a generic map.
  factory DecisionTrace.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('traceId')) {
      throw const FormatException(
        'Missing required DecisionTrace field: traceId',
      );
    }

    if (!map.containsKey('decision')) {
      throw const FormatException(
        'Missing required DecisionTrace field: decision',
      );
    }

    if (!map.containsKey('context')) {
      throw const FormatException(
        'Missing required DecisionTrace field: context',
      );
    }

    final traceIdValue = map['traceId'];
    final decisionValue = map['decision'];
    final contextValue = map['context'];
    final transitionValue = map['transition'];
    final recommendationValue = map['recommendation'];
    final warningsValue = map['warnings'];
    final noteValue = map['note'];
    final timestampValue = map['timestamp'];

    if (traceIdValue is! String) {
      throw FormatException(
        'DecisionTrace field "traceId" must be a String, '
            'but got ${traceIdValue.runtimeType}.',
      );
    }

    if (decisionValue is! Map<String, dynamic>) {
      throw FormatException(
        'DecisionTrace field "decision" must be a Map<String, dynamic>, '
            'but got ${decisionValue.runtimeType}.',
      );
    }

    if (contextValue is! Map<String, dynamic>) {
      throw FormatException(
        'DecisionTrace field "context" must be a Map<String, dynamic>, '
            'but got ${contextValue.runtimeType}.',
      );
    }

    if (noteValue != null && noteValue is! String) {
      throw FormatException(
        'DecisionTrace field "note" must be a String when provided, '
            'but got ${noteValue.runtimeType}.',
      );
    }

    DifficultyTransition? transition;
    if (transitionValue != null) {
      if (transitionValue is! Map<String, dynamic>) {
        throw FormatException(
          'DecisionTrace field "transition" must be a Map<String, dynamic> when provided, '
              'but got ${transitionValue.runtimeType}.',
        );
      }
      transition = DifficultyTransition.fromMap(transitionValue);
    }

    AdaptiveRecommendation? recommendation;
    if (recommendationValue != null) {
      if (recommendationValue is! Map<String, dynamic>) {
        throw FormatException(
          'DecisionTrace field "recommendation" must be a Map<String, dynamic> when provided, '
              'but got ${recommendationValue.runtimeType}.',
        );
      }
      recommendation = AdaptiveRecommendation.fromMap(recommendationValue);
    }

    DateTime? timestamp;
    if (timestampValue != null) {
      if (timestampValue is! String) {
        throw FormatException(
          'DecisionTrace field "timestamp" must be a String when provided, '
              'but got ${timestampValue.runtimeType}.',
        );
      }

      timestamp = DateTime.tryParse(timestampValue);
      if (timestamp == null) {
        throw const FormatException(
          'DecisionTrace field "timestamp" must be a valid ISO-8601 string.',
        );
      }
    }

    return DecisionTrace(
      traceId: traceIdValue,
      decision: AdaptiveDecision.fromMap(decisionValue),
      context: DecisionContext.fromMap(contextValue),
      transition: transition,
      recommendation: recommendation,
      warnings: _readStringList(
        warningsValue,
        fieldName: 'warnings',
      ),
      note: noteValue as String?,
      timestamp: timestamp,
    );
  }

  /// Returns this trace as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'traceId': traceId,
      'decision': decision.toMap(),
      'context': context.toMap(),
      'transition': transition?.toMap(),
      'recommendation': recommendation?.toMap(),
      'warnings': warnings,
      'note': note,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Returns whether this trace contains a difficulty transition.
  bool get hasTransition => transition != null;

  /// Returns whether this trace contains a recommendation.
  bool get hasRecommendation => recommendation != null;

  /// Returns whether this trace contains warnings.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Returns whether this trace represents fallback usage.
  bool get usedFallback => context.usedFallback;

  /// Returns whether this trace represents exact-match usage.
  bool get usedExactMatch => context.usedExactMatch;

  /// Returns a copy of this trace with selected values replaced.
  DecisionTrace copyWith({
    String? traceId,
    AdaptiveDecision? decision,
    DecisionContext? context,
    DifficultyTransition? transition,
    AdaptiveRecommendation? recommendation,
    List<String>? warnings,
    String? note,
    DateTime? timestamp,
  }) {
    return DecisionTrace(
      traceId: traceId ?? this.traceId,
      decision: decision ?? this.decision,
      context: context ?? this.context,
      transition: transition ?? this.transition,
      recommendation: recommendation ?? this.recommendation,
      warnings: warnings ?? this.warnings,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'DecisionTrace('
        'traceId: $traceId, '
        'decision: $decision, '
        'context: $context, '
        'transition: $transition, '
        'recommendation: $recommendation, '
        'warnings: $warnings, '
        'note: $note, '
        'timestamp: $timestamp'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DecisionTrace &&
            other.traceId == traceId &&
            other.decision == decision &&
            other.context == context &&
            other.transition == transition &&
            other.recommendation == recommendation &&
            _listEquals(other.warnings, warnings) &&
            other.note == note &&
            other.timestamp == timestamp);
  }

  @override
  int get hashCode {
    return Object.hash(
      traceId,
      decision,
      context,
      transition,
      recommendation,
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
        'DecisionTrace field "$fieldName" must be a List when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'DecisionTrace field "$fieldName" must contain only String values, '
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