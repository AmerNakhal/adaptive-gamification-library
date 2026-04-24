import '../domain/recommendations/adaptive_recommendation.dart';
import '../domain/sessions/adaptive_session_summary.dart';
import '../domain/sessions/interaction_event.dart';
import '../domain/sessions/session_statistics.dart';
import '../domain/transitions/difficulty_transition.dart';
import 'interaction_accumulator.dart';

/// Builds session summaries from interaction history and optional adaptive
/// outputs such as recommendations and difficulty transitions.
class SessionSummaryBuilder {
  /// Creates a session summary builder.
  const SessionSummaryBuilder({
    this.accumulator = const InteractionAccumulator(),
  });

  /// Accumulator used to derive session-level aggregate information.
  final InteractionAccumulator accumulator;

  /// Builds an [AdaptiveSessionSummary] from [interactions].
  ///
  /// Optional inputs:
  /// - [statistics]: provide precomputed statistics instead of deriving them
  /// - [overallTransition]: provide a session-level transition summary
  /// - [finalRecommendation]: provide the latest or final recommendation
  /// - [status]: provide a semantic session status
  /// - [note]: provide a free-form note
  /// - [tags]: provide machine-usable tags
  AdaptiveSessionSummary build({
    required List<InteractionEvent> interactions,
    SessionStatistics? statistics,
    DifficultyTransition? overallTransition,
    AdaptiveRecommendation? finalRecommendation,
    String? status,
    String? note,
    List<String> tags = const <String>[],
  }) {
    if (interactions.isEmpty) {
      throw const FormatException(
        'Cannot build AdaptiveSessionSummary from an empty interaction list.',
      );
    }

    final sessionId = interactions.first.sessionId;
    final derivedStatistics =
        statistics ?? accumulator.buildStatistics(interactions);
    final startedAt = accumulator.startedAt(interactions);
    final endedAt = accumulator.endedAt(interactions);

    return AdaptiveSessionSummary(
      sessionId: sessionId,
      statistics: derivedStatistics,
      overallTransition: overallTransition,
      finalRecommendation: finalRecommendation,
      startedAt: startedAt,
      endedAt: endedAt,
      status: status,
      note: note,
      tags: List<String>.unmodifiable(tags),
    );
  }

  @override
  String toString() {
    return 'SessionSummaryBuilder('
        'accumulator: $accumulator'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SessionSummaryBuilder && other.accumulator == accumulator);
  }

  @override
  int get hashCode => accumulator.hashCode;
}