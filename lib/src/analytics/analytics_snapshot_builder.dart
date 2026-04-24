import '../domain/analytics/analytics_snapshot.dart';
import '../domain/recommendations/adaptive_recommendation.dart';
import '../domain/sessions/session_snapshot.dart';
import '../domain/sessions/session_statistics.dart';
import '../domain/state/state_snapshot.dart';
import '../domain/transitions/difficulty_transition.dart';

/// Builds lightweight [AnalyticsSnapshot] objects from runtime or session data.
///
/// This builder is intended for:
/// - dashboards
/// - lightweight analytics checkpoints
/// - summarized reporting
/// - session-aware observability
class AnalyticsSnapshotBuilder {
  /// Creates an analytics snapshot builder.
  const AnalyticsSnapshotBuilder();

  /// Builds an [AnalyticsSnapshot] from explicit components.
  AnalyticsSnapshot build({
    required String snapshotId,
    String? sessionId,
    String? scope,
    StateSnapshot? stateSnapshot,
    SessionStatistics? sessionStatistics,
    DifficultyTransition? latestTransition,
    AdaptiveRecommendation? latestRecommendation,
    int? decisionCount,
    int? fallbackCount,
    String? note,
    List<String> tags = const <String>[],
    DateTime? timestamp,
  }) {
    return AnalyticsSnapshot(
      snapshotId: snapshotId,
      sessionId: sessionId,
      scope: scope,
      stateSnapshot: stateSnapshot,
      sessionStatistics: sessionStatistics,
      latestTransition: latestTransition,
      latestRecommendation: latestRecommendation,
      decisionCount: decisionCount,
      fallbackCount: fallbackCount,
      note: note,
      tags: List<String>.unmodifiable(tags),
      timestamp: timestamp,
    );
  }

  /// Builds an [AnalyticsSnapshot] from a [SessionSnapshot].
  AnalyticsSnapshot buildFromSessionSnapshot({
    required String snapshotId,
    required SessionSnapshot sessionSnapshot,
    DifficultyTransition? latestTransition,
    int? decisionCount,
    int? fallbackCount,
    String? scope,
    String? note,
    List<String> tags = const <String>[],
    DateTime? timestamp,
  }) {
    return AnalyticsSnapshot(
      snapshotId: snapshotId,
      sessionId: sessionSnapshot.sessionId,
      scope: scope ?? 'session_snapshot',
      stateSnapshot: sessionSnapshot.currentState,
      sessionStatistics: sessionSnapshot.statistics,
      latestTransition: latestTransition,
      latestRecommendation: sessionSnapshot.latestRecommendation,
      decisionCount: decisionCount,
      fallbackCount: fallbackCount,
      note: note,
      tags: List<String>.unmodifiable(tags),
      timestamp: timestamp ?? sessionSnapshot.updatedAt,
    );
  }

  @override
  String toString() => 'AnalyticsSnapshotBuilder()';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is AnalyticsSnapshotBuilder;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}