import 'package:flutter/material.dart';

import '../../shared/widgets/analytics_snapshot_card.dart';
import '../../shared/widgets/state_snapshot_card.dart';
import '../task_progression_demo_state.dart';

class TaskAnalyticsPanel extends StatelessWidget {
  final TaskProgressionDemoState state;

  const TaskAnalyticsPanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StateSnapshotCard(
          stateSnapshot: state.viewData?.sessionSnapshot?.currentState,
          emptyMessage: 'No task progression state snapshot available yet.',
        ),
        const SizedBox(height: 16),
        AnalyticsSnapshotCard(
          snapshot: state.viewData?.analyticsSnapshot,
          emptyMessage: 'No task progression analytics snapshot available yet.',
        ),
      ],
    );
  }
}