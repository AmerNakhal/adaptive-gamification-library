import '../recommendations/adaptive_recommendation.dart';
import '../sessions/session_statistics.dart';
import '../state/state_snapshot.dart';
import '../transitions/difficulty_transition.dart';

/// Represents a lightweight analytics-oriented snapshot of adaptive execution
/// or session state.
///
/// This model is intended for:
/// - dashboards
/// - lightweight reporting
/// - periodic analytics checkpoints
/// - summarized observability
///
/// It is intentionally more compact than full decision or execution traces.
class AnalyticsSnapshot {
  /// Stable snapshot identifier.
  final String snapshotId;

  /// Optional session identifier associated with this snapshot.
  final String? sessionId;

  /// Optional semantic label describing the snapshot scope.
  ///
  /// Examples:
  /// - `runtime_checkpoint`
  /// - `session_summary`
  /// - `post_interaction`
  /// - `adaptive_review`
  final String? scope;

  /// Optional current adaptive state snapshot.
  final StateSnapshot? stateSnapshot;

  /// Optional aggregated session statistics.
  final SessionStatistics? sessionStatistics;

  /// Optional latest difficulty transition associated with this snapshot.
  final DifficultyTransition? latestTransition;

  /// Optional latest recommendation associated with this snapshot.
  final AdaptiveRecommendation? latestRecommendation;

  /// Optional count of recorded decision events contributing to this snapshot.
  final int? decisionCount;

  /// Optional count of fallback usages contributing to this snapshot.
  final int? fallbackCount;

  /// Optional free-form note.
  final String? note;

  /// Optional machine-usable tags for grouping or filtering.
  final List<String> tags;

  /// Optional timestamp for when the snapshot was recorded.
  final DateTime? timestamp;

  /// Creates an analytics snapshot.
  const AnalyticsSnapshot({
    required this.snapshotId,
    this.sessionId,
    this.scope,
    this.stateSnapshot,
    this.sessionStatistics,
    this.latestTransition,
    this.latestRecommendation,
    this.decisionCount,
    this.fallbackCount,
    this.note,
    this.tags = const <String>[],
    this.timestamp,
  });

