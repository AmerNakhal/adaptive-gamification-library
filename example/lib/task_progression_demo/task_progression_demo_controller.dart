import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/foundation.dart';

import '../core/example_constants.dart';
import '../shared/services/demo_session_service.dart';
import '../shared/services/policy_asset_loader.dart';
import 'task_progression_demo_models.dart';
import 'task_progression_demo_state.dart';
import 'task_progression_seed_data.dart';

class TaskProgressionDemoController extends ChangeNotifier {
  final PolicyAssetLoader policyAssetLoader;
  final DemoSessionService demoSessionService;

  AdaptiveGamificationLibrary? _library;
  TaskProgressionDemoState _state;

  TaskProgressionDemoController({
    PolicyAssetLoader? policyAssetLoader,
    DemoSessionService? demoSessionService,
    String? sessionId,
  })  : policyAssetLoader = policyAssetLoader ?? const PolicyAssetLoader(),
        demoSessionService = demoSessionService ?? const DemoSessionService(),
        _state = TaskProgressionDemoState.initial(
          sessionId: sessionId ??
              '${ExampleConstants.taskDemoSessionPrefix}_${DateTime.now().millisecondsSinceEpoch}',
        );

  TaskProgressionDemoState get state => _state;

  AdaptiveGamificationLibrary? get library => _library;

  bool get isInitialized => _library != null && _state.isInitialized;

