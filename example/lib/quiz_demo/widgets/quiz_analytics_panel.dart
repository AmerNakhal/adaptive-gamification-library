import 'package:flutter/material.dart';

import '../../shared/widgets/analytics_snapshot_card.dart';
import '../../shared/widgets/state_snapshot_card.dart';
import '../quiz_demo_state.dart';

class QuizAnalyticsPanel extends StatelessWidget {
  final QuizDemoState state;

  const QuizAnalyticsPanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StateSnapshotCard(
          stateSnapshot: state.viewData?.sessionSnapshot?.currentState,
          emptyMessage: 'No quiz state snapshot available yet.',
        ),
        const SizedBox(height: 16),
        AnalyticsSnapshotCard(
          snapshot: state.viewData?.analyticsSnapshot,
          emptyMessage: 'No quiz analytics snapshot available yet.',
        ),
      ],
    );
  }
}