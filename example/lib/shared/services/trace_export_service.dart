import 'dart:convert';

import 'package:adaptive_gamification/adaptive_gamification.dart';

class TraceExportService {
  const TraceExportService();

  String decisionTraceToPrettyJson(DecisionTrace trace) {
    return const JsonEncoder.withIndent('  ').convert(trace.toMap());
  }

  String executionTraceToPrettyJson(ExecutionTrace trace) {
    return const JsonEncoder.withIndent('  ').convert(trace.toMap());
  }

  String analyticsSnapshotToPrettyJson(AnalyticsSnapshot snapshot) {
    return const JsonEncoder.withIndent('  ').convert(snapshot.toMap());
  }

  String sessionSnapshotToPrettyJson(SessionSnapshot snapshot) {
    return const JsonEncoder.withIndent('  ').convert(snapshot.toMap());
  }

  String sessionSummaryToPrettyJson(AdaptiveSessionSummary summary) {
    return const JsonEncoder.withIndent('  ').convert(summary.toMap());
  }
}