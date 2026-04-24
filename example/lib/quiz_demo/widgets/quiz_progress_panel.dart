import 'package:flutter/material.dart';

import '../../shared/widgets/metric_chip.dart';
import '../../shared/widgets/section_card.dart';
import '../quiz_demo_state.dart';

class QuizProgressPanel extends StatelessWidget {
  final QuizDemoState state;

  const QuizProgressPanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressValue = state.totalQuestionCount == 0
        ? 0.0
        : state.answeredCount / state.totalQuestionCount;

    return SectionCard(
      title: 'Quiz Progress',
      subtitle:
      'Live session progress, correctness trend, streak behavior, and current difficulty context.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.currentQuestion.prompt,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressValue.clamp(0.0, 1.0),
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          Text(
            'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestionCount}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MetricChip(
                label: 'Answered',
                value: state.answeredCount.toString(),
                icon: Icons.checklist_outlined,
              ),
              MetricChip(
                label: 'Correct',
                value: state.correctCount.toString(),
                icon: Icons.verified_outlined,
              ),
              MetricChip(
                label: 'Incorrect',
                value: state.incorrectCount.toString(),
                icon: Icons.close_outlined,
              ),
              MetricChip(
                label: 'Streak',
                value: state.streakCount.toString(),
                icon: Icons.local_fire_department_outlined,
              ),
              MetricChip(
                label: 'Correctness',
                value: '${(state.correctnessRate * 100).toStringAsFixed(1)}%',
                icon: Icons.percent_outlined,
              ),
              MetricChip(
                label: 'Completion',
                value: '${(state.completionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.timelapse_outlined,
              ),
              MetricChip(
                label: 'Difficulty Rank',
                value: state.currentDifficultyRank.toString(),
                icon: Icons.stacked_line_chart_outlined,
              ),
              MetricChip(
                label: 'Difficulty Label',
                value: state.currentDifficultyLabel,
                icon: Icons.label_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}