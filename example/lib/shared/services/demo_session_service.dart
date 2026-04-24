import 'package:adaptive_gamification/adaptive_gamification.dart';

class DemoSessionService {
  const DemoSessionService();

  void ensureTracker(
      AdaptiveGamificationLibrary library,
      String sessionId,
      ) {
    library.getOrCreateSessionTracker(sessionId);
  }

  void recordInteraction(
      AdaptiveGamificationLibrary library,
      InteractionEvent interaction,
      ) {
    library.recordInteraction(interaction);
  }

  void updateRecommendation({
    required AdaptiveGamificationLibrary library,
    required String sessionId,
    required AdaptiveRecommendation recommendation,
  }) {
    final tracker = library.getOrCreateSessionTracker(sessionId);
    tracker.updateRecommendation(recommendation);
  }

  void updateStateSnapshot({
    required AdaptiveGamificationLibrary library,
    required String sessionId,
    required StateSnapshot stateSnapshot,
  }) {
    final tracker = library.getOrCreateSessionTracker(sessionId);
    tracker.updateCurrentState(stateSnapshot);
  }

  SessionSnapshot? getSnapshot(
      AdaptiveGamificationLibrary library,
      String sessionId,
      ) {
    return library.getSessionSnapshot(sessionId);
  }

  AdaptiveSessionSummary? getSummary({
    required AdaptiveGamificationLibrary library,
    required String sessionId,
    DifficultyTransition? overallTransition,
    String? status,
    List<String> tags = const <String>[],
  }) {
    return library.getSessionSummary(
      sessionId,
      overallTransition: overallTransition,
      status: status,
      tags: tags,
    );
  }

  AnalyticsSnapshot? getAnalyticsSnapshot({
    required AdaptiveGamificationLibrary library,
    required String sessionId,
    DifficultyTransition? latestTransition,
    int? decisionCount,
    int? fallbackCount,
    String? scope,
    String? note,
    List<String> tags = const <String>[],
    DateTime? timestamp,
  }) {
    return library.getAnalyticsSnapshot(
      sessionId,
      latestTransition: latestTransition,
      decisionCount: decisionCount,
      fallbackCount: fallbackCount,
      scope: scope,
      note: note,
      tags: tags,
      timestamp: timestamp,
    );
  }

  void clearSession(
      AdaptiveGamificationLibrary library,
      String sessionId,
      ) {
    library.removeSessionTracker(sessionId);
  }
}