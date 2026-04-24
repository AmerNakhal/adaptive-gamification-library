import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/sessions/session_summary_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionSummaryBuilder', () {
    const builder = SessionSummaryBuilder();

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
      int? retryCount,
    }) {
      return TaskOutcome(
        taskId: taskId,
        wasSuccessful: wasSuccessful,
        score: score,
        retryCount: retryCount,
      );
    }

    List<InteractionEvent> buildInteractions() {
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

    test('build creates summary with derived statistics', () {
      final interactions = buildInteractions();

      const overallTransition = DifficultyTransition(
        beforeRank: 1,
        afterRank: 2,
        beforeLevel: 'easy',
        afterLevel: 'medium',
        changeType: 'increase',
        delta: 1,
      );

      final finalRecommendation = buildRecommendation();

      final summary = builder.build(
        interactions: interactions,
        overallTransition: overallTransition,
        finalRecommendation: finalRecommendation,
        status: 'completed',
        note: 'summary note',
        tags: const <String>['session', 'completed'],
      );

      expect(summary.sessionId, 'session_1');
      expect(summary.statistics, isNotNull);
      expect(summary.statistics!.interactionCount, 2);
      expect(summary.statistics!.successfulCount, 1);
      expect(summary.statistics!.unsuccessfulCount, 1);
      expect(summary.statistics!.averageScore, closeTo(0.6, 1e-9));
      expect(summary.overallTransition, overallTransition);
      expect(summary.finalRecommendation, finalRecommendation);
      expect(summary.startedAt, DateTime.parse('2026-01-01T10:00:00Z'));
      expect(summary.endedAt, DateTime.parse('2026-01-01T11:00:00Z'));
      expect(summary.status, 'completed');
      expect(summary.note, 'summary note');
      expect(summary.tags, <String>['session', 'completed']);
    });

    test('build uses provided statistics instead of deriving them', () {
      final interactions = buildInteractions();

      const providedStatistics = SessionStatistics(
        interactionCount: 99,
        successfulCount: 70,
        unsuccessfulCount: 29,
        averageScore: 0.75,
        averageResponseTime: 15.0,
        averageStreak: 2.5,
        averageDifficultyRank: 3.0,
        minDifficultyRank: 1,
        maxDifficultyRank: 4,
        totalRetryCount: 7,
      );

      final summary = builder.build(
        interactions: interactions,
        statistics: providedStatistics,
      );

      expect(summary.statistics, providedStatistics);
      expect(summary.statistics!.interactionCount, 99);
      expect(summary.statistics!.averageScore, 0.75);
    });

    test('build preserves null optional fields when not provided', () {
      final interactions = buildInteractions();

      final summary = builder.build(
        interactions: interactions,
      );

      expect(summary.sessionId, 'session_1');
      expect(summary.statistics, isNotNull);
      expect(summary.overallTransition, isNull);
      expect(summary.finalRecommendation, isNull);
      expect(summary.status, isNull);
      expect(summary.note, isNull);
      expect(summary.tags, isEmpty);
      expect(summary.hasStatistics, isTrue);
      expect(summary.hasOverallTransition, isFalse);
      expect(summary.hasFinalRecommendation, isFalse);
      expect(summary.hasTags, isFalse);
      expect(summary.hasTimeRange, isTrue);
    });

    test('build throws for empty interactions', () {
      expect(
            () => builder.build(
          interactions: const <InteractionEvent>[],
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('build uses first interaction sessionId', () {
      final interactions = buildInteractions();

      final summary = builder.build(
        interactions: interactions,
      );

      expect(summary.sessionId, interactions.first.sessionId);
    });

    test('toString contains important fields', () {
      final text = builder.toString();

      expect(text, contains('SessionSummaryBuilder'));
      expect(text, contains('accumulator:'));
    });

    test('equality works for identical builders', () {
      const a = SessionSummaryBuilder();
      const b = SessionSummaryBuilder();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}