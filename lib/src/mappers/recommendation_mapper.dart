import '../domain/recommendations/adaptive_recommendation.dart';

/// High-level helper for mapping adaptive recommendations into lightweight
/// application-facing representations.
///
/// This mapper is useful for:
/// - UI integration
/// - logging
/// - lightweight summaries
/// - analytics/export helpers
class RecommendationMapper {
  /// Creates a recommendation mapper.
  const RecommendationMapper();

  /// Returns a serializable map representation of [recommendation].
  Map<String, dynamic> toMap(AdaptiveRecommendation recommendation) {
    return recommendation.toMap();
  }

  /// Returns a lightweight display-oriented map for [recommendation].
  ///
  /// This is intentionally flatter than the full domain object and is useful
  /// for UI layers that need a concise representation.
  Map<String, dynamic> toDisplayMap(AdaptiveRecommendation recommendation) {
    return <String, dynamic>{
      'id': recommendation.id,
      'type': recommendation.type,
      'priority': recommendation.priority,
      'title': recommendation.title,
      'message': recommendation.message,
      'actionGroup': recommendation.actionGroup,
      'supportStrategy': recommendation.supportStrategy,
      'pedagogicalEffect': recommendation.pedagogicalEffect,
      'nextDifficulty': recommendation.decision.nextDifficulty,
      'actionLabel': recommendation.decision.actionLabel,
      'source': recommendation.decision.source,
      'hasTransition': recommendation.hasTransition,
      'tags': recommendation.tags,
    };
  }

  /// Returns a concise human-readable summary for [recommendation].
  String toSummary(AdaptiveRecommendation recommendation) {
    final buffer = StringBuffer()
      ..write(recommendation.title)
      ..write(' — ')
      ..write(recommendation.message);

    final nextDifficulty = recommendation.decision.nextDifficulty;
    buffer.write(' (nextDifficulty: $nextDifficulty');

    final actionLabel = recommendation.decision.actionLabel;
    if (actionLabel != null && actionLabel.trim().isNotEmpty) {
      buffer.write(', action: $actionLabel');
    }

    buffer.write(')');

    return buffer.toString();
  }

  /// Returns unique normalized tags for [recommendation].
  List<String> toDistinctTags(AdaptiveRecommendation recommendation) {
    final seen = <String>{};
    final result = <String>[];

    for (final tag in recommendation.tags) {
      final normalized = tag.trim();
      if (normalized.isEmpty) continue;
      if (seen.add(normalized)) {
        result.add(normalized);
      }
    }

    return List<String>.unmodifiable(result);
  }

  @override
  String toString() => 'RecommendationMapper()';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is RecommendationMapper;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}