  Future<void> initialize() async {
    if (_state.isLoading) return;

    _state = _state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      final library = await policyAssetLoader.loadLibraryFromAsset(
        ExampleConstants.taskProgressionPolicyAsset,
        config: const LibraryConfig(
          diagnostics: DiagnosticsConfig(
            enableRuntimeDiagnostics: true,
          ),
        ),
      );

      _library = library;

      final initialAdaptiveState = _state.viewData?.adaptiveState ??
          const AdaptiveState(
            engagement: 0.50,
            motivation: 0.50,
            flow: 0.50,
            performance: 0.50,
          );

      final initialViewData = _buildViewData(
        library: library,
        adaptiveState: initialAdaptiveState,
        currentDifficultyRank: _state.currentDifficultyRank,
        itemIndex: _state.currentItemIndex,
      );

      demoSessionService.updateStateSnapshot(
        library: library,
        sessionId: _state.sessionId,
        stateSnapshot: StateSnapshot(
          state: initialViewData.adaptiveState,
          sessionId: _state.sessionId,
          timestamp: DateTime.now(),
        ),
      );

      _state = _state.copyWith(
        isLoading: false,
        isInitialized: true,
        currentItem: TaskProgressionSeedData.itemByIndex(0),
        viewData: initialViewData,
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize task progression demo: $error',
      );
      notifyListeners();
    }
  }

  Future<void> resetDemo() async {
    final nextSessionId =
        '${ExampleConstants.taskDemoSessionPrefix}_${DateTime.now().millisecondsSinceEpoch}';

    if (_library != null) {
      demoSessionService.clearSession(_library!, _state.sessionId);
    }

    _state = TaskProgressionDemoState.initial(sessionId: nextSessionId);
    notifyListeners();

    await initialize();
  }

  Future<void> submitProgress({
    required double completion,
    required double successRate,
    required double pace,
    required double fatigue,
    required int retryCount,
  }) async {
    final library = _library;
    if (library == null || !_state.isInitialized || _state.isLoading) {
      return;
    }

    _state = _state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      final item = _state.currentItem;
      final wasSuccessful = successRate >= 0.5;

      final record = TaskProgressionRecord(
        taskId: item.id,
        wasSuccessful: wasSuccessful,
        completion: completion,
        successRate: successRate,
        pace: pace,
        fatigue: fatigue,
        retryCount: retryCount,
        difficultyRank: _state.currentDifficultyRank,
        difficultyLabel: _state.currentDifficultyLabel,
        completedAt: DateTime.now(),
      );

      final updatedRecords = List<TaskProgressionRecord>.from(_state.records)
        ..add(record);

      final updatedCompletedCount = _state.completedCount + 1;
      final updatedSuccessfulCount =
          _state.successfulCount + (wasSuccessful ? 1 : 0);
      final updatedUnsuccessfulCount =
          _state.unsuccessfulCount + (wasSuccessful ? 0 : 1);
      final updatedRetryCount = _state.cumulativeRetryCount + retryCount;

      const adapter = TaskProgressionStateAdapter();
      final adaptiveState = adapter.adapt(<String, dynamic>{
        'completion': completion,
        'successRate': successRate,
        'pace': pace,
        'retryCount': retryCount.toDouble(),
        'fatigue': fatigue,
      });

      final interactionId = 'task_interaction_${updatedRecords.length}';

      final executionResult = library.execute(
        state: adaptiveState,
        sessionId: _state.sessionId,
        interactionId: interactionId,
      );

      final recommendation = library.getRecommendation(
        state: adaptiveState,
        sessionId: _state.sessionId,
        interactionId: interactionId,
        currentDifficultyRank: _state.currentDifficultyRank,
      );

      final now = DateTime.now();

      demoSessionService.recordInteraction(
        library,
        InteractionEvent(
          interactionId: interactionId,
          sessionId: _state.sessionId,
          taskId: item.id,
          eventType: 'task_progress_submitted',
          difficultyRank: _state.currentDifficultyRank,
          difficultyLabel: _state.currentDifficultyLabel,
          responseTime: null,
          streak: wasSuccessful ? updatedSuccessfulCount.toDouble() : 0.0,
          outcome: TaskOutcome(
            taskId: item.id,
            wasSuccessful: wasSuccessful,
            score: successRate,
            retryCount: retryCount,
            difficultyRank: _state.currentDifficultyRank,
            difficultyLabel: _state.currentDifficultyLabel,
            timestamp: now,
            sessionId: _state.sessionId,
            note:
            'completion=$completion, successRate=$successRate, pace=$pace, fatigue=$fatigue',
          ),
          timestamp: now,
          note: 'Task progression submission',
        ),
      );

      demoSessionService.updateRecommendation(
        library: library,
        sessionId: _state.sessionId,
        recommendation: recommendation,
      );

      demoSessionService.updateStateSnapshot(
        library: library,
        sessionId: _state.sessionId,
        stateSnapshot: StateSnapshot(
          state: adaptiveState,
          sessionId: _state.sessionId,
          timestamp: now,
        ),
      );

      final nextDifficultyRank = executionResult.decision.nextDifficulty;
      final nextDifficultyLabel = DifficultyLevel.fromRank(nextDifficultyRank);

      final nextItemIndex = _state.isLastItem
          ? _state.currentItemIndex
          : _state.currentItemIndex + 1;

      final nextItem = TaskProgressionSeedData.itemByIndex(nextItemIndex);

      final updatedViewData = _buildViewData(
        library: library,
        adaptiveState: adaptiveState,
        currentDifficultyRank: _state.currentDifficultyRank,
        itemIndex: nextItemIndex,
      );

      _state = _state.copyWith(
        isLoading: false,
        records: updatedRecords,
        completedCount: updatedCompletedCount,
        successfulCount: updatedSuccessfulCount,
        unsuccessfulCount: updatedUnsuccessfulCount,
        cumulativeRetryCount: updatedRetryCount,
        currentDifficultyRank: nextDifficultyRank,
        currentDifficultyLabel: nextDifficultyLabel,
        currentItemIndex: nextItemIndex,
        currentItem: nextItem,
        viewData: updatedViewData.copyWith(
          recommendation: recommendation,
        ),
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit task progression data: $error',
      );
      notifyListeners();
    }
  }

  Future<void> refreshAnalytics() async {
    final library = _library;
    if (library == null || !_state.isInitialized) return;

    try {
      final adaptiveState = _state.viewData?.adaptiveState ??
          const AdaptiveState(
            engagement: 0.50,
            motivation: 0.50,
            flow: 0.50,
            performance: 0.50,
          );

      final updatedViewData = _buildViewData(
        library: library,
        adaptiveState: adaptiveState,
        currentDifficultyRank: _state.currentDifficultyRank,
        itemIndex: _state.currentItemIndex,
      );

      _state = _state.copyWith(viewData: updatedViewData);
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        errorMessage: 'Failed to refresh analytics: $error',
      );
      notifyListeners();
    }
  }

  TaskProgressionDemoViewData _buildViewData({
    required AdaptiveGamificationLibrary library,
    required AdaptiveState adaptiveState,
    required int currentDifficultyRank,
    required int itemIndex,
  }) {
    final interactionId = 'task_preview_${itemIndex + 1}';

    final decision = library.getDecision(
      state: adaptiveState,
      sessionId: _state.sessionId,
      interactionId: interactionId,
    );

    final recommendation = library.getRecommendation(
      state: adaptiveState,
      sessionId: _state.sessionId,
      interactionId: interactionId,
      currentDifficultyRank: currentDifficultyRank,
    );

    final decisionTrace = library.getDecisionTrace(
      state: adaptiveState,
      sessionId: _state.sessionId,
      interactionId: interactionId,
      currentDifficultyRank: currentDifficultyRank,
      note: 'Task progression preview trace',
    );

    final executionTrace = library.getExecutionTrace(
      state: adaptiveState,
      sessionId: _state.sessionId,
      interactionId: interactionId,
      currentDifficultyRank: currentDifficultyRank,
      phase: ExampleConstants.defaultRuntimePhase,
      note: 'Task progression execution trace',
    );

    final formattedExecutionTrace = library.formatExecutionTrace(
      state: adaptiveState,
      sessionId: _state.sessionId,
      interactionId: interactionId,
      currentDifficultyRank: currentDifficultyRank,
      phase: ExampleConstants.defaultRuntimePhase,
    );

    final sessionSnapshot = demoSessionService.getSnapshot(
      library,
      _state.sessionId,
    );

    final sessionSummary = demoSessionService.getSummary(
      library: library,
      sessionId: _state.sessionId,
      overallTransition: recommendation.transition,
      status: 'task_progression_active',
      tags: const <String>['task_progression_demo'],
    );

    final fallbackCount = decision.source == DecisionSource.fallback ? 1 : 0;

    final analyticsSnapshot = demoSessionService.getAnalyticsSnapshot(
      library: library,
      sessionId: _state.sessionId,
      latestTransition: recommendation.transition,
      decisionCount: _state.records.length,
      fallbackCount: fallbackCount,
      scope: 'task_progression_demo',
      note: 'Task progression analytics snapshot',
      tags: const <String>['task_progression_demo', 'adaptive_runtime'],
      timestamp: DateTime.now(),
    );

    return TaskProgressionDemoViewData(
      adaptiveState: adaptiveState,
      decision: decision,
      recommendation: recommendation,
      decisionTrace: decisionTrace,
      executionTrace: executionTrace,
      sessionSnapshot: sessionSnapshot,
      sessionSummary: sessionSummary,
      analyticsSnapshot: analyticsSnapshot,
      formattedExecutionTrace: formattedExecutionTrace,
    );
  }
}