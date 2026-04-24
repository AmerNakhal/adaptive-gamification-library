import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionTracker', () {
    InteractionEvent buildInteraction({
      required String interactionId,
      required String sessionId,
      required String taskId,
      required String eventType,
      int? difficultyRank,
      String? difficultyLabel,
      double? responseTime,
      double? streak,
      TaskOutcome? outcome,
      DateTime? timestamp,
      String? note,
    }) {
      return InteractionEvent(
        interactionId: interactionId,
        sessionId: sessionId,
        taskId: taskId,
        eventType: eventType,
        difficultyRank: difficultyRank,
        difficultyLabel: difficultyLabel,
        responseTime: responseTime,
        streak: streak,
        outcome: outcome,
        timestamp: timestamp,
        note: note,
      );
    }

    TaskOutcome buildOutcome({
      required String taskId,
      required bool wasSuccessful,
      double? score,
      int? durationMs,
      int? retryCount,
      int? difficultyRank,
      String? difficultyLabel,
      DateTime? timestamp,
      String? sessionId,
      String? note,
    }) {
      return TaskOutcome(
        taskId: taskId,
        wasSuccessful: wasSuccessful,
        score: score,
        durationMs: durationMs,
        retryCount: retryCount,
        difficultyRank: difficultyRank,
        difficultyLabel: difficultyLabel,
        timestamp: timestamp,
        sessionId: sessionId,
        note: note,
      );
    }

    StateSnapshot buildStateSnapshot({
      String? sessionId,
      DateTime? timestamp,
    }) {
      return StateSnapshot(
        state: const AdaptiveState(
          engagement: 0.4,
          motivation: 0.5,
          flow: 0.6,
          performance: 0.7,
        ),
        sessionId: sessionId,
        timestamp: timestamp,
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
          nextDifficulty: 3,
          source: 'exact_match',
          actionLabel: 'hard_task',
        ),
      );
    }

    test('constructs with required sessionId', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      expect(tracker.sessionId, 'session_1');
      expect(tracker.interactions, isEmpty);
      expect(tracker.currentState, isNull);
      expect(tracker.latestRecommendation, isNull);
      expect(tracker.latestInteraction, isNull);
      expect(tracker.latestOutcome, isNull);
      expect(tracker.interactionCount, 0);
      expect(tracker.hasInteractions, isFalse);
      expect(tracker.hasCurrentState, isFalse);
      expect(tracker.hasLatestRecommendation, isFalse);
    });

    test('constructs with initial values', () {
      final interaction = buildInteraction(
        interactionId: 'i1',
        sessionId: 'session_1',
        taskId: 't1',
        eventType: 'task_attempt',
        outcome: buildOutcome(
          taskId: 't1',
          wasSuccessful: true,
          score: 0.9,
        ),
      );

      final stateSnapshot = buildStateSnapshot(sessionId: 'session_1');
      final recommendation = buildRecommendation();

      final tracker = SessionTracker(
        sessionId: 'session_1',
        initialInteractions: <InteractionEvent>[interaction],
        initialState: stateSnapshot,
        initialRecommendation: recommendation,
        note: 'initial note',
      );

      expect(tracker.interactions.length, 1);
      expect(tracker.currentState, stateSnapshot);
      expect(tracker.latestRecommendation, recommendation);
      expect(tracker.latestInteraction, interaction);
      expect(tracker.latestOutcome, isNotNull);
      expect(tracker.latestOutcome!.taskId, 't1');
      expect(tracker.interactionCount, 1);
      expect(tracker.hasInteractions, isTrue);
      expect(tracker.hasCurrentState, isTrue);
      expect(tracker.hasLatestRecommendation, isTrue);
    });

    test('interactions getter returns immutable copy', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      final interactions = tracker.interactions;

      expect(
            () => interactions.add(
          buildInteraction(
            interactionId: 'i1',
            sessionId: 'session_1',
            taskId: 't1',
            eventType: 'task_attempt',
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('recordInteraction appends interaction', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      final interaction = buildInteraction(
        interactionId: 'i1',
        sessionId: 'session_1',
        taskId: 't1',
        eventType: 'task_attempt',
        difficultyRank: 2,
        responseTime: 15.0,
        streak: 1.0,
      );

      tracker.recordInteraction(interaction);

      expect(tracker.interactionCount, 1);
      expect(tracker.hasInteractions, isTrue);
      expect(tracker.latestInteraction, interaction);
    });

    test('recordInteraction throws when sessionId mismatches', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      final interaction = buildInteraction(
        interactionId: 'i1',
        sessionId: 'wrong_session',
        taskId: 't1',
        eventType: 'task_attempt',
      );

      expect(
            () => tracker.recordInteraction(interaction),
        throwsA(isA<FormatException>()),
      );
    });

    test('recordInteractions appends multiple interactions', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'session_1',
          taskId: 't1',
          eventType: 'task_attempt',
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 'session_1',
          taskId: 't2',
          eventType: 'task_attempt',
        ),
      ];

      tracker.recordInteractions(interactions);

      expect(tracker.interactionCount, 2);
      expect(tracker.latestInteraction!.interactionId, 'i2');
    });

    test('updateCurrentState sets current state', () {
      final tracker = SessionTracker(sessionId: 'session_1');
      final stateSnapshot = buildStateSnapshot(sessionId: 'session_1');

      tracker.updateCurrentState(stateSnapshot);

      expect(tracker.currentState, stateSnapshot);
      expect(tracker.hasCurrentState, isTrue);
    });

    test('updateCurrentState allows null snapshot sessionId', () {
      final tracker = SessionTracker(sessionId: 'session_1');
      final stateSnapshot = buildStateSnapshot(sessionId: null);

      tracker.updateCurrentState(stateSnapshot);

      expect(tracker.currentState, stateSnapshot);
    });

    test('updateCurrentState throws when snapshot sessionId mismatches', () {
      final tracker = SessionTracker(sessionId: 'session_1');
      final stateSnapshot = buildStateSnapshot(sessionId: 'wrong_session');

      expect(
            () => tracker.updateCurrentState(stateSnapshot),
        throwsA(isA<FormatException>()),
      );
    });

    test('updateRecommendation sets latest recommendation', () {
      final tracker = SessionTracker(sessionId: 'session_1');
      final recommendation = buildRecommendation();

      tracker.updateRecommendation(recommendation);

      expect(tracker.latestRecommendation, recommendation);
      expect(tracker.hasLatestRecommendation, isTrue);
    });

    test('updateNote stores note', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      tracker.updateNote('updated note');

      final snapshot = tracker.buildSnapshot();
      expect(snapshot.note, 'updated note');
    });

    test('clearInteractions removes all interactions', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      tracker.recordInteraction(
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'session_1',
          taskId: 't1',
          eventType: 'task_attempt',
        ),
      );

      tracker.clearInteractions();

      expect(tracker.interactions, isEmpty);
      expect(tracker.interactionCount, 0);
      expect(tracker.hasInteractions, isFalse);
      expect(tracker.latestInteraction, isNull);
      expect(tracker.latestOutcome, isNull);
    });

    test('buildStatistics aggregates current interaction history', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      tracker.recordInteractions(<InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'session_1',
          taskId: 't1',
          eventType: 'task_attempt',
          difficultyRank: 1,
          responseTime: 10.0,
          streak: 1.0,
          outcome: buildOutcome(
            taskId: 't1',
            wasSuccessful: true,
            score: 0.8,
            retryCount: 1,
          ),
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 'session_1',
          taskId: 't2',
          eventType: 'task_attempt',
          difficultyRank: 3,
          responseTime: 30.0,
          streak: 3.0,
          outcome: buildOutcome(
            taskId: 't2',
            wasSuccessful: false,
            score: 0.4,
            retryCount: 2,
          ),
        ),
      ]);

      final stats = tracker.buildStatistics();

      expect(stats.interactionCount, 2);
      expect(stats.successfulCount, 1);
      expect(stats.unsuccessfulCount, 1);
      expect(stats.averageScore, closeTo(0.6, 1e-9));
      expect(stats.averageResponseTime, closeTo(20.0, 1e-9));
      expect(stats.averageStreak, closeTo(2.0, 1e-9));
      expect(stats.minDifficultyRank, 1);
      expect(stats.maxDifficultyRank, 3);
      expect(stats.totalRetryCount, 3);
    });

    test('buildSnapshot returns session snapshot with current state and recommendation',
            () {
          final tracker = SessionTracker(sessionId: 'session_1');

          final t1 = DateTime.parse('2026-01-01T10:00:00Z');
          final t2 = DateTime.parse('2026-01-01T11:00:00Z');

          final stateSnapshot = buildStateSnapshot(
            sessionId: 'session_1',
            timestamp: t1,
          );
          final recommendation = buildRecommendation();

          tracker.updateCurrentState(stateSnapshot);
          tracker.updateRecommendation(recommendation);
          tracker.updateNote('tracker note');

          tracker.recordInteractions(<InteractionEvent>[
            buildInteraction(
              interactionId: 'i1',
              sessionId: 'session_1',
              taskId: 't1',
              eventType: 'task_attempt',
              timestamp: t1,
              outcome: buildOutcome(
                taskId: 't1',
                wasSuccessful: true,
              ),
            ),
            buildInteraction(
              interactionId: 'i2',
              sessionId: 'session_1',
              taskId: 't2',
              eventType: 'task_attempt',
              timestamp: t2,
              outcome: buildOutcome(
                taskId: 't2',
                wasSuccessful: false,
              ),
            ),
          ]);

          final snapshot = tracker.buildSnapshot();

          expect(snapshot.sessionId, 'session_1');
          expect(snapshot.currentState, stateSnapshot);
          expect(snapshot.latestRecommendation, recommendation);
          expect(snapshot.latestInteraction, isNotNull);
          expect(snapshot.latestInteraction!.interactionId, 'i2');
          expect(snapshot.latestOutcome, isNotNull);
          expect(snapshot.latestOutcome!.taskId, 't2');
          expect(snapshot.statistics, isNotNull);
          expect(snapshot.statistics!.interactionCount, 2);
          expect(snapshot.interactionCount, 2);
          expect(snapshot.startedAt, t1);
          expect(snapshot.updatedAt, t2);
          expect(snapshot.note, 'tracker note');
        });

    test('buildSnapshot returns null statistics when no interactions exist', () {
      final tracker = SessionTracker(sessionId: 'session_1');
      final snapshot = tracker.buildSnapshot();

      expect(snapshot.sessionId, 'session_1');
      expect(snapshot.statistics, isNull);
      expect(snapshot.latestInteraction, isNull);
      expect(snapshot.latestOutcome, isNull);
      expect(snapshot.interactionCount, 0);
      expect(snapshot.startedAt, isNull);
      expect(snapshot.updatedAt, isNull);
    });

    test('toString contains important fields', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      final text = tracker.toString();

      expect(text, contains('SessionTracker'));
      expect(text, contains('sessionId: session_1'));
      expect(text, contains('interactionCount: 0'));
    });

    test('equality works for identical trackers', () {
      final interaction = buildInteraction(
        interactionId: 'i1',
        sessionId: 'session_1',
        taskId: 't1',
        eventType: 'task_attempt',
      );

      final recommendation = buildRecommendation();
      final stateSnapshot = buildStateSnapshot(sessionId: 'session_1');

      final a = SessionTracker(
        sessionId: 'session_1',
        initialInteractions: <InteractionEvent>[interaction],
        initialState: stateSnapshot,
        initialRecommendation: recommendation,
        note: 'same note',
      );

      final b = SessionTracker(
        sessionId: 'session_1',
        initialInteractions: <InteractionEvent>[interaction],
        initialState: stateSnapshot,
        initialRecommendation: recommendation,
        note: 'same note',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality differs when tracker contents differ', () {
      final a = SessionTracker(sessionId: 'session_1');
      final b = SessionTracker(sessionId: 'session_2');

      expect(a, isNot(equals(b)));
    });
  });
}