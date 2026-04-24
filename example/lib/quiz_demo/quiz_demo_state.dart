import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/foundation.dart';

import 'quiz_demo_models.dart';
import 'quiz_demo_seed_data.dart';

@immutable
class QuizDemoState {
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String sessionId;
  final int currentQuestionIndex;
  final int currentDifficultyRank;
  final String currentDifficultyLabel;
  final int correctCount;
  final int incorrectCount;
  final int streakCount;
  final QuizQuestion currentQuestion;
  final List<QuizAnswerRecord> answers;
  final QuizDemoViewData? viewData;

  const QuizDemoState({
    required this.isLoading,
    required this.isInitialized,
    required this.sessionId,
    required this.currentQuestionIndex,
    required this.currentDifficultyRank,
    required this.currentDifficultyLabel,
    required this.correctCount,
    required this.incorrectCount,
    required this.streakCount,
    required this.currentQuestion,
    required this.answers,
    this.errorMessage,
    this.viewData,
  });

  factory QuizDemoState.initial({
    required String sessionId,
  }) {
    return QuizDemoState(
      isLoading: false,
      isInitialized: false,
      sessionId: sessionId,
      currentQuestionIndex: 0,
      currentDifficultyRank: 2,
      currentDifficultyLabel: 'medium',
      correctCount: 0,
      incorrectCount: 0,
      streakCount: 0,
      currentQuestion: QuizDemoSeedData.questionByIndex(0),
      answers: const <QuizAnswerRecord>[],
      viewData: const QuizDemoViewData(
        adaptiveState: AdaptiveState(
          engagement: 0.50,
          motivation: 0.50,
          flow: 0.50,
          performance: 0.50,
        ),
      ),
    );
  }

  int get answeredCount => answers.length;

  int get totalQuestionCount => QuizDemoSeedData.questions.length;

  double get correctnessRate {
    if (answeredCount == 0) return 0.0;
    return correctCount / answeredCount;
  }

  double get completionRate {
    if (totalQuestionCount == 0) return 0.0;
    return answeredCount / totalQuestionCount;
  }

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  bool get hasViewData => viewData != null;

  bool get isLastQuestion => currentQuestionIndex >= totalQuestionCount - 1;

  QuizDemoState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? sessionId,
    int? currentQuestionIndex,
    int? currentDifficultyRank,
    String? currentDifficultyLabel,
    int? correctCount,
    int? incorrectCount,
    int? streakCount,
    QuizQuestion? currentQuestion,
    List<QuizAnswerRecord>? answers,
    QuizDemoViewData? viewData,
  }) {
    return QuizDemoState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      sessionId: sessionId ?? this.sessionId,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentDifficultyRank: currentDifficultyRank ?? this.currentDifficultyRank,
      currentDifficultyLabel:
      currentDifficultyLabel ?? this.currentDifficultyLabel,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      streakCount: streakCount ?? this.streakCount,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      answers: answers ?? this.answers,
      viewData: viewData ?? this.viewData,
    );
  }
}