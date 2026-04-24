import '../domain/analytics/decision_trace.dart';
import '../domain/decisions/adaptive_decision.dart';
import '../domain/decisions/decision_context.dart';
import '../domain/recommendations/adaptive_recommendation.dart';
import '../domain/transitions/difficulty_transition.dart';
import '../gamification/difficulty_transition_resolver.dart';
import '../gamification/recommendation_builder.dart';

/// Builds [DecisionTrace] objects from runtime decision components.
///
/// This builder centralizes trace construction so the library can generate
/// consistent, explainable decision records for:
/// - debugging
/// - analytics
/// - replay
/// - research-oriented tracing
class DecisionTraceBuilder {
  /// Creates a decision-trace builder.
  const DecisionTraceBuilder({
    this.transitionResolver = const DifficultyTransitionResolver(),
    this.recommendationBuilder = const RecommendationBuilder(),
  });

  /// Resolver used to derive difficulty transitions when not provided.
  final DifficultyTransitionResolver transitionResolver;

  /// Builder used to derive recommendations when not provided.
  final RecommendationBuilder recommendationBuilder;

  /// Builds a [DecisionTrace] from the provided runtime data.
  ///
  /// If [transition] is not provided, the builder will try to derive it from
  /// [decision].
  ///
  /// If [recommendation] is not provided, the builder will create one from the
  /// available decision data.
  DecisionTrace build({
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
    final resolvedTransition = transition ??
        transitionResolver.resolve(
          decision,
          currentDifficultyRank: currentDifficultyRank,
        );

    final resolvedRecommendation = recommendation ??
        recommendationBuilder.build(
          decision,
          context: context,
          transition: resolvedTransition,
          currentDifficultyRank: currentDifficultyRank,
        );

    return DecisionTrace(
      traceId: traceId ?? _buildTraceId(decision, context),
      decision: decision,
      context: context,
      transition: resolvedTransition,
      recommendation: resolvedRecommendation,
      warnings: List<String>.unmodifiable(warnings),
      note: note,
      timestamp: timestamp,
    );
  }

  String _buildTraceId(
      AdaptiveDecision decision,
      DecisionContext context,
      ) {
    return 'trace_${decision.source}_${decision.nextDifficulty}_${context.generatedStateKey}';
  }

  @override
  String toString() {
    return 'DecisionTraceBuilder('
        'transitionResolver: $transitionResolver, '
        'recommendationBuilder: $recommendationBuilder'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DecisionTraceBuilder &&
            other.transitionResolver == transitionResolver &&
            other.recommendationBuilder == recommendationBuilder);
  }

  @override
  int get hashCode => Object.hash(
    transitionResolver,
    recommendationBuilder,
  );
}