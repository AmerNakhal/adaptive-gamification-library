import 'package:flutter/material.dart';

import '../../shared/widgets/recommendation_panel.dart';
import '../task_progression_demo_state.dart';

class TaskRecommendationPanel extends StatelessWidget {
  final TaskProgressionDemoState state;

  const TaskRecommendationPanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return RecommendationPanel(
      recommendation: state.viewData?.recommendation,
      emptyMessage: 'No task progression recommendation available yet.',
    );
  }
}