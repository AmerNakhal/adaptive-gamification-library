import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveGamificationLibrary', () {
    String buildNormalizedPolicyJson() {
      return '''
      {
        "metadata": {
          "formatVersion": "1.0",
          "policyType": "deterministic_lookup_table",
          "stateOrder": ["engagement", "motivation", "flow", "performance"],
          "stateDecimals": 2,
          "exportedStateCount": 2,
          "actionCount": 6
        },
        "entries": [
          {
            "stateKey": "0.10|0.20|0.30|0.40",
            "decision": {
              "nextDifficulty": 1,
              "source": "exact_match",
              "reason": "stable",
              "actionLabel": "easy_task"
            }
          },
          {
            "stateKey": "0.40|0.50|0.60|0.70",
            "decision": {
              "nextDifficulty": 3,
              "source": "exact_match",
              "reason": "increase challenge",
              "actionLabel": "hard_task"
            }
          }
        ]
      }
      ''';
    }

    Map<String, dynamic> buildNormalizedPolicyMap() {
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

    test('isInitialized is false before loading a policy', () {
      final library = AdaptiveGamificationLibrary();

      expect(library.isInitialized, isFalse);
      expect(library.loadedPolicy, isNull);
      expect(library.runtimeEngine, isNull);
      expect(library.trackedSessionCount, 0);
    });

    test('initializeFromJsonString loads policy and initializes runtime', () {
      final library = AdaptiveGamificationLibrary();

      library.initializeFromJsonString(buildNormalizedPolicyJson());

      expect(library.isInitialized, isTrue);
      expect(library.loadedPolicy, isNotNull);
      expect(library.runtimeEngine, isNotNull);
      expect(library.loadedPolicy!.policySize, 2);
      expect(library.runtimeEngine!.policySize, 2);
    });

    test('initializeFromMap loads policy and initializes runtime', () {
      final library = AdaptiveGamificationLibrary();

      library.initializeFromMap(buildNormalizedPolicyMap());

      expect(library.isInitialized, isTrue);
      expect(library.loadedPolicy, isNotNull);
      expect(library.runtimeEngine, isNotNull);
      expect(library.loadedPolicy!.metadata.formatVersion, '1.0');
    });

    test('execute returns exact-match result after initialization', () {
      final library = AdaptiveGamificationLibrary();
      library.initializeFromMap(buildNormalizedPolicyMap());

      const state = AdaptiveState(
        engagement: 0.1,
        motivation: 0.2,
        flow: 0.3,
        performance: 0.4,
      );

      final result = library.execute(
        state: state,
        sessionId: 'session_1',
        interactionId: 'interaction_1',
      );

      expect(result.decision.nextDifficulty, 1);
      expect(result.decision.source, DecisionSource.exactMatch);
      expect(result.decision.actionLabel, 'easy_task');
      expect(result.context.generatedStateKey, '0.10|0.20|0.30|0.40');
      expect(result.context.sessionId, 'session_1');
      expect(result.context.interactionId, 'interaction_1');
    });

    test('execute throws before initialization', () {
      final library = AdaptiveGamificationLibrary();

      expect(
            () => library.execute(
          state: const AdaptiveState(
            engagement: 0.1,
            motivation: 0.2,
            flow: 0.3,
            performance: 0.4,
          ),
        ),
        throwsA(isA<RuntimeExecutionException>()),
      );
    });

    test('getDecision returns adaptive decision only', () {
      final library = AdaptiveGamificationLibrary();
      library.initializeFromMap(buildNormalizedPolicyMap());

      final decision = library.getDecision(
        state: const AdaptiveState(
          engagement: 0.4,
          motivation: 0.5,
          flow: 0.6,
          performance: 0.7,
        ),
      );

      expect(decision.nextDifficulty, 3);
      expect(decision.source, DecisionSource.exactMatch);
      expect(decision.actionLabel, 'hard_task');
    });

    test('getRecommendation returns high-level recommendation', () {
      final library = AdaptiveGamificationLibrary();
      library.initializeFromMap(buildNormalizedPolicyMap());

      final recommendation = library.getRecommendation(
        state: const AdaptiveState(
          engagement: 0.4,
          motivation: 0.5,
          flow: 0.6,
          performance: 0.7,
        ),
        currentDifficultyRank: 2,
      );

      expect(recommendation.decision.nextDifficulty, 3);
      expect(
        recommendation.type,
        RecommendationType.difficultyAdjustment,
      );
      expect(recommendation.transition, isNotNull);
      expect(recommendation.transition!.beforeRank, 2);
      expect(recommendation.transition!.afterRank, 3);
    });

    test('getDecisionTrace returns rich decision trace', () {
      final library = AdaptiveGamificationLibrary();
      library.initializeFromMap(buildNormalizedPolicyMap());

      final trace = library.getDecisionTrace(
        state: const AdaptiveState(
          engagement: 0.4,
          motivation: 0.5,
          flow: 0.6,
          performance: 0.7,
        ),
        currentDifficultyRank: 2,
        note: 'trace note',
      );

      expect(trace.decision.nextDifficulty, 3);
      expect(trace.context.generatedStateKey, '0.40|0.50|0.60|0.70');
      expect(trace.transition, isNotNull);
      expect(trace.recommendation, isNotNull);
      expect(trace.note, 'trace note');
    });

    test('getRuntimeDiagnostics returns diagnostics when enabled by config', () {
      final library = AdaptiveGamificationLibrary(
        config: const LibraryConfig(
          diagnostics: DiagnosticsConfig(
            enableRuntimeDiagnostics: true,
          ),
        ),
      );

      library.initializeFromMap(buildNormalizedPolicyMap());

      final diagnostics = library.getRuntimeDiagnostics(
        state: const AdaptiveState(
          engagement: 0.1,
          motivation: 0.2,
          flow: 0.3,
          performance: 0.4,
        ),
      );

      expect(diagnostics, isNotNull);
      expect(diagnostics!.generatedStateKey, '0.10|0.20|0.30|0.40');
      expect(diagnostics.usedExactMatch, isTrue);
      expect(diagnostics.usedFallback, isFalse);
    });

    test('getRuntimeDiagnostics returns null when diagnostics are disabled', () {
      final library = AdaptiveGamificationLibrary(
        config: const LibraryConfig(
          diagnostics: DiagnosticsConfig(
            enableRuntimeDiagnostics: false,
          ),
        ),
      );

      library.initializeFromMap(buildNormalizedPolicyMap());

      final diagnostics = library.getRuntimeDiagnostics(
        state: const AdaptiveState(
          engagement: 0.1,
          motivation: 0.2,
          flow: 0.3,
          performance: 0.4,
        ),
      );

      expect(diagnostics, isNull);
    });

    test('getExecutionTrace returns execution trace', () {
      final library = AdaptiveGamificationLibrary(
        config: const LibraryConfig(
          diagnostics: DiagnosticsConfig(
            enableRuntimeDiagnostics: true,
          ),
        ),
      );

      library.initializeFromMap(buildNormalizedPolicyMap());

      final trace = library.getExecutionTrace(
        state: const AdaptiveState(
          engagement: 0.1,
          motivation: 0.2,
          flow: 0.3,
          performance: 0.4,
        ),
        currentDifficultyRank: 1,
        phase: 'runtime_execution',
        note: 'exec note',
      );

      expect(trace.phase, 'runtime_execution');
      expect(trace.diagnostics, isNotNull);
      expect(trace.decisionTrace, isNotNull);
      expect(trace.policyMetadata, isNotNull);
      expect(trace.indexedPolicySize, 2);
      expect(trace.note, 'exec note');
    });

    test('formatExecutionTrace returns formatted text', () {
      final library = AdaptiveGamificationLibrary(
        config: const LibraryConfig(
          diagnostics: DiagnosticsConfig(
            enableRuntimeDiagnostics: true,
          ),
        ),
      );

      library.initializeFromMap(buildNormalizedPolicyMap());

      final text = library.formatExecutionTrace(
        state: const AdaptiveState(
          engagement: 0.1,
          motivation: 0.2,
          flow: 0.3,
          performance: 0.4,
        ),
        currentDifficultyRank: 1,
      );

      expect(text, contains('ExecutionTrace'));
      expect(text, contains('decisionTrace:'));
      expect(text, contains('generatedStateKey: 0.10|0.20|0.30|0.40'));
    });

    test('getOrCreateSessionTracker creates and reuses tracker', () {
      final library = AdaptiveGamificationLibrary();

      final a = library.getOrCreateSessionTracker('session_1');
      final b = library.getOrCreateSessionTracker('session_1');

      expect(a, same(b));
      expect(library.trackedSessionCount, 1);
    });

    test('getSessionTracker returns null when tracker does not exist', () {
      final library = AdaptiveGamificationLibrary();

      expect(
        library.getSessionTracker('missing_session'),
        isNull,
      );
    });

    test('removeSessionTracker removes existing tracker', () {
      final library = AdaptiveGamificationLibrary();

      library.getOrCreateSessionTracker('session_1');
      expect(library.trackedSessionCount, 1);

      library.removeSessionTracker('session_1');

      expect(library.trackedSessionCount, 0);
      expect(library.getSessionTracker('session_1'), isNull);
    });

    test('recordInteraction stores interaction in appropriate tracker', () {
      final library = AdaptiveGamificationLibrary();

      library.recordInteraction(
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
          ),
        ),
      );

      final tracker = library.getSessionTracker('session_1');
      expect(tracker, isNotNull);
      expect(tracker!.interactionCount, 1);
      expect(tracker.latestInteraction!.interactionId, 'i1');
    });

    test('getSessionSnapshot returns null when session is not tracked', () {
      final library = AdaptiveGamificationLibrary();

      expect(
        library.getSessionSnapshot('missing_session'),
        isNull,
      );
    });

    test('getSessionSnapshot returns current session snapshot', () {
      final library = AdaptiveGamificationLibrary();

      library.recordInteraction(
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'session_1',
          taskId: 't1',
          eventType: 'task_attempt',
          difficultyRank: 1,
          responseTime: 10.0,
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

      final snapshot = library.getSessionSnapshot('session_1');

      expect(snapshot, isNotNull);
      expect(snapshot!.sessionId, 'session_1');
      expect(snapshot.latestInteraction, isNotNull);
      expect(snapshot.latestOutcome, isNotNull);
      expect(snapshot.statistics, isNotNull);
      expect(snapshot.statistics!.interactionCount, 1);
    });

    test('getSessionSummary returns null when session is not tracked or empty', () {
      final library = AdaptiveGamificationLibrary();

      expect(
        library.getSessionSummary('missing_session'),
        isNull,
      );

      library.getOrCreateSessionTracker('empty_session');

      expect(
        library.getSessionSummary('empty_session'),
        isNull,
      );
    });

    test('getSessionSummary returns session summary for tracked session', () {
      final library = AdaptiveGamificationLibrary();

      library.recordInteraction(
        buildInteraction(
          interactionId: 'i1',
          sessionId: 'session_1',
          taskId: 't1',
          eventType: 'task_attempt',
          difficultyRank: 1,
          responseTime: 10.0,
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
          difficultyRank: 2,
          responseTime: 20.0,
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

      const transition = DifficultyTransition(
        beforeRank: 1,
        afterRank: 2,
        beforeLevel: 'easy',
        afterLevel: 'medium',
        changeType: 'increase',
        delta: 1,
      );

      final summary = library.getSessionSummary(
        'session_1',
        overallTransition: transition,
        status: 'completed',
        tags: const <String>['tracked'],
      );

      expect(summary, isNotNull);
      expect(summary!.sessionId, 'session_1');
      expect(summary.statistics, isNotNull);
      expect(summary.statistics!.interactionCount, 2);
      expect(summary.overallTransition, transition);
      expect(summary.status, 'completed');
      expect(summary.tags, <String>['tracked']);
    });

    test('getAnalyticsSnapshot returns null when session snapshot is unavailable',
            () {
          final library = AdaptiveGamificationLibrary();

          expect(
            library.getAnalyticsSnapshot('missing_session'),
            isNull,
          );
        });

    test('getAnalyticsSnapshot returns analytics snapshot for tracked session',
            () {
          final library = AdaptiveGamificationLibrary();

          library.recordInteraction(
            buildInteraction(
              interactionId: 'i1',
              sessionId: 'session_1',
              taskId: 't1',
              eventType: 'task_attempt',
              difficultyRank: 1,
              responseTime: 10.0,
              streak: 1.0,
              timestamp: DateTime.parse('2026-01-01T10:00:00Z'),
              outcome: buildOutcome(
                taskId: 't1',
                wasSuccessful: true,
                score: 0.8,
              ),
            ),
          );

          const transition = DifficultyTransition(
            beforeRank: 1,
            afterRank: 2,
            beforeLevel: 'easy',
            afterLevel: 'medium',
            changeType: 'increase',
            delta: 1,
          );

          final snapshot = library.getAnalyticsSnapshot(
            'session_1',
            latestTransition: transition,
            decisionCount: 10,
            fallbackCount: 2,
            scope: 'session_snapshot',
            note: 'analytics note',
            tags: const <String>['analytics'],
          );

          expect(snapshot, isNotNull);
          expect(snapshot!.sessionId, 'session_1');
          expect(snapshot.scope, 'session_snapshot');
          expect(snapshot.latestTransition, transition);
          expect(snapshot.decisionCount, 10);
          expect(snapshot.fallbackCount, 2);
          expect(snapshot.note, 'analytics note');
          expect(snapshot.tags, <String>['analytics']);
          expect(snapshot.fallbackRate, closeTo(0.2, 1e-9));
        });

    test('toString contains important fields', () {
      final library = AdaptiveGamificationLibrary();

      final text = library.toString();

      expect(text, contains('AdaptiveGamificationLibrary'));
      expect(text, contains('isInitialized: false'));
      expect(text, contains('trackedSessionCount: 0'));
      expect(text, contains('config:'));
    });
  });
}