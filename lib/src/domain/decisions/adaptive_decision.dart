import 'adaptive_decision_details.dart';
import 'decision_source.dart';

/// Represents the primary adaptive decision returned by the library.
///
/// This is the developer-facing decision object used in most application-level
/// workflows. It captures the essential decision result while optionally
/// carrying richer decision details.
class AdaptiveDecision {
  /// Recommended next difficulty index or rank.
  final int nextDifficulty;

  /// Canonical source label describing how the decision was produced.
  ///
  /// See [DecisionSource].
  final String source;

  /// Optional human-readable explanation for the decision.
  final String? reason;

  /// Optional semantic action label associated with the decision.
  ///
  /// Examples:
  /// - `easy_task`
  /// - `medium_task`
  /// - `hard_task`
  /// - `motivation_boost`
  /// - `flow_task`
  final String? actionLabel;

  /// Optional rich decision details.
  ///
  /// These details may include:
  /// - action metadata
  /// - support strategy
  /// - pedagogical effect
  /// - probabilities
  /// - value estimate
  /// - state flags
  final AdaptiveDecisionDetails? details;

  /// Creates an adaptive decision.
  const AdaptiveDecision({
    required this.nextDifficulty,
    required this.source,
    this.reason,
    this.actionLabel,
    this.details,
  });

  /// Creates an adaptive decision from a generic map.
  ///
  /// Expected keys:
  /// - `nextDifficulty` (required, numeric)
  /// - `source` (optional, defaults to `exact_match`)
  /// - `reason` (optional)
  /// - `actionLabel` (optional)
  /// - `details` (optional)
  ///
  /// Throws [FormatException] if the structure is invalid.
  factory AdaptiveDecision.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('nextDifficulty')) {
      throw const FormatException(
        'Missing required AdaptiveDecision field: nextDifficulty',
      );
    }

    final nextDifficultyValue = map['nextDifficulty'];
    if (nextDifficultyValue is! num) {
      throw FormatException(
        'AdaptiveDecision field "nextDifficulty" must be numeric, '
            'but got ${nextDifficultyValue.runtimeType}.',
      );
    }

    final sourceValue = map['source'];
    final reasonValue = map['reason'];
    final actionLabelValue = map['actionLabel'];
    final detailsValue = map['details'];

    if (sourceValue != null && sourceValue is! String) {
      throw FormatException(
        'AdaptiveDecision field "source" must be a String when provided, '
            'but got ${sourceValue.runtimeType}.',
      );
    }

    if (reasonValue != null && reasonValue is! String) {
      throw FormatException(
        'AdaptiveDecision field "reason" must be a String when provided, '
            'but got ${reasonValue.runtimeType}.',
      );
    }

    if (actionLabelValue != null && actionLabelValue is! String) {
      throw FormatException(
        'AdaptiveDecision field "actionLabel" must be a String when provided, '
            'but got ${actionLabelValue.runtimeType}.',
      );
    }

    AdaptiveDecisionDetails? details;
    if (detailsValue != null) {
      if (detailsValue is! Map<String, dynamic>) {
        throw FormatException(
          'AdaptiveDecision field "details" must be a Map<String, dynamic> '
              'when provided, but got ${detailsValue.runtimeType}.',
        );
      }

      details = AdaptiveDecisionDetails.fromMap(detailsValue);
    }

    return AdaptiveDecision(
      nextDifficulty: nextDifficultyValue.toInt(),
      source: DecisionSource.normalize(sourceValue as String?),
      reason: reasonValue as String?,
      actionLabel: actionLabelValue as String?,
      details: details,
    );
  }

  /// Returns this decision as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nextDifficulty': nextDifficulty,
      'source': source,
      'reason': reason,
      'actionLabel': actionLabel,
      'details': details?.toMap(),
    };
  }

  /// Returns whether this decision came from fallback logic.
  bool get isFallback => source == DecisionSource.fallback;

  /// Returns whether this decision came from an exact policy match.
  bool get isExactMatch => source == DecisionSource.exactMatch;

  /// Returns whether this decision carries rich decision details.
  bool get hasDetails => details != null;

  /// Returns a copy of this decision with selected values replaced.
  AdaptiveDecision copyWith({
    int? nextDifficulty,
    String? source,
    String? reason,
    String? actionLabel,
    AdaptiveDecisionDetails? details,
  }) {
    return AdaptiveDecision(
      nextDifficulty: nextDifficulty ?? this.nextDifficulty,
      source: source ?? this.source,
      reason: reason ?? this.reason,
      actionLabel: actionLabel ?? this.actionLabel,
      details: details ?? this.details,
    );
  }

  @override
  String toString() {
    return 'AdaptiveDecision('
        'nextDifficulty: $nextDifficulty, '
        'source: $source, '
        'reason: $reason, '
        'actionLabel: $actionLabel, '
        'details: $details'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdaptiveDecision &&
            other.nextDifficulty == nextDifficulty &&
            other.source == source &&
            other.reason == reason &&
            other.actionLabel == actionLabel &&
            other.details == details);
  }

  @override
  int get hashCode {
    return Object.hash(
      nextDifficulty,
      source,
      reason,
      actionLabel,
      details,
    );
  }
}