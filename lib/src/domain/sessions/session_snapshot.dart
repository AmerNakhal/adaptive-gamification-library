import '../recommendations/adaptive_recommendation.dart';
import '../state/state_snapshot.dart';
import 'interaction_event.dart';
import 'session_statistics.dart';
import 'task_outcome.dart';

/// Represents the current snapshot of an adaptive session.
///
/// A session snapshot captures the current session-level state, including:
/// - session identity
/// - latest adaptive state snapshot
/// - most recent interaction
/// - most recent task outcome
/// - aggregated session statistics
/// - latest adaptive recommendation
class SessionSnapshot {
  /// Stable session identifier.
  final String sessionId;

  /// Optional current adaptive state snapshot.
  final StateSnapshot? currentState;

  /// Optional most recent interaction event.
  final InteractionEvent? latestInteraction;

  /// Optional most recent task outcome.
  final TaskOutcome? latestOutcome;

  /// Optional aggregated session statistics.
  final SessionStatistics? statistics;

  /// Optional latest adaptive recommendation.
  final AdaptiveRecommendation? latestRecommendation;

  /// Optional number of recorded interactions in the session.
  final int interactionCount;

  /// Optional session start timestamp.
  final DateTime? startedAt;

  /// Optional timestamp for the latest update to this snapshot.
  final DateTime? updatedAt;

  /// Optional free-form session note.
  final String? note;

  /// Creates a session snapshot.
  const SessionSnapshot({
    required this.sessionId,
    this.currentState,
    this.latestInteraction,
    this.latestOutcome,
    this.statistics,
    this.latestRecommendation,
    this.interactionCount = 0,
    this.startedAt,
    this.updatedAt,
    this.note,
  });

