import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/foundation.dart';

import 'task_progression_demo_models.dart';
import 'task_progression_seed_data.dart';

@immutable
class TaskProgressionDemoState {
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String sessionId;
  final int currentItemIndex;
  final int currentDifficultyRank;
  final String currentDifficultyLabel;
  final int completedCount;
  final int successfulCount;
  final int unsuccessfulCount;
  final int cumulativeRetryCount;
  final TaskProgressionItem currentItem;
  final List<TaskProgressionRecord> records;
  final TaskProgressionDemoViewData? viewData;

  const TaskProgressionDemoState({
    required this.isLoading,
    required this.isInitialized,
    required this.sessionId,
    required this.currentItemIndex,
    required this.currentDifficultyRank,
    required this.currentDifficultyLabel,
    required this.completedCount,
    required this.successfulCount,
    required this.unsuccessfulCount,
    required this.cumulativeRetryCount,
    required this.currentItem,
    required this.records,
    this.errorMessage,
    this.viewData,
  });

  factory TaskProgressionDemoState.initial({
    required String sessionId,
  }) {
    return TaskProgressionDemoState(
      isLoading: false,
      isInitialized: false,
      sessionId: sessionId,
      currentItemIndex: 0,
      currentDifficultyRank: 2,
      currentDifficultyLabel: 'medium',
      completedCount: 0,
      successfulCount: 0,
      unsuccessfulCount: 0,
      cumulativeRetryCount: 0,
      currentItem: TaskProgressionSeedData.itemByIndex(0),
      records: const <TaskProgressionRecord>[],
      viewData: const TaskProgressionDemoViewData(
        adaptiveState: AdaptiveState(
          engagement: 0.50,
          motivation: 0.50,
          flow: 0.50,
          performance: 0.50,
        ),
      ),
    );
  }

  int get totalItemCount => TaskProgressionSeedData.items.length;

  double get completionRate {
    if (totalItemCount == 0) return 0.0;
    return completedCount / totalItemCount;
  }

  double get successRate {
    if (completedCount == 0) return 0.0;
    return successfulCount / completedCount;
  }

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  bool get hasViewData => viewData != null;

  bool get isLastItem => currentItemIndex >= totalItemCount - 1;

  TaskProgressionDemoState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? sessionId,
    int? currentItemIndex,
    int? currentDifficultyRank,
    String? currentDifficultyLabel,
    int? completedCount,
    int? successfulCount,
    int? unsuccessfulCount,
    int? cumulativeRetryCount,
    TaskProgressionItem? currentItem,
    List<TaskProgressionRecord>? records,
    TaskProgressionDemoViewData? viewData,
  }) {
    return TaskProgressionDemoState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      sessionId: sessionId ?? this.sessionId,
      currentItemIndex: currentItemIndex ?? this.currentItemIndex,
      currentDifficultyRank: currentDifficultyRank ?? this.currentDifficultyRank,
      currentDifficultyLabel:
      currentDifficultyLabel ?? this.currentDifficultyLabel,
      completedCount: completedCount ?? this.completedCount,
      successfulCount: successfulCount ?? this.successfulCount,
      unsuccessfulCount: unsuccessfulCount ?? this.unsuccessfulCount,
      cumulativeRetryCount:
      cumulativeRetryCount ?? this.cumulativeRetryCount,
      currentItem: currentItem ?? this.currentItem,
      records: records ?? this.records,
      viewData: viewData ?? this.viewData,
    );
  }
}