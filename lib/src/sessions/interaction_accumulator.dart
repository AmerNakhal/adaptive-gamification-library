import '../domain/sessions/interaction_event.dart';
import '../domain/sessions/session_statistics.dart';
import '../domain/sessions/task_outcome.dart';
import '../utils/math_utils.dart';

/// Aggregates interaction events into session-level statistics and summaries.
///
/// This class provides lightweight accumulation logic over a list of
/// [InteractionEvent] objects.
class InteractionAccumulator {
  /// Creates an interaction accumulator.
  const InteractionAccumulator();

  /// Builds aggregated [SessionStatistics] from [interactions].
  SessionStatistics buildStatistics(List<InteractionEvent> interactions) {
    final immutableInteractions =
    List<InteractionEvent>.unmodifiable(interactions);

    final outcomes = immutableInteractions
        .map((event) => event.outcome)
        .whereType<TaskOutcome>()
        .toList(growable: false);

    final successfulCount =
        outcomes.where((outcome) => outcome.wasSuccessful).length;
    final unsuccessfulCount =
        outcomes.where((outcome) => !outcome.wasSuccessful).length;

    final scores = outcomes
        .map((outcome) => outcome.score)
        .whereType<double>()
        .toList(growable: false);

    final responseTimes = immutableInteractions
        .map((event) => event.responseTime)
        .whereType<double>()
        .toList(growable: false);

    final streaks = immutableInteractions
        .map((event) => event.streak)
        .whereType<double>()
        .toList(growable: false);

    final difficultyRanks = immutableInteractions
        .map((event) => event.difficultyRank)
        .whereType<int>()
        .toList(growable: false);

    final retryCounts = outcomes
        .map((outcome) => outcome.retryCount)
        .whereType<int>()
        .toList(growable: false);

    final totalRetryCount = retryCounts.isEmpty
        ? null
        : retryCounts.fold<int>(0, (acc, value) => acc + value);

    return SessionStatistics(
      interactionCount: immutableInteractions.length,
      successfulCount: successfulCount,
      unsuccessfulCount: unsuccessfulCount,
      averageScore: MathUtils.mean(scores),
      averageResponseTime: MathUtils.mean(responseTimes),
      averageStreak: MathUtils.mean(streaks),
      averageDifficultyRank: difficultyRanks.isEmpty
          ? null
          : MathUtils.mean(
        difficultyRanks.map((value) => value.toDouble()),
      ),
      minDifficultyRank: difficultyRanks.isEmpty
          ? null
          : difficultyRanks.reduce((a, b) => a < b ? a : b),
      maxDifficultyRank: difficultyRanks.isEmpty
          ? null
          : difficultyRanks.reduce((a, b) => a > b ? a : b),
      totalRetryCount: totalRetryCount,
    );
  }

  /// Returns the most recent interaction from [interactions], or null if empty.
  InteractionEvent? latestInteraction(List<InteractionEvent> interactions) {
    if (interactions.isEmpty) return null;
    return interactions.last;
  }

  /// Returns the most recent task outcome from [interactions], or null if none
  /// are available.
  TaskOutcome? latestOutcome(List<InteractionEvent> interactions) {
    for (var i = interactions.length - 1; i >= 0; i--) {
      final outcome = interactions[i].outcome;
      if (outcome != null) {
        return outcome;
      }
    }
    return null;
  }

  /// Returns the earliest timestamp found in [interactions], or null if none.
  DateTime? startedAt(List<InteractionEvent> interactions) {
    final timestamps = interactions
        .map((event) => event.timestamp)
        .whereType<DateTime>()
        .toList(growable: false);

    if (timestamps.isEmpty) return null;

    return timestamps.reduce(
          (a, b) => a.isBefore(b) ? a : b,
    );
  }

  /// Returns the latest timestamp found in [interactions], or null if none.
  DateTime? endedAt(List<InteractionEvent> interactions) {
    final timestamps = interactions
        .map((event) => event.timestamp)
        .whereType<DateTime>()
        .toList(growable: false);

    if (timestamps.isEmpty) return null;

    return timestamps.reduce(
          (a, b) => a.isAfter(b) ? a : b,
    );
  }

  /// Returns whether [interactions] are all associated with the same session.
  bool hasConsistentSessionId(List<InteractionEvent> interactions) {
    if (interactions.isEmpty) return true;

    final sessionId = interactions.first.sessionId;
    return interactions.every((event) => event.sessionId == sessionId);
  }

  @override
  String toString() => 'InteractionAccumulator()';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is InteractionAccumulator;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}