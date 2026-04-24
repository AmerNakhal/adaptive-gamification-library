import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/sessions/interaction_accumulator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InteractionAccumulator', () {
    const accumulator = InteractionAccumulator();

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

    test('buildStatistics aggregates counts and averages correctly', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
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
          sessionId: 's1',
          taskId: 't2',
          eventType: 'task_attempt',
          difficultyRank: 2,
          responseTime: 20.0,
          streak: 2.0,
          outcome: buildOutcome(
            taskId: 't2',
            wasSuccessful: false,
            score: 0.4,
            retryCount: 2,
          ),
        ),
        buildInteraction(
          interactionId: 'i3',
          sessionId: 's1',
          taskId: 't3',
          eventType: 'task_attempt',
          difficultyRank: 3,
          responseTime: 30.0,
          streak: 3.0,
          outcome: buildOutcome(
            taskId: 't3',
            wasSuccessful: true,
            score: 1.0,
            retryCount: 0,
          ),
        ),
      ];

      final stats = accumulator.buildStatistics(interactions);

      expect(stats.interactionCount, 3);
      expect(stats.successfulCount, 2);
      expect(stats.unsuccessfulCount, 1);
      expect(stats.averageScore, closeTo((0.8 + 0.4 + 1.0) / 3, 1e-9));
      expect(stats.averageResponseTime, closeTo(20.0, 1e-9));
      expect(stats.averageStreak, closeTo(2.0, 1e-9));
      expect(stats.averageDifficultyRank, closeTo(2.0, 1e-9));
      expect(stats.minDifficultyRank, 1);
      expect(stats.maxDifficultyRank, 3);
      expect(stats.totalRetryCount, 3);
      expect(stats.successRate, closeTo(2 / 3, 1e-9));
      expect(stats.failureRate, closeTo(1 / 3, 1e-9));
      expect(stats.hasDifficultyRange, isTrue);
      expect(stats.hasRetryData, isTrue);
    });

    test('buildStatistics handles missing optional values safely', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
          taskId: 't1',
          eventType: 'task_attempt',
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 's1',
          taskId: 't2',
          eventType: 'task_attempt',
          outcome: buildOutcome(
            taskId: 't2',
            wasSuccessful: true,
          ),
        ),
      ];

      final stats = accumulator.buildStatistics(interactions);

      expect(stats.interactionCount, 2);
      expect(stats.successfulCount, 1);
      expect(stats.unsuccessfulCount, 0);
      expect(stats.averageScore, isNull);
      expect(stats.averageResponseTime, isNull);
      expect(stats.averageStreak, isNull);
      expect(stats.averageDifficultyRank, isNull);
      expect(stats.minDifficultyRank, isNull);
      expect(stats.maxDifficultyRank, isNull);
      expect(stats.totalRetryCount, isNull);
      expect(stats.hasDifficultyRange, isFalse);
      expect(stats.hasRetryData, isFalse);
    });

    test('buildStatistics returns zero rates when there are no successful outcomes', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
          taskId: 't1',
          eventType: 'checkpoint',
        ),
      ];

      final stats = accumulator.buildStatistics(interactions);

      expect(stats.interactionCount, 1);
      expect(stats.successfulCount, 0);
      expect(stats.unsuccessfulCount, 0);
      expect(stats.successRate, 0.0);
      expect(stats.failureRate, 0.0);
    });

    test('latestInteraction returns null for empty list', () {
      expect(accumulator.latestInteraction(const <InteractionEvent>[]), isNull);
    });

    test('latestInteraction returns last interaction', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
          taskId: 't1',
          eventType: 'task_attempt',
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 's1',
          taskId: 't2',
          eventType: 'task_attempt',
        ),
      ];

      final latest = accumulator.latestInteraction(interactions);

      expect(latest, isNotNull);
      expect(latest!.interactionId, 'i2');
    });

    test('latestOutcome returns null when no outcomes exist', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
          taskId: 't1',
          eventType: 'checkpoint',
        ),
      ];

      expect(accumulator.latestOutcome(interactions), isNull);
    });

    test('latestOutcome returns most recent available outcome', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
          taskId: 't1',
          eventType: 'task_attempt',
          outcome: buildOutcome(
            taskId: 't1',
            wasSuccessful: false,
          ),
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 's1',
          taskId: 't2',
          eventType: 'checkpoint',
        ),
        buildInteraction(
          interactionId: 'i3',
          sessionId: 's1',
          taskId: 't3',
          eventType: 'task_attempt',
          outcome: buildOutcome(
            taskId: 't3',
            wasSuccessful: true,
            score: 1.0,
          ),
        ),
      ];

      final latestOutcome = accumulator.latestOutcome(interactions);

      expect(latestOutcome, isNotNull);
      expect(latestOutcome!.taskId, 't3');
      expect(latestOutcome.wasSuccessful, isTrue);
      expect(latestOutcome.score, 1.0);
    });

    test('startedAt returns null when no timestamps exist', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
          taskId: 't1',
          eventType: 'checkpoint',
        ),
      ];

      expect(accumulator.startedAt(interactions), isNull);
    });

    test('startedAt returns earliest timestamp', () {
      final t1 = DateTime.parse('2026-01-01T10:00:00Z');
      final t2 = DateTime.parse('2026-01-01T11:00:00Z');
      final t3 = DateTime.parse('2026-01-01T09:00:00Z');

      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
          taskId: 't1',
          eventType: 'task_attempt',
          timestamp: t1,
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 's1',
          taskId: 't2',
          eventType: 'task_attempt',
          timestamp: t2,
        ),
        buildInteraction(
          interactionId: 'i3',
          sessionId: 's1',
          taskId: 't3',
          eventType: 'task_attempt',
          timestamp: t3,
        ),
      ];

      expect(accumulator.startedAt(interactions), t3);
    });

    test('endedAt returns null when no timestamps exist', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
          taskId: 't1',
          eventType: 'checkpoint',
        ),
      ];

      expect(accumulator.endedAt(interactions), isNull);
    });

    test('endedAt returns latest timestamp', () {
      final t1 = DateTime.parse('2026-01-01T10:00:00Z');
      final t2 = DateTime.parse('2026-01-01T11:00:00Z');
      final t3 = DateTime.parse('2026-01-01T09:00:00Z');

      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
          taskId: 't1',
          eventType: 'task_attempt',
          timestamp: t1,
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 's1',
          taskId: 't2',
          eventType: 'task_attempt',
          timestamp: t2,
        ),
        buildInteraction(
          interactionId: 'i3',
          sessionId: 's1',
          taskId: 't3',
          eventType: 'task_attempt',
          timestamp: t3,
        ),
      ];

      expect(accumulator.endedAt(interactions), t2);
    });

    test('hasConsistentSessionId returns true for empty list', () {
      expect(
        accumulator.hasConsistentSessionId(const <InteractionEvent>[]),
        isTrue,
      );
    });

    test('hasConsistentSessionId returns true for same session IDs', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'same_session',
          taskId: 't1',
          eventType: 'task_attempt',
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 'same_session',
          taskId: 't2',
          eventType: 'task_attempt',
        ),
      ];

      expect(accumulator.hasConsistentSessionId(interactions), isTrue);
    });

    test('hasConsistentSessionId returns false for mixed session IDs', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 's1',
          taskId: 't1',
          eventType: 'task_attempt',
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 's2',
          taskId: 't2',
          eventType: 'task_attempt',
        ),
      ];

      expect(accumulator.hasConsistentSessionId(interactions), isFalse);
    });

    test('toString returns readable type name', () {
      expect(
        accumulator.toString(),
        contains('InteractionAccumulator'),
      );
    });

    test('equality works for identical accumulators', () {
      const a = InteractionAccumulator();
      const b = InteractionAccumulator();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}