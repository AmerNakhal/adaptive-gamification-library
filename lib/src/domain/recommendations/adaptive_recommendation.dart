import '../decisions/adaptive_decision.dart';
import '../decisions/decision_context.dart';
import '../transitions/difficulty_transition.dart';
import 'recommendation_priority.dart';
import 'recommendation_type.dart';

/// Represents a high-level adaptive recommendation produced by the library.
///
/// While [AdaptiveDecision] represents the core decision result,
/// [AdaptiveRecommendation] is the higher-level developer-facing object intended
/// for direct use in application workflows and UI integration.
class AdaptiveRecommendation {
  /// Stable recommendation identifier.
  ///
  /// This can be useful for tracking, analytics, logging, or UI state.
  final String id;

  /// Canonical recommendation type.
  ///
  /// See [RecommendationType].
  final String type;

  /// Canonical recommendation priority.
  ///
  /// See [RecommendationPriority].
  final String priority;

  /// Human-readable recommendation title.
  final String title;

  /// Human-readable recommendation message or explanation.
  final String message;

  /// The core adaptive decision underlying this recommendation.
  final AdaptiveDecision decision;

  /// Optional difficulty transition derived from the decision.
  final DifficultyTransition? transition;

  /// Optional decision context associated with the recommendation.
  final DecisionContext? context;

  /// Optional support strategy label associated with the recommendation.
  final String? supportStrategy;

  /// Optional action group label associated with the recommendation.
  final String? actionGroup;

  /// Optional pedagogical effect summary associated with the recommendation.
  final String? pedagogicalEffect;

  /// Optional machine-usable tags for filtering, grouping, or display logic.
  final List<String> tags;

  /// Creates an adaptive recommendation.
  const AdaptiveRecommendation({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.decision,
    this.transition,
    this.context,
    this.supportStrategy,
    this.actionGroup,
    this.pedagogicalEffect,
    this.tags = const <String>[],
  });

