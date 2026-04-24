import 'dart:convert';

import 'package:adaptive_gamification/adaptive_gamification.dart';

abstract class ExampleSerializers {
  static Map<String, dynamic> adaptiveStateToMap(AdaptiveState state) {
    return state.toMap();
  }

  static Map<String, dynamic> decisionToMap(AdaptiveDecision decision) {
    return decision.toMap();
  }

  static Map<String, dynamic> recommendationToMap(
      AdaptiveRecommendation recommendation,
      ) {
    return recommendation.toMap();
  }

  static Map<String, dynamic> decisionTraceToMap(DecisionTrace trace) {
    return trace.toMap();
  }

  static Map<String, dynamic> executionTraceToMap(ExecutionTrace trace) {
    return trace.toMap();
  }

  static Map<String, dynamic> analyticsSnapshotToMap(
      AnalyticsSnapshot snapshot,
      ) {
    return snapshot.toMap();
  }

  static Map<String, dynamic> sessionSnapshotToMap(SessionSnapshot snapshot) {
    return snapshot.toMap();
  }

  static Map<String, dynamic> sessionSummaryToMap(
      AdaptiveSessionSummary summary,
      ) {
    return summary.toMap();
  }

  static String toPrettyJson(Map<String, dynamic> map) {
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static String adaptiveStateToPrettyJson(AdaptiveState state) {
    return toPrettyJson(adaptiveStateToMap(state));
  }

  static String decisionToPrettyJson(AdaptiveDecision decision) {
    return toPrettyJson(decisionToMap(decision));
  }

  static String recommendationToPrettyJson(
      AdaptiveRecommendation recommendation,
      ) {
    return toPrettyJson(recommendationToMap(recommendation));
  }

  static String decisionTraceToPrettyJson(DecisionTrace trace) {
    return toPrettyJson(decisionTraceToMap(trace));
  }

  static String executionTraceToPrettyJson(ExecutionTrace trace) {
    return toPrettyJson(executionTraceToMap(trace));
  }

  static String analyticsSnapshotToPrettyJson(
      AnalyticsSnapshot snapshot,
      ) {
    return toPrettyJson(analyticsSnapshotToMap(snapshot));
  }

  static String sessionSnapshotToPrettyJson(SessionSnapshot snapshot) {
    return toPrettyJson(sessionSnapshotToMap(snapshot));
  }

  static String sessionSummaryToPrettyJson(
      AdaptiveSessionSummary summary,
      ) {
    return toPrettyJson(sessionSummaryToMap(summary));
  }
}