import '../recommendations/adaptive_recommendation.dart';
import '../transitions/difficulty_transition.dart';
import 'session_statistics.dart';

/// Represents a summarized view of an adaptive session.
///
/// This model is intended for:
/// - session reporting
/// - analytics summaries
/// - final or intermediate adaptive review
/// - UI presentation of session-level outcomes
class AdaptiveSessionSummary {
  /// Stable session identifier.
  final String sessionId;

  /// Optional aggregated session statistics.
  final SessionStatistics? statistics;

  /// Optional overall difficulty transition observed across the session.
  final DifficultyTransition? overallTransition;

  /// Optional latest or final recommendation associated with the session.
  final AdaptiveRecommendation? finalRecommendation;

  /// Optional session start timestamp.
  final DateTime? startedAt;

  /// Optional session end timestamp.
  final DateTime? endedAt;

  /// Optional semantic session label.
  ///
  /// Examples:
  /// - `completed`
  /// - `in_progress`
  /// - `interrupted`
  /// - `recovery_focused`
  final String? status;

  /// Optional free-form summary note.
  final String? note;

  /// Optional machine-usable tags for grouping or filtering.
  final List<String> tags;

  /// Creates an adaptive session summary.
  const AdaptiveSessionSummary({
    required this.sessionId,
    this.statistics,
    this.overallTransition,
    this.finalRecommendation,
    this.startedAt,
    this.endedAt,
    this.status,
    this.note,
    this.tags = const <String>[],
  });

