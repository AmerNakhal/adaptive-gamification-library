import '../domain/recommendations/adaptive_recommendation.dart';
import '../domain/sessions/adaptive_session_summary.dart';
import '../domain/sessions/interaction_event.dart';
import '../domain/sessions/session_snapshot.dart';
import '../domain/sessions/session_statistics.dart';
import '../domain/transitions/difficulty_transition.dart';
import '../exceptions/session_evaluation_exception.dart';
import 'interaction_accumulator.dart';
import 'session_summary_builder.dart';
import 'session_tracker.dart';

/// Evaluates adaptive session state and builds session-level outputs.
///
/// This class provides higher-level orchestration for:
/// - validating session interaction consistency
/// - producing live session snapshots
/// - producing summarized session reports
class SessionEvaluator {
  /// Creates a session evaluator.
  const SessionEvaluator({
    this.accumulator = const InteractionAccumulator(),
    this.summaryBuilder = const SessionSummaryBuilder(),
  });

  /// Accumulator used to derive aggregate interaction information.
  final InteractionAccumulator accumulator;

  /// Builder used to construct session summaries.
  final SessionSummaryBuilder summaryBuilder;

  /// Returns whether [interactions] are valid for session-level evaluation.
  ///
  /// Current checks:
  /// - non-empty list
  /// - consistent session IDs
  bool canEvaluate(List<InteractionEvent> interactions) {
    if (interactions.isEmpty) return false;
    return accumulator.hasConsistentSessionId(interactions);
  }

  /// Validates [interactions] and throws if session-level evaluation should not
  /// proceed.
  void validateInteractions(List<InteractionEvent> interactions) {
    if (interactions.isEmpty) {
      throw const SessionEvaluationException(
        'Cannot evaluate an empty interaction list.',
      );
    }

    if (!accumulator.hasConsistentSessionId(interactions)) {
      throw const SessionEvaluationException(
        'Cannot evaluate interactions with inconsistent session IDs.',
      );
    }
  }

  /// Builds a live [SessionSnapshot] from [tracker].
  SessionSnapshot evaluateTracker(SessionTracker tracker) {
    return tracker.buildSnapshot();
  }

  /// Builds [SessionStatistics] from [interactions].
  SessionStatistics evaluateStatistics(List<InteractionEvent> interactions) {
    validateInteractions(interactions);
    return accumulator.buildStatistics(interactions);
  }

  /// Builds an [AdaptiveSessionSummary] from [interactions].
  AdaptiveSessionSummary evaluateSummary({
    required List<InteractionEvent> interactions,
    DifficultyTransition? overallTransition,
    AdaptiveRecommendation? finalRecommendation,
    String? status,
    String? note,
    List<String> tags = const <String>[],
  }) {
    validateInteractions(interactions);

    return summaryBuilder.build(
      interactions: interactions,
      overallTransition: overallTransition,
      finalRecommendation: finalRecommendation,
      status: status,
      note: note,
      tags: tags,
    );
  }

  /// Builds an [AdaptiveSessionSummary] directly from a [tracker].
  AdaptiveSessionSummary evaluateTrackerSummary({
    required SessionTracker tracker,
    DifficultyTransition? overallTransition,
    String? status,
    List<String> tags = const <String>[],
  }) {
    if (!tracker.hasInteractions) {
      throw const SessionEvaluationException(
        'Cannot build a session summary from a tracker with no interactions.',
      );
    }

    return evaluateSummary(
      interactions: tracker.interactions,
      overallTransition: overallTransition,
      finalRecommendation: tracker.latestRecommendation,
      status: status,
      tags: tags,
    );
  }

  @override
  String toString() {
    return 'SessionEvaluator('
        'accumulator: $accumulator, '
        'summaryBuilder: $summaryBuilder'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SessionEvaluator &&
            other.accumulator == accumulator &&
            other.summaryBuilder == summaryBuilder);
  }

  @override
  int get hashCode => Object.hash(accumulator, summaryBuilder);
}