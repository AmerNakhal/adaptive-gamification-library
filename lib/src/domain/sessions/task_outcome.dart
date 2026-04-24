/// Represents the outcome of a task, challenge, or interaction step.
///
/// This model is intentionally generic so that it can support multiple
/// application scenarios such as:
/// - quiz questions
/// - learning tasks
/// - challenge progression
/// - adaptive activities
class TaskOutcome {
  /// Stable task identifier.
  final String taskId;

  /// Whether the task was completed successfully.
  final bool wasSuccessful;

  /// Optional numeric score in the range [0.0, 1.0] or any application-defined
  /// normalized score.
  final double? score;

  /// Optional completion duration in milliseconds.
  final int? durationMs;

  /// Optional number of retries attempted before completion.
  final int? retryCount;

  /// Optional difficulty rank associated with the task when it was attempted.
  final int? difficultyRank;

  /// Optional semantic difficulty label associated with the task.
  final String? difficultyLabel;

  /// Optional timestamp for when the outcome was recorded.
  final DateTime? timestamp;

  /// Optional session identifier.
  final String? sessionId;

  /// Optional free-form outcome note.
  final String? note;

  /// Creates a task outcome.
  const TaskOutcome({
    required this.taskId,
    required this.wasSuccessful,
    this.score,
    this.durationMs,
    this.retryCount,
    this.difficultyRank,
    this.difficultyLabel,
    this.timestamp,
    this.sessionId,
    this.note,
  });

