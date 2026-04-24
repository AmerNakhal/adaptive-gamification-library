import '../domain/decisions/adaptive_decision.dart';
import '../domain/transitions/difficulty_transition.dart';

/// Resolves semantic difficulty transitions from adaptive decisions.
///
/// This resolver centralizes how the library derives a [DifficultyTransition]
/// from runtime decision information.
class DifficultyTransitionResolver {
  /// Creates a difficulty-transition resolver.
  const DifficultyTransitionResolver();

  /// Resolves a difficulty transition from [decision].
  ///
  /// Resolution strategy:
  /// 1. Prefer rich decision details if both before/after ranks are available.
  /// 2. Otherwise use [currentDifficultyRank] together with
  ///    [decision.nextDifficulty] if possible.
  /// 3. Return null if a transition cannot be derived safely.
  DifficultyTransition? resolve(
      AdaptiveDecision decision, {
        int? currentDifficultyRank,
      }) {
    final details = decision.details;

    final beforeFromDetails = details?.difficultyRankBefore;
    final afterFromDetails = details?.difficultyRankAfter;

    if (beforeFromDetails != null && afterFromDetails != null) {
      return DifficultyTransition.fromRanks(
        beforeRank: beforeFromDetails,
        afterRank: afterFromDetails,
      );
    }

    if (currentDifficultyRank != null) {
      return DifficultyTransition.fromRanks(
        beforeRank: currentDifficultyRank,
        afterRank: decision.nextDifficulty,
      );
    }

    return null;
  }

  /// Resolves a transition directly from [beforeRank] and [afterRank].
  DifficultyTransition resolveFromRanks({
    required int beforeRank,
    required int afterRank,
  }) {
    return DifficultyTransition.fromRanks(
      beforeRank: beforeRank,
      afterRank: afterRank,
    );
  }

  /// Returns whether a transition can be resolved from [decision] and the
  /// optional [currentDifficultyRank].
  bool canResolve(
      AdaptiveDecision decision, {
        int? currentDifficultyRank,
      }) {
    final details = decision.details;

    final hasDetailRanks =
        details?.difficultyRankBefore != null &&
            details?.difficultyRankAfter != null;

    return hasDetailRanks || currentDifficultyRank != null;
  }

  @override
  String toString() => 'DifficultyTransitionResolver()';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is DifficultyTransitionResolver;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}