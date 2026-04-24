import '../analytics/decision_trace_builder.dart';
import '../domain/analytics/decision_trace.dart';
import '../domain/decisions/adaptive_decision.dart';
import '../domain/decisions/decision_context.dart';
import '../domain/recommendations/adaptive_recommendation.dart';
import '../domain/transitions/difficulty_transition.dart';
import '../gamification/difficulty_transition_resolver.dart';
import '../gamification/recommendation_builder.dart';

/// High-level helper for mapping adaptive decisions into richer library outputs.
///
/// This mapper provides a single consistent entry point for converting
/// low-level runtime decisions into:
/// - difficulty transitions
/// - adaptive recommendations
/// - decision traces
class DecisionMapper {
  /// Resolver used to derive difficulty transitions.
  final DifficultyTransitionResolver transitionResolver;

  /// Builder used to derive adaptive recommendations.
  final RecommendationBuilder recommendationBuilder;

  /// Builder used to derive decision traces.
  final DecisionTraceBuilder decisionTraceBuilder;

  /// Creates a decision mapper.
  const DecisionMapper({
    this.transitionResolver = const DifficultyTransitionResolver(),
    this.recommendationBuilder = const RecommendationBuilder(),
    this.decisionTraceBuilder = const DecisionTraceBuilder(),
  });

  /// Maps [decision] into a [DifficultyTransition], if one can be derived.
  DifficultyTransition? toTransition(
      AdaptiveDecision decision, {
        int? currentDifficultyRank,
      }) {
    return transitionResolver.resolve(
      decision,
      currentDifficultyRank: currentDifficultyRank,
    );
  }

  /// Maps [decision] into an [AdaptiveRecommendation].
  AdaptiveRecommendation toRecommendation(
      AdaptiveDecision decision, {
        DecisionContext? context,
        DifficultyTransition? transition,
        int? currentDifficultyRank,
        String? recommendationId,
      }) {
    return recommendationBuilder.build(
      decision,
      context: context,
      transition: transition,
      currentDifficultyRank: currentDifficultyRank,
      recommendationId: recommendationId,
    );
  }

  /// Maps [decision] and [context] into a [DecisionTrace].
  DecisionTrace toDecisionTrace({
    required AdaptiveDecision decision,
    required DecisionContext context,
    DifficultyTransition? transition,
    AdaptiveRecommendation? recommendation,
    int? currentDifficultyRank,
    String? traceId,
    List<String> warnings = const <String>[],
    String? note,
    DateTime? timestamp,
  }) {
    return decisionTraceBuilder.build(
      decision: decision,
      context: context,
      transition: transition,
      recommendation: recommendation,
      currentDifficultyRank: currentDifficultyRank,
      traceId: traceId,
      warnings: warnings,
      note: note,
      timestamp: timestamp,
    );
  }

  @override
  String toString() {
    return 'DecisionMapper('
        'transitionResolver: $transitionResolver, '
        'recommendationBuilder: $recommendationBuilder, '
        'decisionTraceBuilder: $decisionTraceBuilder'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DecisionMapper &&
            other.transitionResolver == transitionResolver &&
            other.recommendationBuilder == recommendationBuilder &&
            other.decisionTraceBuilder == decisionTraceBuilder);
  }

  @override
  int get hashCode => Object.hash(
    transitionResolver,
    recommendationBuilder,
    decisionTraceBuilder,
  );
}