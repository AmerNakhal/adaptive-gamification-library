import 'gamification_labels.dart';
import 'support_strategy_mapper.dart';

/// Maps adaptive actions and support strategies into pedagogical effects.
///
/// This mapper helps expose the intended educational or behavioral effect of a
/// runtime adaptive decision in a developer-facing and analytics-friendly way.
class PedagogicalEffectMapper {
  /// Mapper used when pedagogical effect is derived from support strategy.
  final SupportStrategyMapper supportStrategyMapper;

  /// Creates a pedagogical-effect mapper.
  const PedagogicalEffectMapper({
    this.supportStrategyMapper = const SupportStrategyMapper(),
  });

  /// Returns the pedagogical effect for [actionLabel].
  ///
  /// If [actionLabel] is null, empty, or unsupported, a sensible maintenance
  /// effect is returned.
  String mapActionLabelToPedagogicalEffect(String? actionLabel) {
    final normalized = GamificationLabels.normalizeActionLabel(actionLabel);

    switch (normalized) {
      case GamificationLabels.rest:
        return GamificationLabels.recoverySupport;

      case GamificationLabels.easyTask:
        return GamificationLabels.difficultyReduction;

      case GamificationLabels.mediumTask:
        return GamificationLabels.difficultyMaintenance;

      case GamificationLabels.hardTask:
        return GamificationLabels.difficultyIncrease;

      case GamificationLabels.motivationBoost:
        return GamificationLabels.motivationalReinforcement;

      case GamificationLabels.flowTask:
        return GamificationLabels.flowAlignment;
    }

    return GamificationLabels.difficultyMaintenance;
  }

  /// Returns the pedagogical effect for [supportStrategy].
  ///
  /// If [supportStrategy] is null, empty, or unsupported, a sensible
  /// maintenance effect is returned.
  String mapSupportStrategyToPedagogicalEffect(String? supportStrategy) {
    final normalized =
    GamificationLabels.normalizeSupportStrategy(supportStrategy);

    switch (normalized) {
      case GamificationLabels.reducePressure:
        return GamificationLabels.difficultyReduction;

      case GamificationLabels.maintainChallenge:
        return GamificationLabels.difficultyMaintenance;

      case GamificationLabels.increaseChallenge:
        return GamificationLabels.difficultyIncrease;

      case GamificationLabels.encouragePersistence:
        return GamificationLabels.motivationalReinforcement;

      case GamificationLabels.restoreFlow:
        return GamificationLabels.flowAlignment;

      case GamificationLabels.provideRecovery:
        return GamificationLabels.recoverySupport;
    }

    return GamificationLabels.difficultyMaintenance;
  }

  /// Returns the pedagogical effect from either [actionLabel] directly or
  /// [supportStrategy] when action-level information is unavailable.
  String map({
    String? actionLabel,
    String? supportStrategy,
  }) {
    if (actionLabel != null && actionLabel.trim().isNotEmpty) {
      return mapActionLabelToPedagogicalEffect(actionLabel);
    }

    if (supportStrategy != null && supportStrategy.trim().isNotEmpty) {
      return mapSupportStrategyToPedagogicalEffect(supportStrategy);
    }

    return GamificationLabels.difficultyMaintenance;
  }

  /// Returns the pedagogical effect for [actionLabel] by first mapping it to a
  /// support strategy, then mapping that strategy to a pedagogical effect.
  ///
  /// This is useful when callers want the support-strategy route explicitly.
  String mapViaSupportStrategy(String? actionLabel) {
    final strategy =
    supportStrategyMapper.mapActionLabelToSupportStrategy(actionLabel);
    return mapSupportStrategyToPedagogicalEffect(strategy);
  }

  /// Returns whether [actionLabel] implies motivational reinforcement.
  bool isMotivationalEffect(String? actionLabel) {
    return mapActionLabelToPedagogicalEffect(actionLabel) ==
        GamificationLabels.motivationalReinforcement;
  }

  /// Returns whether [actionLabel] implies flow alignment.
  bool isFlowEffect(String? actionLabel) {
    return mapActionLabelToPedagogicalEffect(actionLabel) ==
        GamificationLabels.flowAlignment;
  }

  /// Returns whether [actionLabel] implies recovery support.
  bool isRecoveryEffect(String? actionLabel) {
    return mapActionLabelToPedagogicalEffect(actionLabel) ==
        GamificationLabels.recoverySupport;
  }

  /// Returns whether [actionLabel] implies difficulty adjustment or
  /// maintenance.
  bool isDifficultyEffect(String? actionLabel) {
    final effect = mapActionLabelToPedagogicalEffect(actionLabel);
    return effect == GamificationLabels.difficultyReduction ||
        effect == GamificationLabels.difficultyMaintenance ||
        effect == GamificationLabels.difficultyIncrease;
  }

  @override
  String toString() {
    return 'PedagogicalEffectMapper('
        'supportStrategyMapper: $supportStrategyMapper'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PedagogicalEffectMapper &&
            other.supportStrategyMapper == supportStrategyMapper);
  }

  @override
  int get hashCode => supportStrategyMapper.hashCode;
}