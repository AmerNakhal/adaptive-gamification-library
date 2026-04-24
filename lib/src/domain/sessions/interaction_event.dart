import 'task_outcome.dart';

/// Represents a single interaction event within an adaptive session.
///
/// An interaction event captures a user-facing runtime step such as:
/// - attempting a task
/// - answering a question
/// - completing an activity
/// - triggering an adaptive transition point
///
/// This model is broader than [TaskOutcome], as it may include contextual
/// interaction metadata in addition to the final outcome.
class InteractionEvent {
  /// Stable interaction identifier.
  final String interactionId;

  /// Stable session identifier.
  final String sessionId;

  /// Stable task or activity identifier.
  final String taskId;

  /// Canonical event type label.
  ///
  /// Examples:
  /// - `task_attempt`
  /// - `question_response`
  /// - `activity_completion`
  /// - `adaptive_checkpoint`
  final String eventType;

  /// Optional difficulty rank at the time of the interaction.
  final int? difficultyRank;

  /// Optional semantic difficulty label at the time of the interaction.
  final String? difficultyLabel;

  /// Optional normalized response time indicator or raw duration proxy.
  final double? responseTime;

  /// Optional normalized streak indicator associated with the interaction.
  final double? streak;

  /// Optional task outcome associated with this interaction.
  final TaskOutcome? outcome;

  /// Optional timestamp for when the interaction occurred.
  final DateTime? timestamp;

  /// Optional free-form note.
  final String? note;

  /// Creates an interaction event.
  const InteractionEvent({
    required this.interactionId,
    required this.sessionId,
    required this.taskId,
    required this.eventType,
    this.difficultyRank,
    this.difficultyLabel,
    this.responseTime,
    this.streak,
    this.outcome,
    this.timestamp,
    this.note,
  });

