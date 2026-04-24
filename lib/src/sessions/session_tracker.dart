import '../domain/recommendations/adaptive_recommendation.dart';
import '../domain/sessions/interaction_event.dart';
import '../domain/sessions/session_snapshot.dart';
import '../domain/sessions/session_statistics.dart';
import '../domain/sessions/task_outcome.dart';
import '../domain/state/state_snapshot.dart';
import 'interaction_accumulator.dart';

/// Tracks live session state, interaction history, and the latest adaptive
/// outputs for a single session.
///
/// This class is intended to support:
/// - runtime session progression
/// - snapshot updates
/// - recommendation tracking
/// - session-level aggregation
class SessionTracker {
  /// Creates a session tracker.
  SessionTracker({
    required this.sessionId,
    this.accumulator = const InteractionAccumulator(),
    List<InteractionEvent> initialInteractions = const <InteractionEvent>[],
    StateSnapshot? initialState,
    AdaptiveRecommendation? initialRecommendation,
    String? note,
  })  : _interactions = List<InteractionEvent>.from(initialInteractions),
        _currentState = initialState,
        _latestRecommendation = initialRecommendation,
        _note = note;

  /// Stable session identifier.
  final String sessionId;

  /// Accumulator used to derive session-level statistics.
  final InteractionAccumulator accumulator;

  final List<InteractionEvent> _interactions;
  StateSnapshot? _currentState;
  AdaptiveRecommendation? _latestRecommendation;
  String? _note;

  /// Returns an immutable view of recorded interactions.
  List<InteractionEvent> get interactions =>
      List<InteractionEvent>.unmodifiable(_interactions);

  /// Returns the current state snapshot, if available.
  StateSnapshot? get currentState => _currentState;

  /// Returns the latest recommendation, if available.
  AdaptiveRecommendation? get latestRecommendation => _latestRecommendation;

  /// Returns the latest interaction, if available.
  InteractionEvent? get latestInteraction =>
      accumulator.latestInteraction(_interactions);

  /// Returns the latest task outcome, if available.
  TaskOutcome? get latestOutcome => accumulator.latestOutcome(_interactions);

  /// Returns the current interaction count.
  int get interactionCount => _interactions.length;

  /// Returns whether any interactions have been recorded.
  bool get hasInteractions => _interactions.isNotEmpty;

  /// Returns whether a current state snapshot is available.
  bool get hasCurrentState => _currentState != null;

  /// Returns whether a latest recommendation is available.
  bool get hasLatestRecommendation => _latestRecommendation != null;

  /// Appends a new interaction to the session history.
  void recordInteraction(InteractionEvent interaction) {
    if (interaction.sessionId != sessionId) {
      throw FormatException(
        'Interaction sessionId "${interaction.sessionId}" does not match '
            'tracker sessionId "$sessionId".',
      );
    }

    _interactions.add(interaction);
  }

  /// Appends multiple interactions to the session history.
  void recordInteractions(List<InteractionEvent> interactions) {
    for (final interaction in interactions) {
      recordInteraction(interaction);
    }
  }

  /// Updates the current adaptive state snapshot.
  void updateCurrentState(StateSnapshot stateSnapshot) {
    if (stateSnapshot.sessionId != null &&
        stateSnapshot.sessionId != sessionId) {
      throw FormatException(
        'StateSnapshot sessionId "${stateSnapshot.sessionId}" does not match '
            'tracker sessionId "$sessionId".',
      );
    }

    _currentState = stateSnapshot;
  }

  /// Updates the latest adaptive recommendation.
  void updateRecommendation(AdaptiveRecommendation recommendation) {
    _latestRecommendation = recommendation;
  }

  /// Updates the tracker note.
  void updateNote(String? note) {
    _note = note;
  }

  /// Clears all recorded interactions.
  void clearInteractions() {
    _interactions.clear();
  }

  /// Builds a fresh [SessionStatistics] object from the current interaction
  /// history.
  SessionStatistics buildStatistics() {
    return accumulator.buildStatistics(_interactions);
  }

  /// Builds a [SessionSnapshot] representing the current session state.
  SessionSnapshot buildSnapshot() {
    return SessionSnapshot(
      sessionId: sessionId,
      currentState: _currentState,
      latestInteraction: latestInteraction,
      latestOutcome: latestOutcome,
      statistics: hasInteractions ? buildStatistics() : null,
      latestRecommendation: _latestRecommendation,
      interactionCount: _interactions.length,
      startedAt: accumulator.startedAt(_interactions),
      updatedAt: accumulator.endedAt(_interactions),
      note: _note,
    );
  }

  @override
  String toString() {
    return 'SessionTracker('
        'sessionId: $sessionId, '
        'interactionCount: ${_interactions.length}, '
        'currentState: $_currentState, '
        'latestRecommendation: $_latestRecommendation, '
        'note: $_note'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SessionTracker &&
            other.sessionId == sessionId &&
            _listEquals(other._interactions, _interactions) &&
            other._currentState == _currentState &&
            other._latestRecommendation == _latestRecommendation &&
            other._note == _note);
  }

  @override
  int get hashCode {
    return Object.hash(
      sessionId,
      Object.hashAll(_interactions),
      _currentState,
      _latestRecommendation,
      _note,
    );
  }

  static bool _listEquals(
      List<InteractionEvent> a,
      List<InteractionEvent> b,
      ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}