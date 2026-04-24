import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/analytics_snapshot_card.dart';
import '../../shared/widgets/decision_trace_card.dart';
import '../../shared/widgets/execution_trace_view.dart';
import '../../shared/widgets/state_snapshot_card.dart';

class ManualTracePanel extends StatelessWidget {
  final DecisionTrace? decisionTrace;
  final String? formattedExecutionTrace;
  final StateSnapshot? stateSnapshot;
  final AnalyticsSnapshot? analyticsSnapshot;

  const ManualTracePanel({
    super.key,
    required this.decisionTrace,
    required this.formattedExecutionTrace,
    required this.stateSnapshot,
    required this.analyticsSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecisionTraceCard(
          trace: decisionTrace,
          emptyMessage: 'No manual decision trace available yet.',
        ),
        const SizedBox(height: 16),
        ExecutionTraceView(
          traceText: formattedExecutionTrace,
          emptyMessage: 'No formatted manual execution trace available yet.',
          title: 'Formatted Execution Trace',
          subtitle:
          'Formatted runtime trace output for developer-facing manual inspection.',
        ),
        const SizedBox(height: 16),
        StateSnapshotCard(
          stateSnapshot: stateSnapshot,
          emptyMessage: 'No manual state snapshot available yet.',
        ),
        const SizedBox(height: 16),
        AnalyticsSnapshotCard(
          snapshot: analyticsSnapshot,
          emptyMessage: 'No manual analytics snapshot available yet.',
        ),
      ],
    );
  }
}