import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:adaptive_gamification/src/gamification/gamification_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveGamification end-to-end flow', () {
    Map<String, dynamic> buildPolicyMap() {
      return <String, dynamic>{
        'metadata': <String, dynamic>{
          'formatVersion': '1.0',
          'policyType': 'deterministic_lookup_table',
          'stateOrder': <dynamic>[
            'engagement',
            'motivation',
            'flow',
            'performance',
          ],
          'stateDecimals': 2,
          'exportedStateCount': 2,
          'actionCount': 6,
        },
        'entries': <dynamic>[
          <String, dynamic>{
            'stateKey': '0.10|0.20|0.30|0.40',
            'decision': <String, dynamic>{
              'nextDifficulty': 1,
              'source': 'exact_match',
              'reason': 'stable',
              'actionLabel': 'easy_task',
            },
          },
          <String, dynamic>{
            'stateKey': '0.40|0.50|0.60|0.70',
            'decision': <String, dynamic>{
              'nextDifficulty': 3,
              'source': 'exact_match',
              'reason': 'increase challenge',
              'actionLabel': 'hard_task',
            },
          },
        ],
      };
    }

    InteractionEvent buildInteraction({
      required String interactionId,
      required String sessionId,
      required String taskId,
      required String eventType,
      int? difficultyRank,
      double? responseTime,
      double? streak,
      TaskOutcome? outcome,
      DateTime? timestamp,
    }) {
      return InteractionEvent(
        interactionId: interactionId,
        sessionId: sessionId,
        taskId: taskId,
        eventType: eventType,
        difficultyRank: difficultyRank,
        responseTime: responseTime,
        streak: streak,
        outcome: outcome,
        timestamp: timestamp,
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

    test('loads policy, executes runtime, builds recommendation and traces, and evaluates session',
            () {
          final library = AdaptiveGamificationLibrary(
            config: const LibraryConfig(
              diagnostics: DiagnosticsConfig(
                enableRuntimeDiagnostics: true,
              ),
            ),
          );

          library.initializeFromMap(buildPolicyMap());

          expect(library.isInitialized, isTrue);
          expect(library.loadedPolicy, isNotNull);
          expect(library.runtimeEngine, isNotNull);
          expect(library.loadedPolicy!.policySize, 2);

          const state = AdaptiveState(
            engagement: 0.4,
            motivation: 0.5,
            flow: 0.6,
            performance: 0.7,
          );

          final executionResult = library.execute(
            state: state,
            sessionId: 'session_1',
            interactionId: 'interaction_1',
          );

          expect(executionResult.decision.nextDifficulty, 3);
          expect(executionResult.decision.source, DecisionSource.exactMatch);
          expect(executionResult.decision.reason, 'increase challenge');
          expect(executionResult.decision.actionLabel, 'hard_task');
          expect(
            executionResult.context.generatedStateKey,
            '0.40|0.50|0.60|0.70',
          );
          expect(executionResult.context.sessionId, 'session_1');
          expect(executionResult.context.interactionId, 'interaction_1');
          expect(executionResult.context.usedExactMatch, isTrue);
          expect(executionResult.context.usedFallback, isFalse);

          final recommendation = library.getRecommendation(
            state: state,
            sessionId: 'session_1',
            interactionId: 'interaction_1',
            currentDifficultyRank: 2,
          );

          expect(
            recommendation.type,
            RecommendationType.difficultyAdjustment,
          );
          expect(recommendation.transition, isNotNull);
          expect(recommendation.transition!.beforeRank, 2);
          expect(recommendation.transition!.afterRank, 3);
          expect(
            recommendation.supportStrategy,
            GamificationLabels.increaseChallenge,
          );
          expect(
            recommendation.actionGroup,
            GamificationLabels.challengeAdjustmentGroup,
          );
          expect(
            recommendation.pedagogicalEffect,
            GamificationLabels.difficultyIncrease,
          );

          final decisionTrace = library.getDecisionTrace(
            state: state,
            sessionId: 'session_1',
            interactionId: 'interaction_1',
            currentDifficultyRank: 2,
            note: 'integration trace',
          );

          expect(decisionTrace.decision.nextDifficulty, 3);
          expect(decisionTrace.context.generatedStateKey, '0.40|0.50|0.60|0.70');
          expect(decisionTrace.transition, isNotNull);
          expect(decisionTrace.recommendation, isNotNull);
          expect(decisionTrace.note, 'integration trace');

          final executionTrace = library.getExecutionTrace(
            state: state,
            sessionId: 'session_1',
            interactionId: 'interaction_1',
            currentDifficultyRank: 2,
            phase: 'runtime_execution',
            note: 'integration execution',
          );

          expect(executionTrace.phase, 'runtime_execution');
          expect(executionTrace.diagnostics, isNotNull);
          expect(executionTrace.decisionTrace, isNotNull);
          expect(executionTrace.policyMetadata, isNotNull);
          expect(executionTrace.indexedPolicySize, 2);
          expect(executionTrace.note, 'integration execution');

          final formattedTrace = library.formatExecutionTrace(
            state: state,
            sessionId: 'session_1',
            interactionId: 'interaction_1',
            currentDifficultyRank: 2,
          );

          expect(formattedTrace, contains('ExecutionTrace'));
          expect(formattedTrace, contains('DecisionTrace'));
          expect(formattedTrace, contains('0.40|0.50|0.60|0.70'));

          library.recordInteraction(
            buildInteraction(
              interactionId: 'i1',
              sessionId: 'session_1',
              taskId: 't1',
              eventType: 'task_attempt',
              difficultyRank: 2,
              responseTime: 12.0,
              streak: 1.0,
              timestamp: DateTime.parse('2026-01-01T10:00:00Z'),
              outcome: buildOutcome(
                taskId: 't1',
                wasSuccessful: true,
                score: 0.9,
                retryCount: 1,
              ),
            ),
          );

          library.recordInteraction(
            buildInteraction(
              interactionId: 'i2',
              sessionId: 'session_1',
              taskId: 't2',
              eventType: 'task_attempt',
              difficultyRank: 3,
              responseTime: 18.0,
              streak: 2.0,
              timestamp: DateTime.parse('2026-01-01T11:00:00Z'),
              outcome: buildOutcome(
                taskId: 't2',
                wasSuccessful: false,
                score: 0.4,
                retryCount: 2,
              ),
            ),
          );

          final tracker = library.getOrCreateSessionTracker('session_1');
          tracker.updateRecommendation(recommendation);
          tracker.updateCurrentState(
            const StateSnapshot(
              state: state,
              sessionId: 'session_1',
            ),
          );

          final sessionSnapshot = library.getSessionSnapshot('session_1');
          expect(sessionSnapshot, isNotNull);
          expect(sessionSnapshot!.sessionId, 'session_1');
          expect(sessionSnapshot.currentState, isNotNull);
          expect(sessionSnapshot.latestInteraction, isNotNull);
          expect(sessionSnapshot.latestInteraction!.interactionId, 'i2');
          expect(sessionSnapshot.latestOutcome, isNotNull);
          expect(sessionSnapshot.latestOutcome!.taskId, 't2');
          expect(sessionSnapshot.latestRecommendation, isNotNull);
          expect(sessionSnapshot.statistics, isNotNull);
          expect(sessionSnapshot.statistics!.interactionCount, 2);
          expect(sessionSnapshot.statistics!.successfulCount, 1);
          expect(sessionSnapshot.statistics!.unsuccessfulCount, 1);

          final sessionSummary = library.getSessionSummary(
            'session_1',
            overallTransition: recommendation.transition,
            status: 'completed',
            tags: const <String>['integration'],
          );

          expect(sessionSummary, isNotNull);
          expect(sessionSummary!.sessionId, 'session_1');
          expect(sessionSummary.statistics, isNotNull);
          expect(sessionSummary.statistics!.interactionCount, 2);
          expect(sessionSummary.overallTransition, isNotNull);
          expect(sessionSummary.finalRecommendation, isNotNull);
          expect(sessionSummary.status, 'completed');
          expect(sessionSummary.tags, <String>['integration']);

          final analyticsSnapshot = library.getAnalyticsSnapshot(
            'session_1',
            latestTransition: recommendation.transition,
            decisionCount: 2,
            fallbackCount: 0,
            scope: 'session_snapshot',
            note: 'integration analytics',
            tags: const <String>['integration', 'analytics'],
          );

          expect(analyticsSnapshot, isNotNull);
          expect(analyticsSnapshot!.sessionId, 'session_1');
          expect(analyticsSnapshot.scope, 'session_snapshot');
          expect(analyticsSnapshot.stateSnapshot, isNotNull);
          expect(analyticsSnapshot.sessionStatistics, isNotNull);
          expect(analyticsSnapshot.latestTransition, isNotNull);
          expect(analyticsSnapshot.latestRecommendation, isNotNull);
          expect(analyticsSnapshot.decisionCount, 2);
          expect(analyticsSnapshot.fallbackCount, 0);
          expect(analyticsSnapshot.fallbackRate, 0.0);
          expect(analyticsSnapshot.note, 'integration analytics');
          expect(
            analyticsSnapshot.tags,
            <String>['integration', 'analytics'],
          );
        });

    test('fallback path still supports end-to-end flow', () {
      final library = AdaptiveGamificationLibrary(
        config: const LibraryConfig(
          diagnostics: DiagnosticsConfig(
            enableRuntimeDiagnostics: true,
          ),
        ),
      );

      library.initializeFromMap(buildPolicyMap());

      const unseenState = AdaptiveState(
        engagement: 0.9,
        motivation: 0.9,
        flow: 0.9,
        performance: 0.9,
      );

      final result = library.execute(
        state: unseenState,
        sessionId: 'session_fallback',
        interactionId: 'interaction_fallback',
      );

      expect(result.decision.source, DecisionSource.fallback);
      expect(result.context.usedFallback, isTrue);
      expect(result.context.fallbackReason, 'missing_state_key');
      expect(result.diagnostics, isNotNull);
      expect(result.diagnostics!.usedFallback, isTrue);

      final recommendation = library.getRecommendation(
        state: unseenState,
        sessionId: 'session_fallback',
        interactionId: 'interaction_fallback',
        currentDifficultyRank: 2,
      );

      expect(recommendation.priority, RecommendationPriority.high);

      final trace = library.getDecisionTrace(
        state: unseenState,
        sessionId: 'session_fallback',
        interactionId: 'interaction_fallback',
        currentDifficultyRank: 2,
      );

      expect(trace.usedFallback, isTrue);
      expect(trace.recommendation, isNotNull);
    });
  });
}