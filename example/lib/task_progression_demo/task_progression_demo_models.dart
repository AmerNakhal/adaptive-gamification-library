import 'package:adaptive_gamification/adaptive_gamification.dart';

class TaskProgressionItem {
  final String id;
  final String title;
  final String description;
  final int baseDifficultyRank;
  final String baseDifficultyLabel;
  final double targetCompletion;
  final double expectedPace;

  const TaskProgressionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.baseDifficultyRank,
    required this.baseDifficultyLabel,
    required this.targetCompletion,
    required this.expectedPace,
  });
}

class TaskProgressionRecord {
  final String taskId;
  final bool wasSuccessful;
  final double completion;
  final double successRate;
  final double pace;
  final double fatigue;
  final int retryCount;
  final int difficultyRank;
  final String difficultyLabel;
  final DateTime completedAt;

  const TaskProgressionRecord({
    required this.taskId,
    required this.wasSuccessful,
    required this.completion,
    required this.successRate,
    required this.pace,
    required this.fatigue,
    required this.retryCount,
    required this.difficultyRank,
    required this.difficultyLabel,
    required this.completedAt,
  });
}

class TaskProgressionDemoViewData {
  final AdaptiveState adaptiveState;
  final AdaptiveDecision? decision;
  final AdaptiveRecommendation? recommendation;
  final DecisionTrace? decisionTrace;
  final ExecutionTrace? executionTrace;
  final SessionSnapshot? sessionSnapshot;
  final AdaptiveSessionSummary? sessionSummary;
  final AnalyticsSnapshot? analyticsSnapshot;
  final String? formattedExecutionTrace;

  const TaskProgressionDemoViewData({
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

  TaskProgressionDemoViewData copyWith({
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
    return TaskProgressionDemoViewData(
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