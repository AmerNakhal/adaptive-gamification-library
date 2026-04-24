import 'package:flutter/material.dart';

import '../../shared/widgets/decision_trace_card.dart';
import '../../shared/widgets/execution_trace_view.dart';
import '../quiz_demo_state.dart';

class QuizTracePanel extends StatelessWidget {
  final QuizDemoState state;

  const QuizTracePanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecisionTraceCard(
          trace: state.viewData?.decisionTrace,
          emptyMessage: 'No quiz decision trace available yet.',
        ),
        const SizedBox(height: 16),
        ExecutionTraceView(
          traceText: state.viewData?.formattedExecutionTrace,
          emptyMessage: 'No formatted execution trace available yet.',
          title: 'Formatted Execution Trace',
          subtitle:
          'Formatted runtime trace output for developer-facing inspection in the quiz scenario.',
        ),
      ],
    );
  }
}