/// Represents rich decision details associated with an [AdaptiveDecision].
///
/// This model is intended to preserve the richer semantic and analytical
/// information exported from the policy-generation pipeline, while keeping the
/// primary decision object simple for common developer workflows.
class AdaptiveDecisionDetails {
  /// Optional source action identifier.
  final int? sourceActionId;

  /// Optional source action name.
  ///
  /// Example:
  /// - `flow_task`
  /// - `motivation_boost`
  final String? sourceActionName;

  /// Optional action group.
  ///
  /// Example:
  /// - `flow_regulation`
  /// - `motivational_support`
  final String? actionGroup;

  /// Optional decision type.
  ///
  /// Example:
  /// - `flow_regulation`
  /// - `motivational_support`
  /// - `difficulty_adjustment`
  final String? decisionType;

  /// Optional difficulty change label.
  ///
  /// Example:
  /// - `increase`
  /// - `decrease`
  /// - `maintain`
  final String? difficultyChange;

  /// Optional difficulty rank before the decision.
  final int? difficultyRankBefore;

  /// Optional difficulty rank after the decision.
  final int? difficultyRankAfter;

  /// Optional difficulty delta.
  final int? difficultyDelta;

  /// Optional current difficulty label before the decision.
  ///
  /// Example:
  /// - `veryEasy`
  /// - `easy`
  /// - `medium`
  /// - `hard`
  /// - `veryHard`
  final String? currentDifficulty;

  /// Optional next difficulty label after the decision.
  final String? nextDifficultyLabel;

  /// Optional support strategy label.
  final String? supportStrategy;

  /// Optional pedagogical effect description.
  final String? pedagogicalEffect;

  /// Optional interpreted state values associated with the decision.
  ///
  /// Example:
  /// `{ "eng": 0.5, "mot": 0.75, "flow": 0.25, "perf": 0.5 }`
  final Map<String, double> stateInterpretation;

  /// Optional boolean state flags.
  ///
  /// Example:
  /// `{ "low_engagement": true, "high_performance": false }`
  final Map<String, bool> stateFlags;

  /// Optional action probability distribution.
  final List<double> actionProbabilities;

  /// Optional value estimate associated with the decision.
  final double? valueEstimate;

  /// Creates rich adaptive decision details.
  const AdaptiveDecisionDetails({
    this.sourceActionId,
    this.sourceActionName,
    this.actionGroup,
    this.decisionType,
    this.difficultyChange,
    this.difficultyRankBefore,
    this.difficultyRankAfter,
    this.difficultyDelta,
    this.currentDifficulty,
    this.nextDifficultyLabel,
    this.supportStrategy,
    this.pedagogicalEffect,
    this.stateInterpretation = const <String, double>{},
    this.stateFlags = const <String, bool>{},
    this.actionProbabilities = const <double>[],
    this.valueEstimate,
  });

