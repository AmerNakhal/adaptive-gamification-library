import '../domain/decisions/adaptive_decision.dart';
import '../domain/decisions/decision_context.dart';
import '../domain/recommendations/adaptive_recommendation.dart';
import '../domain/recommendations/recommendation_priority.dart';
import '../domain/recommendations/recommendation_type.dart';
import '../domain/transitions/difficulty_change_type.dart';
import '../domain/transitions/difficulty_transition.dart';
import 'action_group_mapper.dart';
import 'difficulty_transition_resolver.dart';
import 'gamification_labels.dart';
import 'pedagogical_effect_mapper.dart';
import 'support_strategy_mapper.dart';

/// Builds high-level adaptive recommendations from runtime decision data.
///
/// This builder translates low-level runtime decisions into richer,
/// developer-facing recommendation objects suitable for:
/// - UI presentation
/// - analytics
/// - session summaries
/// - adaptive application workflows
class RecommendationBuilder {
  /// Resolves difficulty transitions from decisions.
  final DifficultyTransitionResolver transitionResolver;

  /// Maps action labels into action groups.
  final ActionGroupMapper actionGroupMapper;

  /// Maps actions into support strategies.
  final SupportStrategyMapper supportStrategyMapper;

  /// Maps actions or strategies into pedagogical effects.
  final PedagogicalEffectMapper pedagogicalEffectMapper;

  /// Creates a recommendation builder.
  const RecommendationBuilder({
    this.transitionResolver = const DifficultyTransitionResolver(),
    this.actionGroupMapper = const ActionGroupMapper(),
    this.supportStrategyMapper = const SupportStrategyMapper(),
    this.pedagogicalEffectMapper = const PedagogicalEffectMapper(),
  });

  /// Builds an [AdaptiveRecommendation] from a runtime [decision].
  ///
  /// If [transition] is not provided, the builder will try to derive it from:
  /// - decision details
  /// - [currentDifficultyRank]
  AdaptiveRecommendation build(
      AdaptiveDecision decision, {
        DecisionContext? context,
        DifficultyTransition? transition,
        int? currentDifficultyRank,
        String? recommendationId,
      }) {
    final resolvedTransition = transition ??
        transitionResolver.resolve(
          decision,
          currentDifficultyRank: currentDifficultyRank,
        );

    final actionLabel =
    GamificationLabels.normalizeActionLabel(decision.actionLabel);

    final actionGroup =
    actionGroupMapper.mapActionLabelToGroup(actionLabel);

    final supportStrategy = decision.details?.supportStrategy ??
        supportStrategyMapper.map(
          actionLabel: actionLabel,
          actionGroup: actionGroup,
        );

    final pedagogicalEffect = decision.details?.pedagogicalEffect ??
        pedagogicalEffectMapper.map(
          actionLabel: actionLabel,
          supportStrategy: supportStrategy,
        );

    final type = _resolveRecommendationType(
      actionLabel: actionLabel,
      actionGroup: actionGroup,
      transition: resolvedTransition,
      supportStrategy: supportStrategy,
    );

    final priority = _resolvePriority(
      decision: decision,
      transition: resolvedTransition,
      supportStrategy: supportStrategy,
    );

    final title = _buildTitle(
      decision: decision,
      transition: resolvedTransition,
      supportStrategy: supportStrategy,
    );

    final message = _buildMessage(
      decision: decision,
      transition: resolvedTransition,
      supportStrategy: supportStrategy,
      pedagogicalEffect: pedagogicalEffect,
    );

    final tags = _buildTags(
      decision: decision,
      type: type,
      priority: priority,
      actionLabel: actionLabel,
      actionGroup: actionGroup,
      supportStrategy: supportStrategy,
      pedagogicalEffect: pedagogicalEffect,
      transition: resolvedTransition,
    );

    return AdaptiveRecommendation(
      id: recommendationId ?? _buildRecommendationId(decision, context),
      type: type,
      priority: priority,
      title: title,
      message: message,
      decision: decision,
      transition: resolvedTransition,
      context: context,
      supportStrategy: supportStrategy,
      actionGroup: actionGroup,
      pedagogicalEffect: pedagogicalEffect,
      tags: tags,
    );
  }

  String _resolveRecommendationType({
    required String actionLabel,
    required String actionGroup,
    required DifficultyTransition? transition,
    required String supportStrategy,
  }) {
    if (actionLabel == GamificationLabels.rest ||
        supportStrategy == GamificationLabels.provideRecovery) {
      return RecommendationType.recovery;
    }

    if (actionLabel == GamificationLabels.motivationBoost ||
        actionGroup == GamificationLabels.motivationalSupportGroup ||
        supportStrategy == GamificationLabels.encouragePersistence) {
      return RecommendationType.motivationalSupport;
    }

    if (actionLabel == GamificationLabels.flowTask ||
        actionGroup == GamificationLabels.flowRegulationGroup ||
        supportStrategy == GamificationLabels.restoreFlow) {
      return RecommendationType.flowAlignment;
    }

    if (transition != null && transition.isMaintain) {
      return RecommendationType.maintenance;
    }

    return RecommendationType.difficultyAdjustment;
  }

