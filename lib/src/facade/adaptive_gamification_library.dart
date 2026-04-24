import '../analytics/analytics_snapshot_builder.dart';
import '../analytics/decision_trace_builder.dart';
import '../analytics/execution_trace_formatter.dart';
import '../analytics/probability_summary_builder.dart';
import '../config/library_config.dart';
import '../domain/analytics/analytics_snapshot.dart';
import '../domain/analytics/decision_trace.dart';
import '../domain/analytics/execution_trace.dart';
import '../domain/analytics/runtime_diagnostics.dart';
import '../domain/decisions/adaptive_decision.dart';
import '../domain/recommendations/adaptive_recommendation.dart';
import '../domain/sessions/adaptive_session_summary.dart';
import '../domain/sessions/interaction_event.dart';
import '../domain/sessions/session_snapshot.dart';
import '../domain/state/adaptive_state.dart';
import '../domain/transitions/difficulty_transition.dart';
import '../exceptions/runtime_execution_exception.dart';
import '../gamification/difficulty_transition_resolver.dart';
import '../gamification/recommendation_builder.dart';
import '../runtime/adaptive_runtime_engine.dart';
import '../runtime/decision_engine.dart' show DecisionEngine, DecisionExecutionResult;
import '../runtime/loaded_policy.dart';
import '../runtime/policy_loader.dart';
import '../runtime/state_key_builder.dart';
import '../sessions/session_evaluator.dart';
import '../sessions/session_tracker.dart';

/// High-level developer-facing facade for the adaptive gamification library.
///
/// This facade is the main entry point for:
/// - policy loading
/// - deterministic runtime execution
/// - recommendation building
/// - decision tracing
/// - session tracking and evaluation
/// - lightweight analytics snapshot generation
class AdaptiveGamificationLibrary {
  /// Top-level library configuration.
  final LibraryConfig config;

  /// Policy loader used for initialization.
  final PolicyLoader policyLoader;

  /// Recommendation builder used for high-level outputs.
  final RecommendationBuilder recommendationBuilder;

  /// Difficulty-transition resolver used for recommendation and trace building.
  final DifficultyTransitionResolver transitionResolver;

  /// Decision-trace builder used for explainable execution output.
  final DecisionTraceBuilder decisionTraceBuilder;

  /// Session evaluator used for session summaries and validation.
  final SessionEvaluator sessionEvaluator;

  /// Analytics snapshot builder.
  final AnalyticsSnapshotBuilder analyticsSnapshotBuilder;

  /// Execution trace formatter.
  final ExecutionTraceFormatter executionTraceFormatter;

  /// Probability summary builder.
  final ProbabilitySummaryBuilder probabilitySummaryBuilder;

  final Map<String, SessionTracker> _sessionTrackers;

  AdaptiveRuntimeEngine? _runtimeEngine;
  LoadedPolicy? _loadedPolicy;

  /// Creates a facade instance.
  AdaptiveGamificationLibrary({
    this.config = const LibraryConfig(),
    PolicyLoader? policyLoader,
    RecommendationBuilder? recommendationBuilder,
    DifficultyTransitionResolver? transitionResolver,
    DecisionTraceBuilder? decisionTraceBuilder,
    SessionEvaluator? sessionEvaluator,
    AnalyticsSnapshotBuilder? analyticsSnapshotBuilder,
    ExecutionTraceFormatter? executionTraceFormatter,
    ProbabilitySummaryBuilder? probabilitySummaryBuilder,
    Map<String, SessionTracker>? sessionTrackers,
  })  : policyLoader = policyLoader ?? PolicyLoader(config: config.runtime),
        recommendationBuilder =
            recommendationBuilder ?? const RecommendationBuilder(),
        transitionResolver =
            transitionResolver ?? const DifficultyTransitionResolver(),
        decisionTraceBuilder =
            decisionTraceBuilder ?? const DecisionTraceBuilder(),
        sessionEvaluator = sessionEvaluator ?? const SessionEvaluator(),
        analyticsSnapshotBuilder =
            analyticsSnapshotBuilder ?? const AnalyticsSnapshotBuilder(),
        executionTraceFormatter =
            executionTraceFormatter ?? const ExecutionTraceFormatter(),
        probabilitySummaryBuilder =
            probabilitySummaryBuilder ?? const ProbabilitySummaryBuilder(),
        _sessionTrackers = sessionTrackers ?? <String, SessionTracker>{};