  /// Creates a session snapshot from a generic map.
  factory SessionSnapshot.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('sessionId')) {
      throw const FormatException(
        'Missing required SessionSnapshot field: sessionId',
      );
    }

    final sessionIdValue = map['sessionId'];
    final currentStateValue = map['currentState'];
    final latestInteractionValue = map['latestInteraction'];
    final latestOutcomeValue = map['latestOutcome'];
    final statisticsValue = map['statistics'];
    final latestRecommendationValue = map['latestRecommendation'];
    final interactionCountValue = map['interactionCount'];
    final startedAtValue = map['startedAt'];
    final updatedAtValue = map['updatedAt'];
    final noteValue = map['note'];

    if (sessionIdValue is! String) {
      throw FormatException(
        'SessionSnapshot field "sessionId" must be a String, '
            'but got ${sessionIdValue.runtimeType}.',
      );
    }

    if (interactionCountValue != null && interactionCountValue is! num) {
      throw FormatException(
        'SessionSnapshot field "interactionCount" must be numeric when provided, '
            'but got ${interactionCountValue.runtimeType}.',
      );
    }

    if (noteValue != null && noteValue is! String) {
      throw FormatException(
        'SessionSnapshot field "note" must be a String when provided, '
            'but got ${noteValue.runtimeType}.',
      );
    }

    StateSnapshot? currentState;
    if (currentStateValue != null) {
      if (currentStateValue is! Map<String, dynamic>) {
        throw FormatException(
          'SessionSnapshot field "currentState" must be a Map<String, dynamic> when provided, '
              'but got ${currentStateValue.runtimeType}.',
        );
      }
      currentState = StateSnapshot.fromMap(currentStateValue);
    }

    InteractionEvent? latestInteraction;
    if (latestInteractionValue != null) {
      if (latestInteractionValue is! Map<String, dynamic>) {
        throw FormatException(
          'SessionSnapshot field "latestInteraction" must be a Map<String, dynamic> when provided, '
              'but got ${latestInteractionValue.runtimeType}.',
        );
      }
      latestInteraction = InteractionEvent.fromMap(latestInteractionValue);
    }

    TaskOutcome? latestOutcome;
    if (latestOutcomeValue != null) {
      if (latestOutcomeValue is! Map<String, dynamic>) {
        throw FormatException(
          'SessionSnapshot field "latestOutcome" must be a Map<String, dynamic> when provided, '
              'but got ${latestOutcomeValue.runtimeType}.',
        );
      }
      latestOutcome = TaskOutcome.fromMap(latestOutcomeValue);
    }

    SessionStatistics? statistics;
    if (statisticsValue != null) {
      if (statisticsValue is! Map<String, dynamic>) {
        throw FormatException(
          'SessionSnapshot field "statistics" must be a Map<String, dynamic> when provided, '
              'but got ${statisticsValue.runtimeType}.',
        );
      }
      statistics = SessionStatistics.fromMap(statisticsValue);
    }

    AdaptiveRecommendation? latestRecommendation;
    if (latestRecommendationValue != null) {
      if (latestRecommendationValue is! Map<String, dynamic>) {
        throw FormatException(
          'SessionSnapshot field "latestRecommendation" must be a Map<String, dynamic> when provided, '
              'but got ${latestRecommendationValue.runtimeType}.',
        );
      }
      latestRecommendation =
          AdaptiveRecommendation.fromMap(latestRecommendationValue);
    }

    DateTime? startedAt;
    if (startedAtValue != null) {
      if (startedAtValue is! String) {
        throw FormatException(
          'SessionSnapshot field "startedAt" must be a String when provided, '
              'but got ${startedAtValue.runtimeType}.',
        );
      }
      startedAt = DateTime.tryParse(startedAtValue);
      if (startedAt == null) {
        throw const FormatException(
          'SessionSnapshot field "startedAt" must be a valid ISO-8601 string.',
        );
      }
    }

    DateTime? updatedAt;
    if (updatedAtValue != null) {
      if (updatedAtValue is! String) {
        throw FormatException(
          'SessionSnapshot field "updatedAt" must be a String when provided, '
              'but got ${updatedAtValue.runtimeType}.',
        );
      }
      updatedAt = DateTime.tryParse(updatedAtValue);
      if (updatedAt == null) {
        throw const FormatException(
          'SessionSnapshot field "updatedAt" must be a valid ISO-8601 string.',
        );
      }
    }

    return SessionSnapshot(
      sessionId: sessionIdValue,
      currentState: currentState,
      latestInteraction: latestInteraction,
      latestOutcome: latestOutcome,
      statistics: statistics,
      latestRecommendation: latestRecommendation,
      interactionCount: interactionCountValue == null
          ? 0
          : (interactionCountValue as num).toInt(),
      startedAt: startedAt,
      updatedAt: updatedAt,
      note: noteValue as String?,
    );
  }

  /// Returns this session snapshot as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'currentState': currentState?.toMap(),
      'latestInteraction': latestInteraction?.toMap(),
      'latestOutcome': latestOutcome?.toMap(),
      'statistics': statistics?.toMap(),
      'latestRecommendation': latestRecommendation?.toMap(),
      'interactionCount': interactionCount,
      'startedAt': startedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'note': note,
    };
  }

  /// Returns whether this snapshot has a current adaptive state.
  bool get hasCurrentState => currentState != null;

  /// Returns whether this snapshot has a latest interaction.
  bool get hasLatestInteraction => latestInteraction != null;

  /// Returns whether this snapshot has a latest outcome.
  bool get hasLatestOutcome => latestOutcome != null;

  /// Returns whether this snapshot has statistics.
  bool get hasStatistics => statistics != null;

  /// Returns whether this snapshot has a latest recommendation.
  bool get hasLatestRecommendation => latestRecommendation != null;

  /// Returns a copy of this snapshot with selected values replaced.
  SessionSnapshot copyWith({
    String? sessionId,
    StateSnapshot? currentState,
    InteractionEvent? latestInteraction,
    TaskOutcome? latestOutcome,
    SessionStatistics? statistics,
    AdaptiveRecommendation? latestRecommendation,
    int? interactionCount,
    DateTime? startedAt,
    DateTime? updatedAt,
    String? note,
  }) {
    return SessionSnapshot(
      sessionId: sessionId ?? this.sessionId,
      currentState: currentState ?? this.currentState,
      latestInteraction: latestInteraction ?? this.latestInteraction,
      latestOutcome: latestOutcome ?? this.latestOutcome,
      statistics: statistics ?? this.statistics,
      latestRecommendation: latestRecommendation ?? this.latestRecommendation,
      interactionCount: interactionCount ?? this.interactionCount,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'SessionSnapshot('
        'sessionId: $sessionId, '
        'currentState: $currentState, '
        'latestInteraction: $latestInteraction, '
        'latestOutcome: $latestOutcome, '
        'statistics: $statistics, '
        'latestRecommendation: $latestRecommendation, '
        'interactionCount: $interactionCount, '
        'startedAt: $startedAt, '
        'updatedAt: $updatedAt, '
        'note: $note'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SessionSnapshot &&
            other.sessionId == sessionId &&
            other.currentState == currentState &&
            other.latestInteraction == latestInteraction &&
            other.latestOutcome == latestOutcome &&
            other.statistics == statistics &&
            other.latestRecommendation == latestRecommendation &&
            other.interactionCount == interactionCount &&
            other.startedAt == startedAt &&
            other.updatedAt == updatedAt &&
            other.note == note);
  }

  @override
  int get hashCode {
    return Object.hash(
      sessionId,
      currentState,
      latestInteraction,
      latestOutcome,
      statistics,
      latestRecommendation,
      interactionCount,
      startedAt,
      updatedAt,
      note,
    );
  }
}