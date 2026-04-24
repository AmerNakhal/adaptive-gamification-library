import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/foundation.dart';

import '../core/example_constants.dart';
import '../shared/services/demo_session_service.dart';
import '../shared/services/policy_asset_loader.dart';
import 'quiz_demo_models.dart';
import 'quiz_demo_seed_data.dart';
import 'quiz_demo_state.dart';

class QuizDemoController extends ChangeNotifier {
  final PolicyAssetLoader policyAssetLoader;
  final DemoSessionService demoSessionService;

  AdaptiveGamificationLibrary? _library;
  QuizDemoState _state;

  QuizDemoController({
    PolicyAssetLoader? policyAssetLoader,
    DemoSessionService? demoSessionService,
    String? sessionId,
  })  : policyAssetLoader = policyAssetLoader ?? const PolicyAssetLoader(),
        demoSessionService = demoSessionService ?? const DemoSessionService(),
        _state = QuizDemoState.initial(
          sessionId: sessionId ??
              '${ExampleConstants.quizDemoSessionPrefix}_${DateTime.now().millisecondsSinceEpoch}',
        );

  QuizDemoState get state => _state;

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
        ExampleConstants.quizPolicyAsset,
        config: const LibraryConfig(
          diagnostics: DiagnosticsConfig(
            enableRuntimeDiagnostics: true,
          ),
        ),
      );

      _library = library;

      final initialViewData = _buildViewData(
        library: library,
        adaptiveState: _state.viewData?.adaptiveState ??
            const AdaptiveState(
              engagement: 0.50,
              motivation: 0.50,
              flow: 0.50,
              performance: 0.50,
            ),
        currentDifficultyRank: _state.currentDifficultyRank,
        questionIndex: _state.currentQuestionIndex,
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
        currentQuestion: QuizDemoSeedData.questionByIndex(0),
        viewData: initialViewData,
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize quiz demo: $error',
      );
      notifyListeners();
    }
  }

  Future<void> resetDemo() async {
    final currentSessionId =
        '${ExampleConstants.quizDemoSessionPrefix}_${DateTime.now().millisecondsSinceEpoch}';

    if (_library != null) {
      demoSessionService.clearSession(_library!, _state.sessionId);
    }

    _state = QuizDemoState.initial(sessionId: currentSessionId);
    notifyListeners();

    await initialize();
  }

  Future<void> submitAnswer({
    required int selectedIndex,
    required double responseTimeSeconds,
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
      final question = _state.currentQuestion;
      final isCorrect = question.isCorrect(selectedIndex);

      final answerRecord = QuizAnswerRecord(
        questionId: question.id,
        selectedIndex: selectedIndex,
        isCorrect: isCorrect,
        responseTimeSeconds: responseTimeSeconds,
        difficultyRank: _state.currentDifficultyRank,
        difficultyLabel: _state.currentDifficultyLabel,
        answeredAt: DateTime.now(),
      );

      final updatedAnswers = List<QuizAnswerRecord>.from(_state.answers)
        ..add(answerRecord);

      final updatedCorrectCount =
          _state.correctCount + (isCorrect ? 1 : 0);
      final updatedIncorrectCount =
          _state.incorrectCount + (isCorrect ? 0 : 1);
      final updatedStreakCount = isCorrect ? _state.streakCount + 1 : 0;

      final correctness = updatedAnswers.isEmpty
          ? 0.0
          : updatedCorrectCount / updatedAnswers.length;
      final completion =
          updatedAnswers.length / QuizDemoSeedData.questions.length;

      const adapter = QuizStateAdapter();
      final adaptiveState = adapter.adapt(<String, dynamic>{
        'correctness': correctness,
        'responseTime': responseTimeSeconds,
        'streak': updatedStreakCount.toDouble(),
        'completion': completion,
      });

      final executionResult = library.execute(
        state: adaptiveState,
        sessionId: _state.sessionId,
        interactionId: 'quiz_interaction_${updatedAnswers.length}',
      );

      final recommendation = library.getRecommendation(
        state: adaptiveState,
        sessionId: _state.sessionId,
        interactionId: 'quiz_interaction_${updatedAnswers.length}',
        currentDifficultyRank: _state.currentDifficultyRank,
      );

      final now = DateTime.now();

      demoSessionService.recordInteraction(
        library,
        InteractionEvent(
          interactionId: 'quiz_interaction_${updatedAnswers.length}',
          sessionId: _state.sessionId,
          taskId: question.id,
          eventType: 'quiz_answer_submitted',
          difficultyRank: _state.currentDifficultyRank,
          difficultyLabel: _state.currentDifficultyLabel,
          responseTime: responseTimeSeconds,
          streak: updatedStreakCount.toDouble(),
          outcome: TaskOutcome(
            taskId: question.id,
            wasSuccessful: isCorrect,
            score: isCorrect ? 1.0 : 0.0,
            retryCount: 0,
            difficultyRank: _state.currentDifficultyRank,
            difficultyLabel: _state.currentDifficultyLabel,
            timestamp: now,
            sessionId: _state.sessionId,
            note: question.explanation,
          ),
          timestamp: now,
          note: 'Selected option index: $selectedIndex',
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

      final nextQuestionIndex = _state.isLastQuestion
          ? _state.currentQuestionIndex
          : _state.currentQuestionIndex + 1;

      final nextQuestion = QuizDemoSeedData.questionByIndex(nextQuestionIndex);

      final updatedViewData = _buildViewData(
        library: library,
        adaptiveState: adaptiveState,
        currentDifficultyRank: _state.currentDifficultyRank,
        questionIndex: nextQuestionIndex,
      );

      _state = _state.copyWith(
        isLoading: false,
        answers: updatedAnswers,
        correctCount: updatedCorrectCount,
        incorrectCount: updatedIncorrectCount,
        streakCount: updatedStreakCount,
        currentDifficultyRank: nextDifficultyRank,
        currentDifficultyLabel: nextDifficultyLabel,
        currentQuestionIndex: nextQuestionIndex,
        currentQuestion: nextQuestion,
        viewData: updatedViewData.copyWith(
          recommendation: recommendation,
        ),
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit answer: $error',
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
        questionIndex: _state.currentQuestionIndex,
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

  QuizDemoViewData _buildViewData({
    required AdaptiveGamificationLibrary library,
    required AdaptiveState adaptiveState,
    required int currentDifficultyRank,
    required int questionIndex,
  }) {
    final interactionId = 'quiz_preview_${questionIndex + 1}';

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
      note: 'Quiz demo preview trace',
    );

    final executionTrace = library.getExecutionTrace(
      state: adaptiveState,
      sessionId: _state.sessionId,
      interactionId: interactionId,
      currentDifficultyRank: currentDifficultyRank,
      phase: ExampleConstants.defaultRuntimePhase,
      note: 'Quiz demo execution trace',
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
      status: 'quiz_demo_active',
      tags: const <String>['quiz_demo'],
    );

    final analyticsSnapshot = demoSessionService.getAnalyticsSnapshot(
      library: library,
      sessionId: _state.sessionId,
      latestTransition: recommendation.transition,
      decisionCount: _state.answers.length,
      fallbackCount: decision.source == DecisionSource.fallback ? 1 : 0,
      scope: 'quiz_demo',
      note: 'Quiz demo analytics snapshot',
      tags: const <String>['quiz_demo', 'adaptive_runtime'],
      timestamp: DateTime.now(),
    );

    return QuizDemoViewData(
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