  /// Creates an adaptive recommendation from a generic map.
  ///
  /// Expected keys:
  /// - `id` (required)
  /// - `type` (optional, defaults to `difficulty_adjustment`)
  /// - `priority` (optional, defaults to `medium`)
  /// - `title` (required)
  /// - `message` (required)
  /// - `decision` (required)
  /// - `transition` (optional)
  /// - `context` (optional)
  /// - `supportStrategy` (optional)
  /// - `actionGroup` (optional)
  /// - `pedagogicalEffect` (optional)
  /// - `tags` (optional)
  factory AdaptiveRecommendation.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('id')) {
      throw const FormatException(
        'Missing required AdaptiveRecommendation field: id',
      );
    }

    if (!map.containsKey('title')) {
      throw const FormatException(
        'Missing required AdaptiveRecommendation field: title',
      );
    }

    if (!map.containsKey('message')) {
      throw const FormatException(
        'Missing required AdaptiveRecommendation field: message',
      );
    }

    if (!map.containsKey('decision')) {
      throw const FormatException(
        'Missing required AdaptiveRecommendation field: decision',
      );
    }

    final idValue = map['id'];
    final typeValue = map['type'];
    final priorityValue = map['priority'];
    final titleValue = map['title'];
    final messageValue = map['message'];
    final decisionValue = map['decision'];
    final transitionValue = map['transition'];
    final contextValue = map['context'];
    final supportStrategyValue = map['supportStrategy'];
    final actionGroupValue = map['actionGroup'];
    final pedagogicalEffectValue = map['pedagogicalEffect'];
    final tagsValue = map['tags'];

    if (idValue is! String) {
      throw FormatException(
        'AdaptiveRecommendation field "id" must be a String, '
            'but got ${idValue.runtimeType}.',
      );
    }

    if (titleValue is! String) {
      throw FormatException(
        'AdaptiveRecommendation field "title" must be a String, '
            'but got ${titleValue.runtimeType}.',
      );
    }

    if (messageValue is! String) {
      throw FormatException(
        'AdaptiveRecommendation field "message" must be a String, '
            'but got ${messageValue.runtimeType}.',
      );
    }

    if (decisionValue is! Map<String, dynamic>) {
      throw FormatException(
        'AdaptiveRecommendation field "decision" must be a Map<String, dynamic>, '
            'but got ${decisionValue.runtimeType}.',
      );
    }

    if (typeValue != null && typeValue is! String) {
      throw FormatException(
        'AdaptiveRecommendation field "type" must be a String when provided, '
            'but got ${typeValue.runtimeType}.',
      );
    }

    if (priorityValue != null && priorityValue is! String) {
      throw FormatException(
        'AdaptiveRecommendation field "priority" must be a String when provided, '
            'but got ${priorityValue.runtimeType}.',
      );
    }

    if (supportStrategyValue != null && supportStrategyValue is! String) {
      throw FormatException(
        'AdaptiveRecommendation field "supportStrategy" must be a String when provided, '
            'but got ${supportStrategyValue.runtimeType}.',
      );
    }

    if (actionGroupValue != null && actionGroupValue is! String) {
      throw FormatException(
        'AdaptiveRecommendation field "actionGroup" must be a String when provided, '
            'but got ${actionGroupValue.runtimeType}.',
      );
    }

    if (pedagogicalEffectValue != null && pedagogicalEffectValue is! String) {
      throw FormatException(
        'AdaptiveRecommendation field "pedagogicalEffect" must be a String when provided, '
            'but got ${pedagogicalEffectValue.runtimeType}.',
      );
    }

    DifficultyTransition? transition;
    if (transitionValue != null) {
      if (transitionValue is! Map<String, dynamic>) {
        throw FormatException(
          'AdaptiveRecommendation field "transition" must be a Map<String, dynamic> when provided, '
              'but got ${transitionValue.runtimeType}.',
        );
      }

      transition = DifficultyTransition.fromMap(transitionValue);
    }

    DecisionContext? context;
    if (contextValue != null) {
      if (contextValue is! Map<String, dynamic>) {
        throw FormatException(
          'AdaptiveRecommendation field "context" must be a Map<String, dynamic> when provided, '
              'but got ${contextValue.runtimeType}.',
        );
      }

      context = DecisionContext.fromMap(contextValue);
    }

    return AdaptiveRecommendation(
      id: idValue,
      type: RecommendationType.normalize(typeValue as String?),
      priority: RecommendationPriority.normalize(priorityValue as String?),
      title: titleValue,
      message: messageValue,
      decision: AdaptiveDecision.fromMap(decisionValue),
      transition: transition,
      context: context,
      supportStrategy: supportStrategyValue as String?,
      actionGroup: actionGroupValue as String?,
      pedagogicalEffect: pedagogicalEffectValue as String?,
      tags: _readStringList(
        tagsValue,
        fieldName: 'tags',
      ),
    );
  }

  /// Returns this recommendation as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'priority': priority,
      'title': title,
      'message': message,
      'decision': decision.toMap(),
      'transition': transition?.toMap(),
      'context': context?.toMap(),
      'supportStrategy': supportStrategy,
      'actionGroup': actionGroup,
      'pedagogicalEffect': pedagogicalEffect,
      'tags': tags,
    };
  }

  /// Returns whether this recommendation carries a difficulty transition.
  bool get hasTransition => transition != null;

  /// Returns whether this recommendation carries a decision context.
  bool get hasContext => context != null;

  /// Returns whether this recommendation carries any tags.
  bool get hasTags => tags.isNotEmpty;

  /// Returns a copy of this recommendation with selected values replaced.
  AdaptiveRecommendation copyWith({
    String? id,
    String? type,
    String? priority,
    String? title,
    String? message,
    AdaptiveDecision? decision,
    DifficultyTransition? transition,
    DecisionContext? context,
    String? supportStrategy,
    String? actionGroup,
    String? pedagogicalEffect,
    List<String>? tags,
  }) {
    return AdaptiveRecommendation(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      message: message ?? this.message,
      decision: decision ?? this.decision,
      transition: transition ?? this.transition,
      context: context ?? this.context,
      supportStrategy: supportStrategy ?? this.supportStrategy,
      actionGroup: actionGroup ?? this.actionGroup,
      pedagogicalEffect: pedagogicalEffect ?? this.pedagogicalEffect,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'AdaptiveRecommendation('
        'id: $id, '
        'type: $type, '
        'priority: $priority, '
        'title: $title, '
        'message: $message, '
        'decision: $decision, '
        'transition: $transition, '
        'context: $context, '
        'supportStrategy: $supportStrategy, '
        'actionGroup: $actionGroup, '
        'pedagogicalEffect: $pedagogicalEffect, '
        'tags: $tags'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdaptiveRecommendation &&
            other.id == id &&
            other.type == type &&
            other.priority == priority &&
            other.title == title &&
            other.message == message &&
            other.decision == decision &&
            other.transition == transition &&
            other.context == context &&
            other.supportStrategy == supportStrategy &&
            other.actionGroup == actionGroup &&
            other.pedagogicalEffect == pedagogicalEffect &&
            _listEquals(other.tags, tags));
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      priority,
      title,
      message,
      decision,
      transition,
      context,
      supportStrategy,
      actionGroup,
      pedagogicalEffect,
      Object.hashAll(tags),
    );
  }

  static List<String> _readStringList(
      dynamic value, {
        required String fieldName,
      }) {
    if (value == null) return const <String>[];

    if (value is! List) {
      throw FormatException(
        'AdaptiveRecommendation field "$fieldName" must be a List when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'AdaptiveRecommendation field "$fieldName" must contain only String values, '
              'but found ${item.runtimeType}.',
        );
      }
      result.add(item);
    }

    return List<String>.unmodifiable(result);
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}