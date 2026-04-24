import 'gamification_labels.dart';

/// Maps action labels into higher-level gamification action groups.
///
/// This mapper provides a stable semantic grouping layer so the library can
/// reason about adaptive actions even when only low-level action labels are
/// available.
class ActionGroupMapper {
  /// Creates an action-group mapper.
  const ActionGroupMapper();

  /// Returns the semantic action group for [actionLabel].
  ///
  /// If [actionLabel] is null, empty, or unsupported, a sensible default
  /// challenge-adjustment group is returned.
  String mapActionLabelToGroup(String? actionLabel) {
    final normalized = GamificationLabels.normalizeActionLabel(actionLabel);

    switch (normalized) {
      case GamificationLabels.rest:
        return GamificationLabels.recoveryGroup;

      case GamificationLabels.easyTask:
      case GamificationLabels.mediumTask:
      case GamificationLabels.hardTask:
        return GamificationLabels.challengeAdjustmentGroup;

      case GamificationLabels.motivationBoost:
        return GamificationLabels.motivationalSupportGroup;

      case GamificationLabels.flowTask:
        return GamificationLabels.flowRegulationGroup;
    }

    return GamificationLabels.challengeAdjustmentGroup;
  }

  /// Returns whether [actionLabel] maps to the recovery group.
  bool isRecoveryAction(String? actionLabel) {
    return mapActionLabelToGroup(actionLabel) ==
        GamificationLabels.recoveryGroup;
  }

  /// Returns whether [actionLabel] maps to the challenge-adjustment group.
  bool isChallengeAdjustmentAction(String? actionLabel) {
    return mapActionLabelToGroup(actionLabel) ==
        GamificationLabels.challengeAdjustmentGroup;
  }

  /// Returns whether [actionLabel] maps to the motivational-support group.
  bool isMotivationalSupportAction(String? actionLabel) {
    return mapActionLabelToGroup(actionLabel) ==
        GamificationLabels.motivationalSupportGroup;
  }

  /// Returns whether [actionLabel] maps to the flow-regulation group.
  bool isFlowRegulationAction(String? actionLabel) {
    return mapActionLabelToGroup(actionLabel) ==
        GamificationLabels.flowRegulationGroup;
  }

  @override
  String toString() => 'ActionGroupMapper()';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is ActionGroupMapper;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}