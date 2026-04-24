import 'adaptive_state.dart';

/// Represents a contextual snapshot of an [AdaptiveState].
///
/// A state snapshot is useful for:
/// - session tracking
/// - analytics
/// - runtime tracing
/// - storing labeled or timestamped state observations
class StateSnapshot {
  /// The adaptive state captured by this snapshot.
  final AdaptiveState state;

  /// Optional timestamp associated with this snapshot.
  final DateTime? timestamp;

  /// Optional session identifier.
  final String? sessionId;

  /// Optional interaction identifier.
  final String? interactionId;

  /// Optional source label describing where the snapshot came from.
  ///
  /// Examples:
  /// - `runtime_input`
  /// - `normalized_state`
  /// - `session_summary`
  /// - `decision_trace`
  final String? source;

  /// Optional free-form note or label.
  final String? note;

  /// Creates a state snapshot.
  const StateSnapshot({
    required this.state,
    this.timestamp,
    this.sessionId,
    this.interactionId,
    this.source,
    this.note,
  });

  /// Creates a snapshot from a generic map.
  ///
  /// Expected keys:
  /// - `state` (required)
  /// - `timestamp` (optional ISO-8601 string)
  /// - `sessionId` (optional)
  /// - `interactionId` (optional)
  /// - `source` (optional)
  /// - `note` (optional)
  factory StateSnapshot.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('state')) {
      throw const FormatException(
        'Missing required StateSnapshot field: state',
      );
    }

    final stateValue = map['state'];
    if (stateValue is! Map<String, dynamic>) {
      throw FormatException(
        'StateSnapshot field "state" must be a Map<String, dynamic>, '
            'but got ${stateValue.runtimeType}.',
      );
    }

    final timestampValue = map['timestamp'];
    final sessionIdValue = map['sessionId'];
    final interactionIdValue = map['interactionId'];
    final sourceValue = map['source'];
    final noteValue = map['note'];

    DateTime? timestamp;
    if (timestampValue != null) {
      if (timestampValue is! String) {
        throw FormatException(
          'StateSnapshot field "timestamp" must be a String when provided, '
              'but got ${timestampValue.runtimeType}.',
        );
      }

      timestamp = DateTime.tryParse(timestampValue);
      if (timestamp == null) {
        throw const FormatException(
          'StateSnapshot field "timestamp" must be a valid ISO-8601 string.',
        );
      }
    }

    if (sessionIdValue != null && sessionIdValue is! String) {
      throw FormatException(
        'StateSnapshot field "sessionId" must be a String when provided, '
            'but got ${sessionIdValue.runtimeType}.',
      );
    }

    if (interactionIdValue != null && interactionIdValue is! String) {
      throw FormatException(
        'StateSnapshot field "interactionId" must be a String when provided, '
            'but got ${interactionIdValue.runtimeType}.',
      );
    }

    if (sourceValue != null && sourceValue is! String) {
      throw FormatException(
        'StateSnapshot field "source" must be a String when provided, '
            'but got ${sourceValue.runtimeType}.',
      );
    }

    if (noteValue != null && noteValue is! String) {
      throw FormatException(
        'StateSnapshot field "note" must be a String when provided, '
            'but got ${noteValue.runtimeType}.',
      );
    }

    return StateSnapshot(
      state: AdaptiveState.fromMap(stateValue),
      timestamp: timestamp,
      sessionId: sessionIdValue as String?,
      interactionId: interactionIdValue as String?,
      source: sourceValue as String?,
      note: noteValue as String?,
    );
  }

  /// Returns this snapshot as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'state': state.toMap(),
      'timestamp': timestamp?.toIso8601String(),
      'sessionId': sessionId,
      'interactionId': interactionId,
      'source': source,
      'note': note,
    };
  }

  /// Returns a copy of this snapshot with selected values replaced.
  StateSnapshot copyWith({
    AdaptiveState? state,
    DateTime? timestamp,
    String? sessionId,
    String? interactionId,
    String? source,
    String? note,
  }) {
    return StateSnapshot(
      state: state ?? this.state,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      interactionId: interactionId ?? this.interactionId,
      source: source ?? this.source,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'StateSnapshot('
        'state: $state, '
        'timestamp: $timestamp, '
        'sessionId: $sessionId, '
        'interactionId: $interactionId, '
        'source: $source, '
        'note: $note'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StateSnapshot &&
            other.state == state &&
            other.timestamp == timestamp &&
            other.sessionId == sessionId &&
            other.interactionId == interactionId &&
            other.source == source &&
            other.note == note);
  }

  @override
  int get hashCode {
    return Object.hash(
      state,
      timestamp,
      sessionId,
      interactionId,
      source,
      note,
    );
  }
}