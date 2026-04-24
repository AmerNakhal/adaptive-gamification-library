/// Canonical gamification-related labels used across the library.
abstract class GamificationLabels {
  // ---------------------------------------------------------------------------
  // Action labels
  // ---------------------------------------------------------------------------

  static const String rest = 'rest';
  static const String easyTask = 'easy_task';
  static const String mediumTask = 'medium_task';
  static const String hardTask = 'hard_task';
  static const String motivationBoost = 'motivation_boost';
  static const String flowTask = 'flow_task';

  /// Stable ordered list of supported action labels.
  static const List<String> actionLabels = <String>[
    rest,
    easyTask,
    mediumTask,
    hardTask,
    motivationBoost,
    flowTask,
  ];

  // ---------------------------------------------------------------------------
  // Action groups
  // ---------------------------------------------------------------------------

  static const String recoveryGroup = 'recovery';
  static const String challengeAdjustmentGroup = 'challenge_adjustment';
  static const String motivationalSupportGroup = 'motivational_support';
  static const String flowRegulationGroup = 'flow_regulation';

  /// Stable ordered list of supported action-group labels.
  static const List<String> actionGroups = <String>[
    recoveryGroup,
    challengeAdjustmentGroup,
    motivationalSupportGroup,
    flowRegulationGroup,
  ];

  // ---------------------------------------------------------------------------
  // Support strategies
  // ---------------------------------------------------------------------------

  static const String reducePressure = 'reduce_pressure';
  static const String maintainChallenge = 'maintain_challenge';
  static const String increaseChallenge = 'increase_challenge';
  static const String encouragePersistence = 'encourage_persistence';
  static const String restoreFlow = 'restore_flow';
  static const String provideRecovery = 'provide_recovery';

  /// Stable ordered list of supported support-strategy labels.
  static const List<String> supportStrategies = <String>[
    reducePressure,
    maintainChallenge,
    increaseChallenge,
    encouragePersistence,
    restoreFlow,
    provideRecovery,
  ];

  // ---------------------------------------------------------------------------
  // Pedagogical effects
  // ---------------------------------------------------------------------------

  static const String difficultyReduction = 'difficulty_reduction';
  static const String difficultyMaintenance = 'difficulty_maintenance';
  static const String difficultyIncrease = 'difficulty_increase';
  static const String motivationalReinforcement = 'motivational_reinforcement';
  static const String flowAlignment = 'flow_alignment';
  static const String recoverySupport = 'recovery_support';

  /// Stable ordered list of supported pedagogical-effect labels.
  static const List<String> pedagogicalEffects = <String>[
    difficultyReduction,
    difficultyMaintenance,
    difficultyIncrease,
    motivationalReinforcement,
    flowAlignment,
    recoverySupport,
  ];

  /// Returns whether [label] is a supported action label.
  static bool isSupportedActionLabel(String label) {
    return actionLabels.contains(label);
  }

  /// Returns whether [label] is a supported action-group label.
  static bool isSupportedActionGroup(String label) {
    return actionGroups.contains(label);
  }

  /// Returns whether [label] is a supported support-strategy label.
  static bool isSupportedSupportStrategy(String label) {
    return supportStrategies.contains(label);
  }

  /// Returns whether [label] is a supported pedagogical-effect label.
  static bool isSupportedPedagogicalEffect(String label) {
    return pedagogicalEffects.contains(label);
  }

  /// Normalizes an action label, defaulting to [mediumTask].
  static String normalizeActionLabel(String? label) {
    if (label == null) return mediumTask;
    final trimmed = label.trim();
    if (trimmed.isEmpty) return mediumTask;
    return isSupportedActionLabel(trimmed) ? trimmed : mediumTask;
  }

  /// Normalizes an action-group label, defaulting to [challengeAdjustmentGroup].
  static String normalizeActionGroup(String? label) {
    if (label == null) return challengeAdjustmentGroup;
    final trimmed = label.trim();
    if (trimmed.isEmpty) return challengeAdjustmentGroup;
    return isSupportedActionGroup(trimmed)
        ? trimmed
        : challengeAdjustmentGroup;
  }

  /// Normalizes a support-strategy label, defaulting to [maintainChallenge].
  static String normalizeSupportStrategy(String? label) {
    if (label == null) return maintainChallenge;
    final trimmed = label.trim();
    if (trimmed.isEmpty) return maintainChallenge;
    return isSupportedSupportStrategy(trimmed)
        ? trimmed
        : maintainChallenge;
  }

  /// Normalizes a pedagogical-effect label, defaulting to
  /// [difficultyMaintenance].
  static String normalizePedagogicalEffect(String? label) {
    if (label == null) return difficultyMaintenance;
    final trimmed = label.trim();
    if (trimmed.isEmpty) return difficultyMaintenance;
    return isSupportedPedagogicalEffect(trimmed)
        ? trimmed
        : difficultyMaintenance;
  }
}