  /// Loads policy data from a JSON string and initializes the runtime engine.
  void initializeFromJsonString(String jsonString) {
    final loadedPolicy = policyLoader.loadFromJsonString(jsonString);
    _initializeRuntime(loadedPolicy);
  }

  /// Loads policy data from a raw map and initializes the runtime engine.
  void initializeFromMap(Map<String, dynamic> map) {
    final loadedPolicy = policyLoader.loadFromMap(map);
    _initializeRuntime(loadedPolicy);
  }

  void _initializeRuntime(LoadedPolicy loadedPolicy) {
    final stateKeyBuilder = StateKeyBuilder(
      decimals: config.runtime.stateKeyDecimals,
      clampValues: config.runtime.clampStateValues,
    );

    final decisionEngine = DecisionEngine(
      indexedDecisions: loadedPolicy.indexedDecisions,
      metadata: loadedPolicy.metadata,
      stateKeyBuilder: stateKeyBuilder,
      fallbackStrategy: config.runtime.fallbackStrategy,
      enableDiagnostics: config.diagnostics.enableRuntimeDiagnostics,
    );

    _loadedPolicy = loadedPolicy;
    _runtimeEngine = AdaptiveRuntimeEngine(
      loadedPolicy: loadedPolicy,
      decisionEngine: decisionEngine,
    );
  }

  /// Returns whether the runtime has been initialized.
  bool get isInitialized => _runtimeEngine != null && _loadedPolicy != null;

  /// Returns the currently loaded policy, if available.
  LoadedPolicy? get loadedPolicy => _loadedPolicy;

  /// Returns the runtime engine, if available.
  AdaptiveRuntimeEngine? get runtimeEngine => _runtimeEngine;

  /// Returns the number of tracked sessions currently held by the facade.
  int get trackedSessionCount => _sessionTrackers.length;

  /// Returns a decision execution result for [state].
  DecisionExecutionResult execute({
    required AdaptiveState state,
    String? sessionId,
    String? interactionId,
  }) {
    final runtime = _requireRuntime();
    return runtime.execute(
      inputState: state,
      sessionId: sessionId,
      interactionId: interactionId,
    );
  }

  /// Returns only the adaptive decision for [state].
  AdaptiveDecision getDecision({
    required AdaptiveState state,
    String? sessionId,
    String? interactionId,
  }) {
    return execute(
      state: state,
      sessionId: sessionId,
      interactionId: interactionId,
    ).decision;
  }

  /// Returns a high-level recommendation for [state].
  AdaptiveRecommendation getRecommendation({
    required AdaptiveState state,
    String? sessionId,
    String? interactionId,
    int? currentDifficultyRank,
  }) {
    final result = execute(
      state: state,
      sessionId: sessionId,
      interactionId: interactionId,
    );

    final transition = transitionResolver.resolve(
      result.decision,
      currentDifficultyRank: currentDifficultyRank,
    );

    return recommendationBuilder.build(
      result.decision,
      context: result.context,
      transition: transition,
      currentDifficultyRank: currentDifficultyRank,
    );
  }

  /// Returns a rich decision trace for [state].
  DecisionTrace getDecisionTrace({
    required AdaptiveState state,
    String? sessionId,
    String? interactionId,
    int? currentDifficultyRank,
    String? traceId,
    List<String> warnings = const <String>[],
    String? note,
    DateTime? timestamp,
  }) {
    final result = execute(
      state: state,
      sessionId: sessionId,
      interactionId: interactionId,
    );

    return decisionTraceBuilder.build(
      decision: result.decision,
      context: result.context,
      currentDifficultyRank: currentDifficultyRank,
      traceId: traceId,
      warnings: warnings,
      note: note,
      timestamp: timestamp,
    );
  }

  /// Returns lightweight runtime diagnostics for [state].
  RuntimeDiagnostics? getRuntimeDiagnostics({
    required AdaptiveState state,
    String? sessionId,
    String? interactionId,
  }) {
    final result = execute(
      state: state,
      sessionId: sessionId,
      interactionId: interactionId,
    );
    return result.diagnostics;
  }

