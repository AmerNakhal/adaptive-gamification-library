import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/sessions/session_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionEvaluator', () {
    const evaluator = SessionEvaluator();

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

    List<InteractionEvent> buildValidInteractions() {
      final t1 = DateTime.parse('2026-01-01T10:00:00Z');
      final t2 = DateTime.parse('2026-01-01T11:00:00Z');

      return <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'session_1',
          taskId: 't1',
          eventType: 'task_attempt',
          difficultyRank: 1,
          responseTime: 10.0,
          streak: 1.0,
          timestamp: t1,
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
          difficultyRank: 2,
          responseTime: 20.0,
          streak: 2.0,
          timestamp: t2,
          outcome: buildOutcome(
            taskId: 't2',
            wasSuccessful: false,
            score: 0.4,
            retryCount: 2,
          ),
        ),
      ];
    }

    test('canEvaluate returns false for empty interactions', () {
      expect(
        evaluator.canEvaluate(const <InteractionEvent>[]),
        isFalse,
      );
    });

    test('canEvaluate returns true for non-empty consistent interactions', () {
      final interactions = buildValidInteractions();

      expect(
        evaluator.canEvaluate(interactions),
        isTrue,
      );
    });

    test('canEvaluate returns false for inconsistent session IDs', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'session_1',
          taskId: 't1',
          eventType: 'task_attempt',
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 'session_2',
          taskId: 't2',
          eventType: 'task_attempt',
        ),
      ];

      expect(
        evaluator.canEvaluate(interactions),
        isFalse,
      );
    });

    test('validateInteractions throws for empty interactions', () {
      expect(
            () => evaluator.validateInteractions(const <InteractionEvent>[]),
        throwsA(isA<SessionEvaluationException>()),
      );
    });

    test('validateInteractions throws for inconsistent session IDs', () {
      final interactions = <InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'session_1',
          taskId: 't1',
          eventType: 'task_attempt',
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 'session_2',
          taskId: 't2',
          eventType: 'task_attempt',
        ),
      ];

      expect(
            () => evaluator.validateInteractions(interactions),
        throwsA(isA<SessionEvaluationException>()),
      );
    });

    test('validateInteractions does not throw for valid interactions', () {
      final interactions = buildValidInteractions();

      expect(
            () => evaluator.validateInteractions(interactions),
        returnsNormally,
      );
    });

    test('evaluateStatistics builds statistics from valid interactions', () {
      final interactions = buildValidInteractions();

      final stats = evaluator.evaluateStatistics(interactions);

      expect(stats.interactionCount, 2);
      expect(stats.successfulCount, 1);
      expect(stats.unsuccessfulCount, 1);
      expect(stats.averageScore, closeTo(0.6, 1e-9));
      expect(stats.averageResponseTime, closeTo(15.0, 1e-9));
      expect(stats.averageStreak, closeTo(1.5, 1e-9));
      expect(stats.averageDifficultyRank, closeTo(1.5, 1e-9));
      expect(stats.minDifficultyRank, 1);
      expect(stats.maxDifficultyRank, 2);
      expect(stats.totalRetryCount, 3);
    });

    test('evaluateStatistics throws for invalid interactions', () {
      expect(
            () => evaluator.evaluateStatistics(const <InteractionEvent>[]),
        throwsA(isA<SessionEvaluationException>()),
      );
    });

    test('evaluateSummary builds summary from valid interactions', () {
      final interactions = buildValidInteractions();

      const overallTransition = DifficultyTransition(
        beforeRank: 1,
        afterRank: 2,
        beforeLevel: 'easy',
        afterLevel: 'medium',
        changeType: 'increase',
        delta: 1,
      );

      final recommendation = buildRecommendation();

      final summary = evaluator.evaluateSummary(
        interactions: interactions,
        overallTransition: overallTransition,
        finalRecommendation: recommendation,
        status: 'completed',
        note: 'summary note',
        tags: const <String>['session', 'completed'],
      );

      expect(summary.sessionId, 'session_1');
      expect(summary.statistics, isNotNull);
      expect(summary.statistics!.interactionCount, 2);
      expect(summary.overallTransition, overallTransition);
      expect(summary.finalRecommendation, recommendation);
      expect(summary.status, 'completed');
      expect(summary.note, 'summary note');
      expect(summary.tags, <String>['session', 'completed']);
      expect(summary.startedAt, DateTime.parse('2026-01-01T10:00:00Z'));
      expect(summary.endedAt, DateTime.parse('2026-01-01T11:00:00Z'));
      expect(summary.hasStatistics, isTrue);
      expect(summary.hasOverallTransition, isTrue);
      expect(summary.hasFinalRecommendation, isTrue);
      expect(summary.hasTimeRange, isTrue);
      expect(summary.hasTags, isTrue);
      expect(summary.duration, const Duration(hours: 1));
    });

    test('evaluateSummary throws for invalid interactions', () {
      expect(
            () => evaluator.evaluateSummary(
          interactions: const <InteractionEvent>[],
        ),
        throwsA(isA<SessionEvaluationException>()),
      );
    });

    test('evaluateTracker returns current snapshot from tracker', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      final t1 = DateTime.parse('2026-01-01T10:00:00Z');

      tracker.recordInteraction(
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'session_1',
          taskId: 't1',
          eventType: 'task_attempt',
          timestamp: t1,
          outcome: buildOutcome(
            taskId: 't1',
            wasSuccessful: true,
            score: 1.0,
          ),
        ),
      );

      final snapshot = evaluator.evaluateTracker(tracker);

      expect(snapshot.sessionId, 'session_1');
      expect(snapshot.latestInteraction, isNotNull);
      expect(snapshot.latestInteraction!.interactionId, 'i1');
      expect(snapshot.latestOutcome, isNotNull);
      expect(snapshot.latestOutcome!.taskId, 't1');
      expect(snapshot.statistics, isNotNull);
      expect(snapshot.statistics!.interactionCount, 1);
    });

    test('evaluateTrackerSummary builds summary from tracker', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      final t1 = DateTime.parse('2026-01-01T10:00:00Z');
      final t2 = DateTime.parse('2026-01-01T11:00:00Z');

      tracker.recordInteractions(<InteractionEvent>[
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'session_1',
          taskId: 't1',
          eventType: 'task_attempt',
          timestamp: t1,
          difficultyRank: 1,
          outcome: buildOutcome(
            taskId: 't1',
            wasSuccessful: true,
            score: 0.9,
          ),
        ),
        buildInteraction(
          interactionId: 'i2',
          sessionId: 'session_1',
          taskId: 't2',
          eventType: 'task_attempt',
          timestamp: t2,
          difficultyRank: 2,
          outcome: buildOutcome(
            taskId: 't2',
            wasSuccessful: false,
            score: 0.3,
          ),
        ),
      ]);

      tracker.updateRecommendation(buildRecommendation());

      const overallTransition = DifficultyTransition(
        beforeRank: 1,
        afterRank: 2,
        beforeLevel: 'easy',
        afterLevel: 'medium',
        changeType: 'increase',
        delta: 1,
      );

      final summary = evaluator.evaluateTrackerSummary(
        tracker: tracker,
        overallTransition: overallTransition,
        status: 'in_progress',
        tags: const <String>['tracked'],
      );

      expect(summary.sessionId, 'session_1');
      expect(summary.statistics, isNotNull);
      expect(summary.statistics!.interactionCount, 2);
      expect(summary.overallTransition, overallTransition);
      expect(summary.finalRecommendation, isNotNull);
      expect(summary.finalRecommendation!.id, 'rec_1');
      expect(summary.status, 'in_progress');
      expect(summary.tags, <String>['tracked']);
    });

    test('evaluateTrackerSummary throws when tracker has no interactions', () {
      final tracker = SessionTracker(sessionId: 'session_1');

      expect(
            () => evaluator.evaluateTrackerSummary(tracker: tracker),
        throwsA(isA<SessionEvaluationException>()),
      );
    });

    test('toString contains important fields', () {
      final text = evaluator.toString();

      expect(text, contains('SessionEvaluator'));
      expect(text, contains('accumulator:'));
      expect(text, contains('summaryBuilder:'));
    });

    test('equality works for identical evaluators', () {
      const a = SessionEvaluator();
      const b = SessionEvaluator();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}