  String _resolvePriority({
    required AdaptiveDecision decision,
    required DifficultyTransition? transition,
    required String supportStrategy,
  }) {
    if (decision.isFallback) {
      return RecommendationPriority.high;
    }

    if (supportStrategy == GamificationLabels.provideRecovery) {
      return RecommendationPriority.high;
    }

    if (transition != null && transition.delta.abs() >= 2) {
      return RecommendationPriority.high;
    }

    if (supportStrategy == GamificationLabels.encouragePersistence ||
        supportStrategy == GamificationLabels.restoreFlow) {
      return RecommendationPriority.medium;
    }

    return RecommendationPriority.medium;
  }

  String _buildTitle({
    required AdaptiveDecision decision,
    required DifficultyTransition? transition,
    required String supportStrategy,
  }) {
    if (supportStrategy == GamificationLabels.provideRecovery) {
      return 'Recovery recommendation';
    }

    if (supportStrategy == GamificationLabels.restoreFlow) {
      return 'Flow alignment recommendation';
    }

    if (supportStrategy == GamificationLabels.encouragePersistence) {
      return 'Motivational support recommendation';
    }

    if (transition != null) {
      if (transition.changeType == DifficultyChangeType.increase) {
        return 'Increase challenge';
      }
      if (transition.changeType == DifficultyChangeType.decrease) {
        return 'Reduce challenge';
      }
      return 'Maintain current challenge';
    }

    return 'Adaptive recommendation';
  }

  String _buildMessage({
    required AdaptiveDecision decision,
    required DifficultyTransition? transition,
    required String supportStrategy,
    required String pedagogicalEffect,
  }) {
    final reason = decision.reason;

    if (supportStrategy == GamificationLabels.provideRecovery) {
      return reason ??
          'A recovery-oriented step is recommended to reduce pressure and restore stability.';
    }

    if (supportStrategy == GamificationLabels.restoreFlow) {
      return reason ??
          'A flow-supporting step is recommended to improve alignment between challenge and current state.';
    }

    if (supportStrategy == GamificationLabels.encouragePersistence) {
      return reason ??
          'A motivational support step is recommended to reinforce persistence and sustain engagement.';
    }

    if (transition != null) {
      if (transition.isIncrease) {
        return reason ??
            'A higher difficulty level is recommended to increase challenge and support continued progression.';
      }

      if (transition.isDecrease) {
        return reason ??
            'A lower difficulty level is recommended to reduce pressure and support recovery.';
      }

      return reason ??
          'The current difficulty level is recommended to be maintained for stable progression.';
    }

    return reason ??
        'An adaptive step is recommended based on the current runtime state and pedagogical effect: $pedagogicalEffect.';
  }

  List<String> _buildTags({
    required AdaptiveDecision decision,
    required String type,
    required String priority,
    required String actionLabel,
    required String actionGroup,
    required String supportStrategy,
    required String pedagogicalEffect,
    required DifficultyTransition? transition,
  }) {
    final tags = <String>[
      type,
      priority,
      actionLabel,
      actionGroup,
      supportStrategy,
      pedagogicalEffect,
      decision.source,
    ];

    if (transition != null) {
      tags.add(transition.changeType);
      tags.add(transition.beforeLevel);
      tags.add(transition.afterLevel);
    }

    if (decision.reason != null && decision.reason!.trim().isNotEmpty) {
      tags.add('has_reason');
    }

    return List<String>.unmodifiable(tags);
  }

  String _buildRecommendationId(
      AdaptiveDecision decision,
      DecisionContext? context,
      ) {
    final keyPart = context?.generatedStateKey ?? 'unknown_state';
    final sourcePart = decision.source;
    final difficultyPart = decision.nextDifficulty;
    return 'rec_${sourcePart}_${difficultyPart}_$keyPart';
  }

  @override
  String toString() {
    return 'RecommendationBuilder('
        'transitionResolver: $transitionResolver, '
        'actionGroupMapper: $actionGroupMapper, '
        'supportStrategyMapper: $supportStrategyMapper, '
        'pedagogicalEffectMapper: $pedagogicalEffectMapper'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RecommendationBuilder &&
            other.transitionResolver == transitionResolver &&
            other.actionGroupMapper == actionGroupMapper &&
            other.supportStrategyMapper == supportStrategyMapper &&
            other.pedagogicalEffectMapper == pedagogicalEffectMapper);
  }

  @override
  int get hashCode => Object.hash(
    transitionResolver,
    actionGroupMapper,
    supportStrategyMapper,
    pedagogicalEffectMapper,
  );
}