  /// Returns an execution trace for [state].
  ExecutionTrace getExecutionTrace({
    required AdaptiveState state,
    String? sessionId,
    String? interactionId,
    int? currentDifficultyRank,
    String? traceId,
    String? phase,
    String? note,
    DateTime? timestamp,
  }) {
    final result = execute(
      state: state,
      sessionId: sessionId,
      interactionId: interactionId,
    );

    final decisionTrace = decisionTraceBuilder.build(
      decision: result.decision,
      context: result.context,
      currentDifficultyRank: currentDifficultyRank,
      traceId: traceId,
      note: note,
      timestamp: timestamp,
    );

    return ExecutionTrace(
      traceId: traceId ?? 'exec_${result.context.generatedStateKey}',
      phase: phase ?? 'runtime_execution',
      diagnostics: result.diagnostics,
      decisionTrace: decisionTrace,
      policyMetadata: _loadedPolicy?.metadata,
      indexedPolicySize: _loadedPolicy?.policySize,
      note: note,
      timestamp: timestamp,
    );
  }

  /// Returns a formatted execution trace string for [state].
  String formatExecutionTrace({
    required AdaptiveState state,
    String? sessionId,
    String? interactionId,
    int? currentDifficultyRank,
    String? traceId,
    String? phase,
    String? note,
    DateTime? timestamp,
  }) {
    final trace = getExecutionTrace(
      state: state,
      sessionId: sessionId,
      interactionId: interactionId,
      currentDifficultyRank: currentDifficultyRank,
      traceId: traceId,
      phase: phase,
      note: note,
      timestamp: timestamp,
    );

    return executionTraceFormatter.formatExecutionTrace(trace);
  }

  /// Creates or returns an existing tracker for [sessionId].
  SessionTracker getOrCreateSessionTracker(String sessionId) {
    return _sessionTrackers.putIfAbsent(
      sessionId,
          () => SessionTracker(sessionId: sessionId),
    );
  }

  /// Returns a tracker for [sessionId], if one exists.
  SessionTracker? getSessionTracker(String sessionId) {
    return _sessionTrackers[sessionId];
  }

  /// Removes the tracker for [sessionId], if one exists.
  void removeSessionTracker(String sessionId) {
    _sessionTrackers.remove(sessionId);
  }

  /// Records [interaction] into the corresponding session tracker.
  void recordInteraction(InteractionEvent interaction) {
    final tracker = getOrCreateSessionTracker(interaction.sessionId);
    tracker.recordInteraction(interaction);
  }

  /// Returns a current session snapshot for [sessionId], if tracked.
  SessionSnapshot? getSessionSnapshot(String sessionId) {
    final tracker = getSessionTracker(sessionId);
    if (tracker == null) return null;
    return sessionEvaluator.evaluateTracker(tracker);
  }

  /// Returns a session summary for [sessionId], if tracked and non-empty.
  AdaptiveSessionSummary? getSessionSummary(
      String sessionId, {
        DifficultyTransition? overallTransition,
        String? status,
        List<String> tags = const <String>[],
      }) {
    final tracker = getSessionTracker(sessionId);
    if (tracker == null || !tracker.hasInteractions) {
      return null;
    }

    return sessionEvaluator.evaluateTrackerSummary(
      tracker: tracker,
      overallTransition: overallTransition,
      status: status,
      tags: tags,
    );
  }

  /// Returns a lightweight analytics snapshot from a tracked session.
  AnalyticsSnapshot? getAnalyticsSnapshot(
      String sessionId, {
        DifficultyTransition? latestTransition,
        int? decisionCount,
        int? fallbackCount,
        String? scope,
        String? note,
        List<String> tags = const <String>[],
        DateTime? timestamp,
      }) {
    final snapshot = getSessionSnapshot(sessionId);
    if (snapshot == null) return null;

    return analyticsSnapshotBuilder.buildFromSessionSnapshot(
      snapshotId: 'analytics_$sessionId',
      sessionSnapshot: snapshot,
      latestTransition: latestTransition,
      decisionCount: decisionCount,
      fallbackCount: fallbackCount,
      scope: scope,
      note: note,
      tags: tags,
      timestamp: timestamp,
    );
  }

  AdaptiveRuntimeEngine _requireRuntime() {
    final runtime = _runtimeEngine;
    if (runtime == null) {
      throw const RuntimeExecutionException(
        'AdaptiveGamificationLibrary is not initialized. '
            'Load a policy before executing runtime decisions.',
      );
    }
    return runtime;
  }

  @override
  String toString() {
    return 'AdaptiveGamificationLibrary('
        'isInitialized: $isInitialized, '
        'trackedSessionCount: $trackedSessionCount, '
        'config: $config'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdaptiveGamificationLibrary &&
            other.config == config &&
            other._runtimeEngine == _runtimeEngine &&
            other._loadedPolicy == _loadedPolicy);
  }

  @override
  int get hashCode => Object.hash(
    config,
    _runtimeEngine,
    _loadedPolicy,
  );
}