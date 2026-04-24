import 'package:flutter/material.dart';

import '../../shared/widgets/recommendation_panel.dart';
import '../quiz_demo_state.dart';

class QuizRecommendationPanel extends StatelessWidget {
  final QuizDemoState state;

  const QuizRecommendationPanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return RecommendationPanel(
      recommendation: state.viewData?.recommendation,
      emptyMessage: 'No quiz recommendation available yet.',
    );
  }
}