  /// Creates a session summary from a generic map.
  factory AdaptiveSessionSummary.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('sessionId')) {
      throw const FormatException(
        'Missing required AdaptiveSessionSummary field: sessionId',
      );
    }

    final sessionIdValue = map['sessionId'];
    final statisticsValue = map['statistics'];
    final overallTransitionValue = map['overallTransition'];
    final finalRecommendationValue = map['finalRecommendation'];
    final startedAtValue = map['startedAt'];
    final endedAtValue = map['endedAt'];
    final statusValue = map['status'];
    final noteValue = map['note'];
    final tagsValue = map['tags'];

    if (sessionIdValue is! String) {
      throw FormatException(
        'AdaptiveSessionSummary field "sessionId" must be a String, '
            'but got ${sessionIdValue.runtimeType}.',
      );
    }

    if (statusValue != null && statusValue is! String) {
      throw FormatException(
        'AdaptiveSessionSummary field "status" must be a String when provided, '
            'but got ${statusValue.runtimeType}.',
      );
    }

    if (noteValue != null && noteValue is! String) {
      throw FormatException(
        'AdaptiveSessionSummary field "note" must be a String when provided, '
            'but got ${noteValue.runtimeType}.',
      );
    }

    SessionStatistics? statistics;
    if (statisticsValue != null) {
      if (statisticsValue is! Map<String, dynamic>) {
        throw FormatException(
          'AdaptiveSessionSummary field "statistics" must be a Map<String, dynamic> when provided, '
              'but got ${statisticsValue.runtimeType}.',
        );
      }
      statistics = SessionStatistics.fromMap(statisticsValue);
    }

    DifficultyTransition? overallTransition;
    if (overallTransitionValue != null) {
      if (overallTransitionValue is! Map<String, dynamic>) {
        throw FormatException(
          'AdaptiveSessionSummary field "overallTransition" must be a Map<String, dynamic> when provided, '
              'but got ${overallTransitionValue.runtimeType}.',
        );
      }
      overallTransition = DifficultyTransition.fromMap(overallTransitionValue);
    }

    AdaptiveRecommendation? finalRecommendation;
    if (finalRecommendationValue != null) {
      if (finalRecommendationValue is! Map<String, dynamic>) {
        throw FormatException(
          'AdaptiveSessionSummary field "finalRecommendation" must be a Map<String, dynamic> when provided, '
              'but got ${finalRecommendationValue.runtimeType}.',
        );
      }
      finalRecommendation =
          AdaptiveRecommendation.fromMap(finalRecommendationValue);
    }

    DateTime? startedAt;
    if (startedAtValue != null) {
      if (startedAtValue is! String) {
        throw FormatException(
          'AdaptiveSessionSummary field "startedAt" must be a String when provided, '
              'but got ${startedAtValue.runtimeType}.',
        );
      }
      startedAt = DateTime.tryParse(startedAtValue);
      if (startedAt == null) {
        throw const FormatException(
          'AdaptiveSessionSummary field "startedAt" must be a valid ISO-8601 string.',
        );
      }
    }

    DateTime? endedAt;
    if (endedAtValue != null) {
      if (endedAtValue is! String) {
        throw FormatException(
          'AdaptiveSessionSummary field "endedAt" must be a String when provided, '
              'but got ${endedAtValue.runtimeType}.',
        );
      }
      endedAt = DateTime.tryParse(endedAtValue);
      if (endedAt == null) {
        throw const FormatException(
          'AdaptiveSessionSummary field "endedAt" must be a valid ISO-8601 string.',
        );
      }
    }

    return AdaptiveSessionSummary(
      sessionId: sessionIdValue,
      statistics: statistics,
      overallTransition: overallTransition,
      finalRecommendation: finalRecommendation,
      startedAt: startedAt,
      endedAt: endedAt,
      status: statusValue as String?,
      note: noteValue as String?,
      tags: _readStringList(
        tagsValue,
        fieldName: 'tags',
      ),
    );
  }

  /// Returns this session summary as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'statistics': statistics?.toMap(),
      'overallTransition': overallTransition?.toMap(),
      'finalRecommendation': finalRecommendation?.toMap(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'status': status,
      'note': note,
      'tags': tags,
    };
  }

  /// Returns whether statistics are available.
  bool get hasStatistics => statistics != null;

  /// Returns whether an overall transition is available.
  bool get hasOverallTransition => overallTransition != null;

  /// Returns whether a final recommendation is available.
  bool get hasFinalRecommendation => finalRecommendation != null;

  /// Returns whether both timestamps are available.
  bool get hasTimeRange => startedAt != null && endedAt != null;

  /// Returns whether tags are available.
  bool get hasTags => tags.isNotEmpty;

  /// Returns session duration if both timestamps are available.
  Duration? get duration {
    if (!hasTimeRange) return null;
    return endedAt!.difference(startedAt!);
  }

  /// Returns a copy of this summary with selected values replaced.
  AdaptiveSessionSummary copyWith({
    String? sessionId,
    SessionStatistics? statistics,
    DifficultyTransition? overallTransition,
    AdaptiveRecommendation? finalRecommendation,
    DateTime? startedAt,
    DateTime? endedAt,
    String? status,
    String? note,
    List<String>? tags,
  }) {
    return AdaptiveSessionSummary(
      sessionId: sessionId ?? this.sessionId,
      statistics: statistics ?? this.statistics,
      overallTransition: overallTransition ?? this.overallTransition,
      finalRecommendation: finalRecommendation ?? this.finalRecommendation,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'AdaptiveSessionSummary('
        'sessionId: $sessionId, '
        'statistics: $statistics, '
        'overallTransition: $overallTransition, '
        'finalRecommendation: $finalRecommendation, '
        'startedAt: $startedAt, '
        'endedAt: $endedAt, '
        'status: $status, '
        'note: $note, '
        'tags: $tags'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdaptiveSessionSummary &&
            other.sessionId == sessionId &&
            other.statistics == statistics &&
            other.overallTransition == overallTransition &&
            other.finalRecommendation == finalRecommendation &&
            other.startedAt == startedAt &&
            other.endedAt == endedAt &&
            other.status == status &&
            other.note == note &&
            _listEquals(other.tags, tags));
  }

  @override
  int get hashCode {
    return Object.hash(
      sessionId,
      statistics,
      overallTransition,
      finalRecommendation,
      startedAt,
      endedAt,
      status,
      note,
      Object.hashAll(tags),
    );
  }

  static List<String> _readStringList(
      dynamic value, {
        required String fieldName,
      }) {
    if (value == null) return const <String>[];

    if (value is! List) {
      throw FormatException(
        'AdaptiveSessionSummary field "$fieldName" must be a List when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'AdaptiveSessionSummary field "$fieldName" must contain only String values, '
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