import 'package:adaptive_gamification/adaptive_gamification.dart';

class QuizQuestion {
  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final int baseDifficultyRank;
  final String baseDifficultyLabel;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.baseDifficultyRank,
    required this.baseDifficultyLabel,
    required this.explanation,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

class QuizAnswerRecord {
  final String questionId;
  final int selectedIndex;
  final bool isCorrect;
  final double responseTimeSeconds;
  final int difficultyRank;
  final String difficultyLabel;
  final DateTime answeredAt;

  const QuizAnswerRecord({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.responseTimeSeconds,
    required this.difficultyRank,
    required this.difficultyLabel,
    required this.answeredAt,
  });
}

class QuizDemoViewData {
  final AdaptiveState adaptiveState;
  final AdaptiveDecision? decision;
  final AdaptiveRecommendation? recommendation;
  final DecisionTrace? decisionTrace;
  final ExecutionTrace? executionTrace;
  final SessionSnapshot? sessionSnapshot;
  final AdaptiveSessionSummary? sessionSummary;
  final AnalyticsSnapshot? analyticsSnapshot;
  final String? formattedExecutionTrace;

  const QuizDemoViewData({
    required this.adaptiveState,
    this.decision,
    this.recommendation,
    this.decisionTrace,
    this.executionTrace,
    this.sessionSnapshot,
    this.sessionSummary,
    this.analyticsSnapshot,
    this.formattedExecutionTrace,
  });

  QuizDemoViewData copyWith({
    AdaptiveState? adaptiveState,
    AdaptiveDecision? decision,
    AdaptiveRecommendation? recommendation,
    DecisionTrace? decisionTrace,
    ExecutionTrace? executionTrace,
    SessionSnapshot? sessionSnapshot,
    AdaptiveSessionSummary? sessionSummary,
    AnalyticsSnapshot? analyticsSnapshot,
    String? formattedExecutionTrace,
  }) {
    return QuizDemoViewData(
      adaptiveState: adaptiveState ?? this.adaptiveState,
      decision: decision ?? this.decision,
      recommendation: recommendation ?? this.recommendation,
      decisionTrace: decisionTrace ?? this.decisionTrace,
      executionTrace: executionTrace ?? this.executionTrace,
      sessionSnapshot: sessionSnapshot ?? this.sessionSnapshot,
      sessionSummary: sessionSummary ?? this.sessionSummary,
      analyticsSnapshot: analyticsSnapshot ?? this.analyticsSnapshot,
      formattedExecutionTrace:
      formattedExecutionTrace ?? this.formattedExecutionTrace,
    );
  }
}