  /// Creates an analytics snapshot from a generic map.
  factory AnalyticsSnapshot.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('snapshotId')) {
      throw const FormatException(
        'Missing required AnalyticsSnapshot field: snapshotId',
      );
    }

    final snapshotIdValue = map['snapshotId'];
    final sessionIdValue = map['sessionId'];
    final scopeValue = map['scope'];
    final stateSnapshotValue = map['stateSnapshot'];
    final sessionStatisticsValue = map['sessionStatistics'];
    final latestTransitionValue = map['latestTransition'];
    final latestRecommendationValue = map['latestRecommendation'];
    final decisionCountValue = map['decisionCount'];
    final fallbackCountValue = map['fallbackCount'];
    final noteValue = map['note'];
    final tagsValue = map['tags'];
    final timestampValue = map['timestamp'];

    if (snapshotIdValue is! String) {
      throw FormatException(
        'AnalyticsSnapshot field "snapshotId" must be a String, '
            'but got ${snapshotIdValue.runtimeType}.',
      );
    }

    if (sessionIdValue != null && sessionIdValue is! String) {
      throw FormatException(
        'AnalyticsSnapshot field "sessionId" must be a String when provided, '
            'but got ${sessionIdValue.runtimeType}.',
      );
    }

    if (scopeValue != null && scopeValue is! String) {
      throw FormatException(
        'AnalyticsSnapshot field "scope" must be a String when provided, '
            'but got ${scopeValue.runtimeType}.',
      );
    }

    if (decisionCountValue != null && decisionCountValue is! num) {
      throw FormatException(
        'AnalyticsSnapshot field "decisionCount" must be numeric when provided, '
            'but got ${decisionCountValue.runtimeType}.',
      );
    }

    if (fallbackCountValue != null && fallbackCountValue is! num) {
      throw FormatException(
        'AnalyticsSnapshot field "fallbackCount" must be numeric when provided, '
            'but got ${fallbackCountValue.runtimeType}.',
      );
    }

    if (noteValue != null && noteValue is! String) {
      throw FormatException(
        'AnalyticsSnapshot field "note" must be a String when provided, '
            'but got ${noteValue.runtimeType}.',
      );
    }

    StateSnapshot? stateSnapshot;
    if (stateSnapshotValue != null) {
      if (stateSnapshotValue is! Map<String, dynamic>) {
        throw FormatException(
          'AnalyticsSnapshot field "stateSnapshot" must be a Map<String, dynamic> when provided, '
              'but got ${stateSnapshotValue.runtimeType}.',
        );
      }
      stateSnapshot = StateSnapshot.fromMap(stateSnapshotValue);
    }

    SessionStatistics? sessionStatistics;
    if (sessionStatisticsValue != null) {
      if (sessionStatisticsValue is! Map<String, dynamic>) {
        throw FormatException(
          'AnalyticsSnapshot field "sessionStatistics" must be a Map<String, dynamic> when provided, '
              'but got ${sessionStatisticsValue.runtimeType}.',
        );
      }
      sessionStatistics = SessionStatistics.fromMap(sessionStatisticsValue);
    }

    DifficultyTransition? latestTransition;
    if (latestTransitionValue != null) {
      if (latestTransitionValue is! Map<String, dynamic>) {
        throw FormatException(
          'AnalyticsSnapshot field "latestTransition" must be a Map<String, dynamic> when provided, '
              'but got ${latestTransitionValue.runtimeType}.',
        );
      }
      latestTransition = DifficultyTransition.fromMap(latestTransitionValue);
    }

    AdaptiveRecommendation? latestRecommendation;
    if (latestRecommendationValue != null) {
      if (latestRecommendationValue is! Map<String, dynamic>) {
        throw FormatException(
          'AnalyticsSnapshot field "latestRecommendation" must be a Map<String, dynamic> when provided, '
              'but got ${latestRecommendationValue.runtimeType}.',
        );
      }
      latestRecommendation =
          AdaptiveRecommendation.fromMap(latestRecommendationValue);
    }

    DateTime? timestamp;
    if (timestampValue != null) {
      if (timestampValue is! String) {
        throw FormatException(
          'AnalyticsSnapshot field "timestamp" must be a String when provided, '
              'but got ${timestampValue.runtimeType}.',
        );
      }

      timestamp = DateTime.tryParse(timestampValue);
      if (timestamp == null) {
        throw const FormatException(
          'AnalyticsSnapshot field "timestamp" must be a valid ISO-8601 string.',
        );
      }
    }

    return AnalyticsSnapshot(
      snapshotId: snapshotIdValue,
      sessionId: sessionIdValue as String?,
      scope: scopeValue as String?,
      stateSnapshot: stateSnapshot,
      sessionStatistics: sessionStatistics,
      latestTransition: latestTransition,
      latestRecommendation: latestRecommendation,
      decisionCount: decisionCountValue == null
          ? null
          : (decisionCountValue as num).toInt(),
      fallbackCount: fallbackCountValue == null
          ? null
          : (fallbackCountValue as num).toInt(),
      note: noteValue as String?,
      tags: _readStringList(
        tagsValue,
        fieldName: 'tags',
      ),
      timestamp: timestamp,
    );
  }

  /// Returns this analytics snapshot as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'snapshotId': snapshotId,
      'sessionId': sessionId,
      'scope': scope,
      'stateSnapshot': stateSnapshot?.toMap(),
      'sessionStatistics': sessionStatistics?.toMap(),
      'latestTransition': latestTransition?.toMap(),
      'latestRecommendation': latestRecommendation?.toMap(),
      'decisionCount': decisionCount,
      'fallbackCount': fallbackCount,
      'note': note,
      'tags': tags,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Returns whether this snapshot contains a state snapshot.
  bool get hasStateSnapshot => stateSnapshot != null;

  /// Returns whether this snapshot contains session statistics.
  bool get hasSessionStatistics => sessionStatistics != null;

  /// Returns whether this snapshot contains a latest transition.
  bool get hasLatestTransition => latestTransition != null;

  /// Returns whether this snapshot contains a latest recommendation.
  bool get hasLatestRecommendation => latestRecommendation != null;

  /// Returns whether tags are available.
  bool get hasTags => tags.isNotEmpty;

  /// Returns fallback ratio if both counts are available and valid.
  double? get fallbackRate {
    if (decisionCount == null || fallbackCount == null) return null;
    if (decisionCount == 0) return 0.0;
    return fallbackCount! / decisionCount!;
  }

  /// Returns a copy of this analytics snapshot with selected values replaced.
  AnalyticsSnapshot copyWith({
    String? snapshotId,
    String? sessionId,
    String? scope,
    StateSnapshot? stateSnapshot,
    SessionStatistics? sessionStatistics,
    DifficultyTransition? latestTransition,
    AdaptiveRecommendation? latestRecommendation,
    int? decisionCount,
    int? fallbackCount,
    String? note,
    List<String>? tags,
    DateTime? timestamp,
  }) {
    return AnalyticsSnapshot(
      snapshotId: snapshotId ?? this.snapshotId,
      sessionId: sessionId ?? this.sessionId,
      scope: scope ?? this.scope,
      stateSnapshot: stateSnapshot ?? this.stateSnapshot,
      sessionStatistics: sessionStatistics ?? this.sessionStatistics,
      latestTransition: latestTransition ?? this.latestTransition,
      latestRecommendation: latestRecommendation ?? this.latestRecommendation,
      decisionCount: decisionCount ?? this.decisionCount,
      fallbackCount: fallbackCount ?? this.fallbackCount,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'AnalyticsSnapshot('
        'snapshotId: $snapshotId, '
        'sessionId: $sessionId, '
        'scope: $scope, '
        'stateSnapshot: $stateSnapshot, '
        'sessionStatistics: $sessionStatistics, '
        'latestTransition: $latestTransition, '
        'latestRecommendation: $latestRecommendation, '
        'decisionCount: $decisionCount, '
        'fallbackCount: $fallbackCount, '
        'note: $note, '
        'tags: $tags, '
        'timestamp: $timestamp'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AnalyticsSnapshot &&
            other.snapshotId == snapshotId &&
            other.sessionId == sessionId &&
            other.scope == scope &&
            other.stateSnapshot == stateSnapshot &&
            other.sessionStatistics == sessionStatistics &&
            other.latestTransition == latestTransition &&
            other.latestRecommendation == latestRecommendation &&
            other.decisionCount == decisionCount &&
            other.fallbackCount == fallbackCount &&
            other.note == note &&
            _listEquals(other.tags, tags) &&
            other.timestamp == timestamp);
  }

  @override
  int get hashCode {
    return Object.hash(
      snapshotId,
      sessionId,
      scope,
      stateSnapshot,
      sessionStatistics,
      latestTransition,
      latestRecommendation,
      decisionCount,
      fallbackCount,
      note,
      Object.hashAll(tags),
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
        'AnalyticsSnapshot field "$fieldName" must be a List when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'AnalyticsSnapshot field "$fieldName" must contain only String values, '
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