  /// Creates an interaction event from a generic map.
  factory InteractionEvent.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('interactionId')) {
      throw const FormatException(
        'Missing required InteractionEvent field: interactionId',
      );
    }

    if (!map.containsKey('sessionId')) {
      throw const FormatException(
        'Missing required InteractionEvent field: sessionId',
      );
    }

    if (!map.containsKey('taskId')) {
      throw const FormatException(
        'Missing required InteractionEvent field: taskId',
      );
    }

    if (!map.containsKey('eventType')) {
      throw const FormatException(
        'Missing required InteractionEvent field: eventType',
      );
    }

    final interactionIdValue = map['interactionId'];
    final sessionIdValue = map['sessionId'];
    final taskIdValue = map['taskId'];
    final eventTypeValue = map['eventType'];
    final difficultyRankValue = map['difficultyRank'];
    final difficultyLabelValue = map['difficultyLabel'];
    final responseTimeValue = map['responseTime'];
    final streakValue = map['streak'];
    final outcomeValue = map['outcome'];
    final timestampValue = map['timestamp'];
    final noteValue = map['note'];

    if (interactionIdValue is! String) {
      throw FormatException(
        'InteractionEvent field "interactionId" must be a String, '
            'but got ${interactionIdValue.runtimeType}.',
      );
    }

    if (sessionIdValue is! String) {
      throw FormatException(
        'InteractionEvent field "sessionId" must be a String, '
            'but got ${sessionIdValue.runtimeType}.',
      );
    }

    if (taskIdValue is! String) {
      throw FormatException(
        'InteractionEvent field "taskId" must be a String, '
            'but got ${taskIdValue.runtimeType}.',
      );
    }

    if (eventTypeValue is! String) {
      throw FormatException(
        'InteractionEvent field "eventType" must be a String, '
            'but got ${eventTypeValue.runtimeType}.',
      );
    }

    if (difficultyRankValue != null && difficultyRankValue is! num) {
      throw FormatException(
        'InteractionEvent field "difficultyRank" must be numeric when provided, '
            'but got ${difficultyRankValue.runtimeType}.',
      );
    }

    if (difficultyLabelValue != null && difficultyLabelValue is! String) {
      throw FormatException(
        'InteractionEvent field "difficultyLabel" must be a String when provided, '
            'but got ${difficultyLabelValue.runtimeType}.',
      );
    }

    if (responseTimeValue != null && responseTimeValue is! num) {
      throw FormatException(
        'InteractionEvent field "responseTime" must be numeric when provided, '
            'but got ${responseTimeValue.runtimeType}.',
      );
    }

    if (streakValue != null && streakValue is! num) {
      throw FormatException(
        'InteractionEvent field "streak" must be numeric when provided, '
            'but got ${streakValue.runtimeType}.',
      );
    }

    if (noteValue != null && noteValue is! String) {
      throw FormatException(
        'InteractionEvent field "note" must be a String when provided, '
            'but got ${noteValue.runtimeType}.',
      );
    }

    TaskOutcome? outcome;
    if (outcomeValue != null) {
      if (outcomeValue is! Map<String, dynamic>) {
        throw FormatException(
          'InteractionEvent field "outcome" must be a Map<String, dynamic> when provided, '
              'but got ${outcomeValue.runtimeType}.',
        );
      }

      outcome = TaskOutcome.fromMap(outcomeValue);
    }

    DateTime? timestamp;
    if (timestampValue != null) {
      if (timestampValue is! String) {
        throw FormatException(
          'InteractionEvent field "timestamp" must be a String when provided, '
              'but got ${timestampValue.runtimeType}.',
        );
      }

      timestamp = DateTime.tryParse(timestampValue);
      if (timestamp == null) {
        throw const FormatException(
          'InteractionEvent field "timestamp" must be a valid ISO-8601 string.',
        );
      }
    }

    return InteractionEvent(
      interactionId: interactionIdValue,
      sessionId: sessionIdValue,
      taskId: taskIdValue,
      eventType: eventTypeValue,
      difficultyRank: difficultyRankValue == null
          ? null
          : (difficultyRankValue as num).toInt(),
      difficultyLabel: difficultyLabelValue as String?,
      responseTime: responseTimeValue == null
          ? null
          : (responseTimeValue as num).toDouble(),
      streak: streakValue == null ? null : (streakValue as num).toDouble(),
      outcome: outcome,
      timestamp: timestamp,
      note: noteValue as String?,
    );
  }

  /// Returns this interaction event as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'interactionId': interactionId,
      'sessionId': sessionId,
      'taskId': taskId,
      'eventType': eventType,
      'difficultyRank': difficultyRank,
      'difficultyLabel': difficultyLabel,
      'responseTime': responseTime,
      'streak': streak,
      'outcome': outcome?.toMap(),
      'timestamp': timestamp?.toIso8601String(),
      'note': note,
    };
  }

  /// Returns whether this interaction carries an outcome.
  bool get hasOutcome => outcome != null;

  /// Returns whether this interaction carries response-time information.
  bool get hasResponseTime => responseTime != null;

  /// Returns whether this interaction carries streak information.
  bool get hasStreak => streak != null;

  /// Returns a copy of this interaction event with selected values replaced.
  InteractionEvent copyWith({
    String? interactionId,
    String? sessionId,
    String? taskId,
    String? eventType,
    int? difficultyRank,
    String? difficultyLabel,
    double? responseTime,
    double? streak,
    TaskOutcome? outcome,
    DateTime? timestamp,
    String? note,
  }) {
    return InteractionEvent(
      interactionId: interactionId ?? this.interactionId,
      sessionId: sessionId ?? this.sessionId,
      taskId: taskId ?? this.taskId,
      eventType: eventType ?? this.eventType,
      difficultyRank: difficultyRank ?? this.difficultyRank,
      difficultyLabel: difficultyLabel ?? this.difficultyLabel,
      responseTime: responseTime ?? this.responseTime,
      streak: streak ?? this.streak,
      outcome: outcome ?? this.outcome,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'InteractionEvent('
        'interactionId: $interactionId, '
        'sessionId: $sessionId, '
        'taskId: $taskId, '
        'eventType: $eventType, '
        'difficultyRank: $difficultyRank, '
        'difficultyLabel: $difficultyLabel, '
        'responseTime: $responseTime, '
        'streak: $streak, '
        'outcome: $outcome, '
        'timestamp: $timestamp, '
        'note: $note'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is InteractionEvent &&
            other.interactionId == interactionId &&
            other.sessionId == sessionId &&
            other.taskId == taskId &&
            other.eventType == eventType &&
            other.difficultyRank == difficultyRank &&
            other.difficultyLabel == difficultyLabel &&
            other.responseTime == responseTime &&
            other.streak == streak &&
            other.outcome == outcome &&
            other.timestamp == timestamp &&
            other.note == note);
  }

  @override
  int get hashCode {
    return Object.hash(
      interactionId,
      sessionId,
      taskId,
      eventType,
      difficultyRank,
      difficultyLabel,
      responseTime,
      streak,
      outcome,
      timestamp,
      note,
    );
  }
}