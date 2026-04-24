import '../domain/state/state_dimension_labels.dart';

/// Defines the supported exported-policy contract used by the runtime layer.
///
/// This class centralizes:
/// - canonical field names
/// - supported alias names from Python exports
/// - top-level supported structures
/// - known decision payload fields
///
/// It exists to keep loader/validator code cleaner and to make the policy
/// contract explicit and documentable.
abstract class PolicyContract {
  // ---------------------------------------------------------------------------
  // Top-level fields
  // ---------------------------------------------------------------------------

  /// Canonical top-level metadata field.
  static const String metadata = 'metadata';

  /// Canonical top-level normalized entries field.
  static const String entries = 'entries';

  /// Canonical top-level Python-style policy map field.
  static const String policy = 'policy';

  /// Supported top-level fields for exported policy maps.
  static const List<String> supportedTopLevelFields = <String>[
    metadata,
    entries,
    policy,
  ];

  // ---------------------------------------------------------------------------
  // Metadata fields
  // ---------------------------------------------------------------------------

  static const String formatVersion = 'formatVersion';
  static const String formatVersionSnake = 'format_version';

  static const String policyType = 'policyType';
  static const String policyTypeSnake = 'policy_type';

  static const String exportMode = 'exportMode';
  static const String exportModeSnake = 'export_mode';

  static const String stateOrder = 'stateOrder';
  static const String stateOrderSnake = 'state_order';

  static const String stateKeyFormat = 'stateKeyFormat';
  static const String stateKeyFormatSnake = 'state_key_format';

  static const String stateDecimals = 'stateDecimals';
  static const String stateDecimalsSnake = 'state_decimals';

  static const String exportResolution = 'exportResolution';
  static const String exportResolutionSnake = 'export_resolution';

  static const String stateDimensionCount = 'stateDimensionCount';
  static const String stateDim = 'state_dim';

  static const String exportedStateCount = 'exportedStateCount';
  static const String numExportedStates = 'num_exported_states';

  static const String actionCount = 'actionCount';
  static const String numActions = 'num_actions';

  static const String actionNames = 'actionNames';
  static const String actionNamesSnake = 'action_names';

  static const String actionSelection = 'actionSelection';
  static const String actionSelectionSnake = 'action_selection';

  static const String decisionMapping = 'decisionMapping';
  static const String decisionMappingSnake = 'decision_mapping';

  static const String source = 'source';
  static const String description = 'description';
  static const String notes = 'notes';

  static const String exportedAt = 'exportedAt';
  static const String exportedAtSnake = 'exported_at';

  // ---------------------------------------------------------------------------
  // Normalized entry fields
  // ---------------------------------------------------------------------------

  static const String stateKey = 'stateKey';
  static const String decision = 'decision';
  static const String stateValues = 'stateValues';
  static const String actionId = 'actionId';
  static const String actionLabel = 'actionLabel';
  static const String probabilities = 'probabilities';
  static const String valueEstimate = 'valueEstimate';

  // ---------------------------------------------------------------------------
  // Python-style entry fields
  // ---------------------------------------------------------------------------

  static const String pythonState = 'state';
  static const String pythonAction = 'action';
  static const String pythonActionLabel = 'action_label';
  static const String pythonDecision = 'decision';
  static const String pythonProbabilities = 'probs';
  static const String pythonValue = 'value';

  // ---------------------------------------------------------------------------
  // Decision fields (canonical / normalized)
  // ---------------------------------------------------------------------------

  static const String nextDifficulty = 'nextDifficulty';
  static const String decisionSource = 'source';
  static const String reason = 'reason';
  static const String details = 'details';

  // ---------------------------------------------------------------------------
  // Rich decision-detail fields from Python/export pipeline
  // ---------------------------------------------------------------------------

  static const String sourceActionId = 'source_action_id';
  static const String sourceActionName = 'source_action_name';
  static const String actionGroup = 'action_group';
  static const String decisionType = 'decision_type';
  static const String difficultyChange = 'difficulty_change';
  static const String difficultyRankBefore = 'difficulty_rank_before';
  static const String difficultyRankAfter = 'difficulty_rank_after';
  static const String difficultyDelta = 'difficulty_delta';
  static const String currentDifficulty = 'current_difficulty';
  static const String nextDifficultyLabel = 'next_difficulty';
  static const String supportStrategy = 'support_strategy';
  static const String pedagogicalEffect = 'pedagogical_effect';
  static const String stateInterpretation = 'state_interpretation';
  static const String stateFlags = 'state_flags';

  // ---------------------------------------------------------------------------
  // Canonical state-dimension labels
  // ---------------------------------------------------------------------------

  static const List<String> canonicalStateDimensions =
      StateDimensionLabels.ordered;

  /// Common short-form aliases frequently used in Python exports.
  static const List<String> shortStateDimensions = <String>[
    'eng',
    'mot',
    'flow',
    'perf',
  ];

  // ---------------------------------------------------------------------------
  // Supported format labels
  // ---------------------------------------------------------------------------

  /// Canonical normalized exported policy structure:
  /// - metadata
  /// - entries
  static const String normalizedEntriesFormat = 'normalized_entries_format';

  /// Python-style exported policy structure:
  /// - metadata
  /// - policy
  static const String pythonPolicyMapFormat = 'python_policy_map_format';

  /// Supported high-level export format labels.
  static const List<String> supportedFormats = <String>[
    normalizedEntriesFormat,
    pythonPolicyMapFormat,
  ];

  /// Returns whether [map] appears to be in normalized entries format.
  static bool isNormalizedEntriesFormat(Map<String, dynamic> map) {
    return map.containsKey(entries);
  }

  /// Returns whether [map] appears to be in Python-style policy-map format.
  static bool isPythonPolicyMapFormat(Map<String, dynamic> map) {
    return map.containsKey(policy);
  }

  /// Returns the detected top-level format label for [map], or null if unknown.
  static String? detectFormat(Map<String, dynamic> map) {
    if (isNormalizedEntriesFormat(map)) {
      return normalizedEntriesFormat;
    }

    if (isPythonPolicyMapFormat(map)) {
      return pythonPolicyMapFormat;
    }

    return null;
  }

  /// Returns whether [label] is a canonical or supported state dimension name.
  static bool isSupportedStateDimension(String label) {
    return canonicalStateDimensions.contains(label) ||
        shortStateDimensions.contains(label);
  }
}