  /// Creates rich decision details from a generic map.
  factory AdaptiveDecisionDetails.fromMap(Map<String, dynamic> map) {
    final sourceActionIdValue = map['sourceActionId'];
    final sourceActionNameValue = map['sourceActionName'];
    final actionGroupValue = map['actionGroup'];
    final decisionTypeValue = map['decisionType'];
    final difficultyChangeValue = map['difficultyChange'];
    final difficultyRankBeforeValue = map['difficultyRankBefore'];
    final difficultyRankAfterValue = map['difficultyRankAfter'];
    final difficultyDeltaValue = map['difficultyDelta'];
    final currentDifficultyValue = map['currentDifficulty'];
    final nextDifficultyLabelValue = map['nextDifficultyLabel'];
    final supportStrategyValue = map['supportStrategy'];
    final pedagogicalEffectValue = map['pedagogicalEffect'];
    final stateInterpretationValue = map['stateInterpretation'];
    final stateFlagsValue = map['stateFlags'];
    final actionProbabilitiesValue = map['actionProbabilities'];
    final valueEstimateValue = map['valueEstimate'];

    if (sourceActionIdValue != null && sourceActionIdValue is! num) {
      throw FormatException(
        'AdaptiveDecisionDetails field "sourceActionId" must be numeric when provided, '
        'but got ${sourceActionIdValue.runtimeType}.',
      );
    }

    if (sourceActionNameValue != null && sourceActionNameValue is! String) {
      throw FormatException(
        'AdaptiveDecisionDetails field "sourceActionName" must be a String when provided, '
        'but got ${sourceActionNameValue.runtimeType}.',
      );
    }

    if (actionGroupValue != null && actionGroupValue is! String) {
      throw FormatException(
        'AdaptiveDecisionDetails field "actionGroup" must be a String when provided, '
        'but got ${actionGroupValue.runtimeType}.',
      );
    }

    if (decisionTypeValue != null && decisionTypeValue is! String) {
      throw FormatException(
        'AdaptiveDecisionDetails field "decisionType" must be a String when provided, '
        'but got ${decisionTypeValue.runtimeType}.',
      );
    }

    if (difficultyChangeValue != null && difficultyChangeValue is! String) {
      throw FormatException(
        'AdaptiveDecisionDetails field "difficultyChange" must be a String when provided, '
        'but got ${difficultyChangeValue.runtimeType}.',
      );
    }

    if (difficultyRankBeforeValue != null &&
        difficultyRankBeforeValue is! num) {
      throw FormatException(
        'AdaptiveDecisionDetails field "difficultyRankBefore" must be numeric when provided, '
        'but got ${difficultyRankBeforeValue.runtimeType}.',
      );
    }

    if (difficultyRankAfterValue != null && difficultyRankAfterValue is! num) {
      throw FormatException(
        'AdaptiveDecisionDetails field "difficultyRankAfter" must be numeric when provided, '
        'but got ${difficultyRankAfterValue.runtimeType}.',
      );
    }

    if (difficultyDeltaValue != null && difficultyDeltaValue is! num) {
      throw FormatException(
        'AdaptiveDecisionDetails field "difficultyDelta" must be numeric when provided, '
        'but got ${difficultyDeltaValue.runtimeType}.',
      );
    }

    if (currentDifficultyValue != null && currentDifficultyValue is! String) {
      throw FormatException(
        'AdaptiveDecisionDetails field "currentDifficulty" must be a String when provided, '
        'but got ${currentDifficultyValue.runtimeType}.',
      );
    }

    if (nextDifficultyLabelValue != null &&
        nextDifficultyLabelValue is! String) {
      throw FormatException(
        'AdaptiveDecisionDetails field "nextDifficultyLabel" must be a String when provided, '
        'but got ${nextDifficultyLabelValue.runtimeType}.',
      );
    }

    if (supportStrategyValue != null && supportStrategyValue is! String) {
      throw FormatException(
        'AdaptiveDecisionDetails field "supportStrategy" must be a String when provided, '
        'but got ${supportStrategyValue.runtimeType}.',
      );
    }

    if (pedagogicalEffectValue != null && pedagogicalEffectValue is! String) {
      throw FormatException(
        'AdaptiveDecisionDetails field "pedagogicalEffect" must be a String when provided, '
        'but got ${pedagogicalEffectValue.runtimeType}.',
      );
    }

    if (valueEstimateValue != null && valueEstimateValue is! num) {
      throw FormatException(
        'AdaptiveDecisionDetails field "valueEstimate" must be numeric when provided, '
        'but got ${valueEstimateValue.runtimeType}.',
      );
    }

    return AdaptiveDecisionDetails(
      sourceActionId: sourceActionIdValue == null
          ? null
          : (sourceActionIdValue as num).toInt(),
      sourceActionName: sourceActionNameValue as String?,
      actionGroup: actionGroupValue as String?,
      decisionType: decisionTypeValue as String?,
      difficultyChange: difficultyChangeValue as String?,
      difficultyRankBefore: difficultyRankBeforeValue == null
          ? null
          : (difficultyRankBeforeValue as num).toInt(),
      difficultyRankAfter: difficultyRankAfterValue == null
          ? null
          : (difficultyRankAfterValue as num).toInt(),
      difficultyDelta: difficultyDeltaValue == null
          ? null
          : (difficultyDeltaValue as num).toInt(),
      currentDifficulty: currentDifficultyValue as String?,
      nextDifficultyLabel: nextDifficultyLabelValue as String?,
      supportStrategy: supportStrategyValue as String?,
      pedagogicalEffect: pedagogicalEffectValue as String?,
      stateInterpretation: _readDoubleMap(
        stateInterpretationValue,
        fieldName: 'stateInterpretation',
      ),
      stateFlags: _readBoolMap(
        stateFlagsValue,
        fieldName: 'stateFlags',
      ),
      actionProbabilities: _readDoubleList(
        actionProbabilitiesValue,
        fieldName: 'actionProbabilities',
      ),
      valueEstimate: valueEstimateValue == null
          ? null
          : (valueEstimateValue as num).toDouble(),
    );
  }

