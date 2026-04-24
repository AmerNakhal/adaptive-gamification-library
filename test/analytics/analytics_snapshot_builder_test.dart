import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/analytics/analytics_snapshot_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsSnapshotBuilder', () {
    const builder = AnalyticsSnapshotBuilder();

    SessionStatistics buildStatistics() {
      return const SessionStatistics(
        interactionCount: 3,
        successfulCount: 2,
        unsuccessfulCount: 1,
        averageScore: 0.75,
        averageResponseTime: 18.0,
        averageStreak: 2.0,
        averageDifficultyRank: 2.0,
        minDifficultyRank: 1,
        maxDifficultyRank: 3,
        totalRetryCount: 2,
      );
    }

    StateSnapshot buildStateSnapshot() {
      return const StateSnapshot(
        state: AdaptiveState(
          engagement: 0.4,
          motivation: 0.5,
          flow: 0.6,
          performance: 0.7,
        ),
        sessionId: 'session_1',
        timestamp: null,
      );
    }

    DifficultyTransition buildTransition() {
      return const DifficultyTransition(
        beforeRank: 1,
        afterRank: 2,
        beforeLevel: 'easy',
        afterLevel: 'medium',
        changeType: 'increase',
        delta: 1,
      );
    }

    AdaptiveRecommendation buildRecommendation() {
      return const AdaptiveRecommendation(
        id: 'rec_1',
        type: 'difficulty_adjustment',
        priority: 'medium',
        title: 'Increase challenge',
        message: 'A higher difficulty level is recommended.',
        decision: AdaptiveDecision(
          nextDifficulty: 2,
          source: 'exact_match',
          actionLabel: 'medium_task',
        ),
      );
    }

    SessionSnapshot buildSessionSnapshot() {
      return SessionSnapshot(
        sessionId: 'session_1',
        currentState: buildStateSnapshot(),
        latestInteraction: null,
        latestOutcome: null,
        statistics: buildStatistics(),
        latestRecommendation: buildRecommendation(),
        interactionCount: 3,
        startedAt: DateTime.parse('2026-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2026-01-01T11:00:00Z'),
        note: 'session note',
      );
    }

    test('build creates analytics snapshot from explicit components', () {
      final snapshot = builder.build(
        snapshotId: 'snap_1',
        sessionId: 'session_1',
        scope: 'runtime_checkpoint',
        stateSnapshot: buildStateSnapshot(),
        sessionStatistics: buildStatistics(),
        latestTransition: buildTransition(),
        latestRecommendation: buildRecommendation(),
        decisionCount: 10,
        fallbackCount: 2,
        note: 'analytics note',
        tags: const <String>['checkpoint', 'runtime'],
        timestamp: DateTime.parse('2026-01-01T12:00:00Z'),
      );

      expect(snapshot.snapshotId, 'snap_1');
      expect(snapshot.sessionId, 'session_1');
      expect(snapshot.scope, 'runtime_checkpoint');
      expect(snapshot.stateSnapshot, isNotNull);
      expect(snapshot.sessionStatistics, isNotNull);
      expect(snapshot.latestTransition, isNotNull);
      expect(snapshot.latestRecommendation, isNotNull);
      expect(snapshot.decisionCount, 10);
      expect(snapshot.fallbackCount, 2);
      expect(snapshot.note, 'analytics note');
      expect(snapshot.tags, <String>['checkpoint', 'runtime']);
      expect(snapshot.timestamp, DateTime.parse('2026-01-01T12:00:00Z'));

      expect(snapshot.hasStateSnapshot, isTrue);
      expect(snapshot.hasSessionStatistics, isTrue);
      expect(snapshot.hasLatestTransition, isTrue);
      expect(snapshot.hasLatestRecommendation, isTrue);
      expect(snapshot.hasTags, isTrue);
      expect(snapshot.fallbackRate, closeTo(0.2, 1e-9));
    });

    test('build handles nullable fields safely', () {
      final snapshot = builder.build(
        snapshotId: 'snap_2',
      );

      expect(snapshot.snapshotId, 'snap_2');
      expect(snapshot.sessionId, isNull);
      expect(snapshot.scope, isNull);
      expect(snapshot.stateSnapshot, isNull);
      expect(snapshot.sessionStatistics, isNull);
      expect(snapshot.latestTransition, isNull);
      expect(snapshot.latestRecommendation, isNull);
      expect(snapshot.decisionCount, isNull);
      expect(snapshot.fallbackCount, isNull);
      expect(snapshot.note, isNull);
      expect(snapshot.tags, isEmpty);
      expect(snapshot.timestamp, isNull);

      expect(snapshot.hasStateSnapshot, isFalse);
      expect(snapshot.hasSessionStatistics, isFalse);
      expect(snapshot.hasLatestTransition, isFalse);
      expect(snapshot.hasLatestRecommendation, isFalse);
      expect(snapshot.hasTags, isFalse);
      expect(snapshot.fallbackRate, isNull);
    });

    test('fallbackRate returns 0.0 when decisionCount is zero', () {
      final snapshot = builder.build(
        snapshotId: 'snap_3',
        decisionCount: 0,
        fallbackCount: 5,
      );

      expect(snapshot.fallbackRate, 0.0);
    });

    test('buildFromSessionSnapshot creates snapshot from session snapshot', () {
      final sessionSnapshot = buildSessionSnapshot();
      final transition = buildTransition();

      final analyticsSnapshot = builder.buildFromSessionSnapshot(
        snapshotId: 'analytics_session_1',
        sessionSnapshot: sessionSnapshot,
        latestTransition: transition,
        decisionCount: 12,
        fallbackCount: 3,
        scope: 'session_snapshot',
        note: 'built from session',
        tags: const <String>['session', 'analytics'],
      );

      expect(analyticsSnapshot.snapshotId, 'analytics_session_1');
      expect(analyticsSnapshot.sessionId, 'session_1');
      expect(analyticsSnapshot.scope, 'session_snapshot');
      expect(analyticsSnapshot.stateSnapshot, sessionSnapshot.currentState);
      expect(analyticsSnapshot.sessionStatistics, sessionSnapshot.statistics);
      expect(analyticsSnapshot.latestTransition, transition);
      expect(
        analyticsSnapshot.latestRecommendation,
        sessionSnapshot.latestRecommendation,
      );
      expect(analyticsSnapshot.decisionCount, 12);
      expect(analyticsSnapshot.fallbackCount, 3);
      expect(analyticsSnapshot.note, 'built from session');
      expect(
        analyticsSnapshot.tags,
        <String>['session', 'analytics'],
      );
      expect(
        analyticsSnapshot.timestamp,
        sessionSnapshot.updatedAt,
      );
    });

    test('buildFromSessionSnapshot uses default scope when not provided', () {
      final sessionSnapshot = buildSessionSnapshot();

      final analyticsSnapshot = builder.buildFromSessionSnapshot(
        snapshotId: 'analytics_default_scope',
        sessionSnapshot: sessionSnapshot,
      );

      expect(analyticsSnapshot.scope, 'session_snapshot');
    });

    test('buildFromSessionSnapshot uses explicit timestamp when provided', () {
      final sessionSnapshot = buildSessionSnapshot();
      final customTimestamp = DateTime.parse('2026-01-01T12:30:00Z');

      final analyticsSnapshot = builder.buildFromSessionSnapshot(
        snapshotId: 'analytics_custom_time',
        sessionSnapshot: sessionSnapshot,
        timestamp: customTimestamp,
      );

      expect(analyticsSnapshot.timestamp, customTimestamp);
    });

    test('toString returns readable type name', () {
      expect(
        builder.toString(),
        contains('AnalyticsSnapshotBuilder'),
      );
    });

    test('equality works for identical builders', () {
      const a = AnalyticsSnapshotBuilder();
      const b = AnalyticsSnapshotBuilder();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}