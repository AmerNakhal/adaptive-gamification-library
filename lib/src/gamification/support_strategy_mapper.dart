import 'action_group_mapper.dart';
import 'gamification_labels.dart';

/// Maps action labels and action groups into higher-level support strategies.
///
/// This mapper helps translate low-level adaptive actions into developer-facing
/// semantic strategies that can be used in recommendations, analytics, and UI.
class SupportStrategyMapper {
  /// Mapper used to derive action groups from action labels when needed.
  final ActionGroupMapper actionGroupMapper;

  /// Creates a support-strategy mapper.
  const SupportStrategyMapper({
    this.actionGroupMapper = const ActionGroupMapper(),
  });

  /// Returns the semantic support strategy for [actionLabel].
  ///
  /// If [actionLabel] is null, empty, or unsupported, a sensible default
  /// maintenance strategy is returned.
  String mapActionLabelToSupportStrategy(String? actionLabel) {
    final normalized = GamificationLabels.normalizeActionLabel(actionLabel);

    switch (normalized) {
      case GamificationLabels.rest:
        return GamificationLabels.provideRecovery;

      case GamificationLabels.easyTask:
        return GamificationLabels.reducePressure;

      case GamificationLabels.mediumTask:
        return GamificationLabels.maintainChallenge;

      case GamificationLabels.hardTask:
        return GamificationLabels.increaseChallenge;

      case GamificationLabels.motivationBoost:
        return GamificationLabels.encouragePersistence;

      case GamificationLabels.flowTask:
        return GamificationLabels.restoreFlow;
    }

    return GamificationLabels.maintainChallenge;
  }

  /// Returns the semantic support strategy for [actionGroup].
  ///
  /// If [actionGroup] is null, empty, or unsupported, a sensible default
  /// maintenance strategy is returned.
  String mapActionGroupToSupportStrategy(String? actionGroup) {
    final normalized = GamificationLabels.normalizeActionGroup(actionGroup);

    switch (normalized) {
      case GamificationLabels.recoveryGroup:
        return GamificationLabels.provideRecovery;

      case GamificationLabels.challengeAdjustmentGroup:
        return GamificationLabels.maintainChallenge;

      case GamificationLabels.motivationalSupportGroup:
        return GamificationLabels.encouragePersistence;

      case GamificationLabels.flowRegulationGroup:
        return GamificationLabels.restoreFlow;
    }

    return GamificationLabels.maintainChallenge;
  }

  /// Returns the semantic support strategy for either [actionLabel] directly,
  /// or via its derived action group when needed.
  String map({
    String? actionLabel,
    String? actionGroup,
  }) {
    if (actionLabel != null && actionLabel.trim().isNotEmpty) {
      return mapActionLabelToSupportStrategy(actionLabel);
    }

    if (actionGroup != null && actionGroup.trim().isNotEmpty) {
      return mapActionGroupToSupportStrategy(actionGroup);
    }

    return GamificationLabels.maintainChallenge;
  }

  /// Returns the semantic support strategy for [actionLabel] by first deriving
  /// an action group and then mapping it.
  ///
  /// This is useful when a caller wants the grouping route explicitly.
  String mapViaActionGroup(String? actionLabel) {
    final group = actionGroupMapper.mapActionLabelToGroup(actionLabel);
    return mapActionGroupToSupportStrategy(group);
  }

  /// Returns whether [actionLabel] implies a recovery-oriented strategy.
  bool isRecoveryStrategy(String? actionLabel) {
    return mapActionLabelToSupportStrategy(actionLabel) ==
        GamificationLabels.provideRecovery;
  }

  /// Returns whether [actionLabel] implies a flow-restoration strategy.
  bool isFlowSupportStrategy(String? actionLabel) {
    return mapActionLabelToSupportStrategy(actionLabel) ==
        GamificationLabels.restoreFlow;
  }

  /// Returns whether [actionLabel] implies a motivational-support strategy.
  bool isMotivationalStrategy(String? actionLabel) {
    return mapActionLabelToSupportStrategy(actionLabel) ==
        GamificationLabels.encouragePersistence;
  }

  /// Returns whether [actionLabel] implies a challenge-maintenance or
  /// challenge-adjustment strategy.
  bool isChallengeStrategy(String? actionLabel) {
    final strategy = mapActionLabelToSupportStrategy(actionLabel);
    return strategy == GamificationLabels.reducePressure ||
        strategy == GamificationLabels.maintainChallenge ||
        strategy == GamificationLabels.increaseChallenge;
  }

  @override
  String toString() {
    return 'SupportStrategyMapper('
        'actionGroupMapper: $actionGroupMapper'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SupportStrategyMapper &&
            other.actionGroupMapper == actionGroupMapper);
  }

  @override
  int get hashCode => actionGroupMapper.hashCode;
}