  /// Returns this object as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sourceActionId': sourceActionId,
      'sourceActionName': sourceActionName,
      'actionGroup': actionGroup,
      'decisionType': decisionType,
      'difficultyChange': difficultyChange,
      'difficultyRankBefore': difficultyRankBefore,
      'difficultyRankAfter': difficultyRankAfter,
      'difficultyDelta': difficultyDelta,
      'currentDifficulty': currentDifficulty,
      'nextDifficultyLabel': nextDifficultyLabel,
      'supportStrategy': supportStrategy,
      'pedagogicalEffect': pedagogicalEffect,
      'stateInterpretation': stateInterpretation,
      'stateFlags': stateFlags,
      'actionProbabilities': actionProbabilities,
      'valueEstimate': valueEstimate,
    };
  }

  /// Returns whether rich state interpretation values are present.
  bool get hasStateInterpretation => stateInterpretation.isNotEmpty;

  /// Returns whether state flags are present.
  bool get hasStateFlags => stateFlags.isNotEmpty;

  /// Returns whether action probabilities are present.
  bool get hasActionProbabilities => actionProbabilities.isNotEmpty;

  /// Returns whether a value estimate is present.
  bool get hasValueEstimate => valueEstimate != null;

  /// Returns a copy of this object with selected values replaced.
  AdaptiveDecisionDetails copyWith({
    int? sourceActionId,
    String? sourceActionName,
    String? actionGroup,
    String? decisionType,
    String? difficultyChange,
    int? difficultyRankBefore,
    int? difficultyRankAfter,
    int? difficultyDelta,
    String? currentDifficulty,
    String? nextDifficultyLabel,
    String? supportStrategy,
    String? pedagogicalEffect,
    Map<String, double>? stateInterpretation,
    Map<String, bool>? stateFlags,
    List<double>? actionProbabilities,
    double? valueEstimate,
  }) {
    return AdaptiveDecisionDetails(
      sourceActionId: sourceActionId ?? this.sourceActionId,
      sourceActionName: sourceActionName ?? this.sourceActionName,
      actionGroup: actionGroup ?? this.actionGroup,
      decisionType: decisionType ?? this.decisionType,
      difficultyChange: difficultyChange ?? this.difficultyChange,
      difficultyRankBefore: difficultyRankBefore ?? this.difficultyRankBefore,
      difficultyRankAfter: difficultyRankAfter ?? this.difficultyRankAfter,
      difficultyDelta: difficultyDelta ?? this.difficultyDelta,
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      nextDifficultyLabel: nextDifficultyLabel ?? this.nextDifficultyLabel,
      supportStrategy: supportStrategy ?? this.supportStrategy,
      pedagogicalEffect: pedagogicalEffect ?? this.pedagogicalEffect,
      stateInterpretation: stateInterpretation ?? this.stateInterpretation,
      stateFlags: stateFlags ?? this.stateFlags,
      actionProbabilities: actionProbabilities ?? this.actionProbabilities,
      valueEstimate: valueEstimate ?? this.valueEstimate,
    );
  }

  @override
  String toString() {
    return 'AdaptiveDecisionDetails('
        'sourceActionId: $sourceActionId, '
        'sourceActionName: $sourceActionName, '
        'actionGroup: $actionGroup, '
        'decisionType: $decisionType, '
        'difficultyChange: $difficultyChange, '
        'difficultyRankBefore: $difficultyRankBefore, '
        'difficultyRankAfter: $difficultyRankAfter, '
        'difficultyDelta: $difficultyDelta, '
        'currentDifficulty: $currentDifficulty, '
        'nextDifficultyLabel: $nextDifficultyLabel, '
        'supportStrategy: $supportStrategy, '
        'pedagogicalEffect: $pedagogicalEffect, '
        'stateInterpretation: $stateInterpretation, '
        'stateFlags: $stateFlags, '
        'actionProbabilities: $actionProbabilities, '
        'valueEstimate: $valueEstimate'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdaptiveDecisionDetails &&
            other.sourceActionId == sourceActionId &&
            other.sourceActionName == sourceActionName &&
            other.actionGroup == actionGroup &&
            other.decisionType == decisionType &&
            other.difficultyChange == difficultyChange &&
            other.difficultyRankBefore == difficultyRankBefore &&
            other.difficultyRankAfter == difficultyRankAfter &&
            other.difficultyDelta == difficultyDelta &&
            other.currentDifficulty == currentDifficulty &&
            other.nextDifficultyLabel == nextDifficultyLabel &&
            other.supportStrategy == supportStrategy &&
            other.pedagogicalEffect == pedagogicalEffect &&
            _doubleMapEquals(other.stateInterpretation, stateInterpretation) &&
            _boolMapEquals(other.stateFlags, stateFlags) &&
            _doubleListEquals(other.actionProbabilities, actionProbabilities) &&
            other.valueEstimate == valueEstimate);
  }

  @override
  int get hashCode {
    return Object.hash(
      sourceActionId,
      sourceActionName,
      actionGroup,
      decisionType,
      difficultyChange,
      difficultyRankBefore,
      difficultyRankAfter,
      difficultyDelta,
      currentDifficulty,
      nextDifficultyLabel,
      supportStrategy,
      pedagogicalEffect,
      Object.hashAll(
        stateInterpretation.entries.map(
          (entry) => Object.hash(entry.key, entry.value),
        ),
      ),
      Object.hashAll(
        stateFlags.entries.map(
          (entry) => Object.hash(entry.key, entry.value),
        ),
      ),
      Object.hashAll(actionProbabilities),
      valueEstimate,
    );
  }

  static Map<String, double> _readDoubleMap(
    dynamic value, {
    required String fieldName,
  }) {
    if (value == null) return const <String, double>{};

    if (value is! Map) {
      throw FormatException(
        'AdaptiveDecisionDetails field "$fieldName" must be a Map when provided, '
        'but got ${value.runtimeType}.',
      );
    }

    final result = <String, double>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! num) {
        throw FormatException(
          'AdaptiveDecisionDetails field "$fieldName" must map String keys to numeric values.',
        );
      }
      result[entry.key as String] = (entry.value as num).toDouble();
    }

    return Map<String, double>.unmodifiable(result);
  }

  static Map<String, bool> _readBoolMap(
    dynamic value, {
    required String fieldName,
  }) {
    if (value == null) return const <String, bool>{};

    if (value is! Map) {
      throw FormatException(
        'AdaptiveDecisionDetails field "$fieldName" must be a Map when provided, '
        'but got ${value.runtimeType}.',
      );
    }

    final result = <String, bool>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! bool) {
        throw FormatException(
          'AdaptiveDecisionDetails field "$fieldName" must map String keys to bool values.',
        );
      }
      result[entry.key as String] = entry.value as bool;
    }

    return Map<String, bool>.unmodifiable(result);
  }

  static List<double> _readDoubleList(
    dynamic value, {
    required String fieldName,
  }) {
    if (value == null) return const <double>[];

    if (value is! List) {
      throw FormatException(
        'AdaptiveDecisionDetails field "$fieldName" must be a List when provided, '
        'but got ${value.runtimeType}.',
      );
    }

    final result = <double>[];
    for (final item in value) {
      if (item is! num) {
        throw FormatException(
          'AdaptiveDecisionDetails field "$fieldName" must contain only numeric values, '
          'but found ${item.runtimeType}.',
        );
      }
      result.add(item.toDouble());
    }

    return List<double>.unmodifiable(result);
  }

  static bool _doubleMapEquals(Map<String, double> a, Map<String, double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  static bool _boolMapEquals(Map<String, bool> a, Map<String, bool> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  static bool _doubleListEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