  /// Creates a task outcome from a generic map.
  factory TaskOutcome.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('taskId')) {
      throw const FormatException(
        'Missing required TaskOutcome field: taskId',
      );
    }

    if (!map.containsKey('wasSuccessful')) {
      throw const FormatException(
        'Missing required TaskOutcome field: wasSuccessful',
      );
    }

    final taskIdValue = map['taskId'];
    final wasSuccessfulValue = map['wasSuccessful'];
    final scoreValue = map['score'];
    final durationMsValue = map['durationMs'];
    final retryCountValue = map['retryCount'];
    final difficultyRankValue = map['difficultyRank'];
    final difficultyLabelValue = map['difficultyLabel'];
    final timestampValue = map['timestamp'];
    final sessionIdValue = map['sessionId'];
    final noteValue = map['note'];

    if (taskIdValue is! String) {
      throw FormatException(
        'TaskOutcome field "taskId" must be a String, '
            'but got ${taskIdValue.runtimeType}.',
      );
    }

    if (wasSuccessfulValue is! bool) {
      throw FormatException(
        'TaskOutcome field "wasSuccessful" must be a bool, '
            'but got ${wasSuccessfulValue.runtimeType}.',
      );
    }

    if (scoreValue != null && scoreValue is! num) {
      throw FormatException(
        'TaskOutcome field "score" must be numeric when provided, '
            'but got ${scoreValue.runtimeType}.',
      );
    }

    if (durationMsValue != null && durationMsValue is! num) {
      throw FormatException(
        'TaskOutcome field "durationMs" must be numeric when provided, '
            'but got ${durationMsValue.runtimeType}.',
      );
    }

    if (retryCountValue != null && retryCountValue is! num) {
      throw FormatException(
        'TaskOutcome field "retryCount" must be numeric when provided, '
            'but got ${retryCountValue.runtimeType}.',
      );
    }

    if (difficultyRankValue != null && difficultyRankValue is! num) {
      throw FormatException(
        'TaskOutcome field "difficultyRank" must be numeric when provided, '
            'but got ${difficultyRankValue.runtimeType}.',
      );
    }

    if (difficultyLabelValue != null && difficultyLabelValue is! String) {
      throw FormatException(
        'TaskOutcome field "difficultyLabel" must be a String when provided, '
            'but got ${difficultyLabelValue.runtimeType}.',
      );
    }

    if (sessionIdValue != null && sessionIdValue is! String) {
      throw FormatException(
        'TaskOutcome field "sessionId" must be a String when provided, '
            'but got ${sessionIdValue.runtimeType}.',
      );
    }

    if (noteValue != null && noteValue is! String) {
      throw FormatException(
        'TaskOutcome field "note" must be a String when provided, '
            'but got ${noteValue.runtimeType}.',
      );
    }

    DateTime? timestamp;
    if (timestampValue != null) {
      if (timestampValue is! String) {
        throw FormatException(
          'TaskOutcome field "timestamp" must be a String when provided, '
              'but got ${timestampValue.runtimeType}.',
        );
      }

      timestamp = DateTime.tryParse(timestampValue);
      if (timestamp == null) {
        throw const FormatException(
          'TaskOutcome field "timestamp" must be a valid ISO-8601 string.',
        );
      }
    }

    return TaskOutcome(
      taskId: taskIdValue,
      wasSuccessful: wasSuccessfulValue,
      score: scoreValue == null ? null : (scoreValue as num).toDouble(),
      durationMs: durationMsValue == null
          ? null
          : (durationMsValue as num).toInt(),
      retryCount: retryCountValue == null
          ? null
          : (retryCountValue as num).toInt(),
      difficultyRank: difficultyRankValue == null
          ? null
          : (difficultyRankValue as num).toInt(),
      difficultyLabel: difficultyLabelValue as String?,
      timestamp: timestamp,
      sessionId: sessionIdValue as String?,
      note: noteValue as String?,
    );
  }

  /// Returns this task outcome as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'taskId': taskId,
      'wasSuccessful': wasSuccessful,
      'score': score,
      'durationMs': durationMs,
      'retryCount': retryCount,
      'difficultyRank': difficultyRank,
      'difficultyLabel': difficultyLabel,
      'timestamp': timestamp?.toIso8601String(),
      'sessionId': sessionId,
      'note': note,
    };
  }

  /// Returns whether a score is available.
  bool get hasScore => score != null;

  /// Returns whether a duration is available.
  bool get hasDuration => durationMs != null;

  /// Returns whether retry information is available.
  bool get hasRetryInfo => retryCount != null;

  /// Returns a copy of this task outcome with selected values replaced.
  TaskOutcome copyWith({
    String? taskId,
    bool? wasSuccessful,
    double? score,
    int? durationMs,
    int? retryCount,
    int? difficultyRank,
    String? difficultyLabel,
    DateTime? timestamp,
    String? sessionId,
    String? note,
  }) {
    return TaskOutcome(
      taskId: taskId ?? this.taskId,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      score: score ?? this.score,
      durationMs: durationMs ?? this.durationMs,
      retryCount: retryCount ?? this.retryCount,
      difficultyRank: difficultyRank ?? this.difficultyRank,
      difficultyLabel: difficultyLabel ?? this.difficultyLabel,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'TaskOutcome('
        'taskId: $taskId, '
        'wasSuccessful: $wasSuccessful, '
        'score: $score, '
        'durationMs: $durationMs, '
        'retryCount: $retryCount, '
        'difficultyRank: $difficultyRank, '
        'difficultyLabel: $difficultyLabel, '
        'timestamp: $timestamp, '
        'sessionId: $sessionId, '
        'note: $note'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TaskOutcome &&
            other.taskId == taskId &&
            other.wasSuccessful == wasSuccessful &&
            other.score == score &&
            other.durationMs == durationMs &&
            other.retryCount == retryCount &&
            other.difficultyRank == difficultyRank &&
            other.difficultyLabel == difficultyLabel &&
            other.timestamp == timestamp &&
            other.sessionId == sessionId &&
            other.note == note);
  }

  @override
  int get hashCode {
    return Object.hash(
      taskId,
      wasSuccessful,
      score,
      durationMs,
      retryCount,
      difficultyRank,
      difficultyLabel,
      timestamp,
      sessionId,
      note,
    );
  }
}