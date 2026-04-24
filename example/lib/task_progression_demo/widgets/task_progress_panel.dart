import 'package:flutter/material.dart';

import '../../shared/widgets/metric_chip.dart';
import '../../shared/widgets/section_card.dart';
import '../task_progression_demo_state.dart';

class TaskProgressPanel extends StatelessWidget {
  final TaskProgressionDemoState state;

  const TaskProgressPanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressValue = state.totalItemCount == 0
        ? 0.0
        : state.completedCount / state.totalItemCount;

    return SectionCard(
      title: 'Task Progress',
      subtitle:
      'Live progression status, success trend, retry accumulation, and current adaptive difficulty context.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.currentItem.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.currentItem.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
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
            'Task ${state.currentItemIndex + 1} of ${state.totalItemCount}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MetricChip(
                label: 'Completed',
                value: state.completedCount.toString(),
                icon: Icons.task_alt_outlined,
              ),
              MetricChip(
                label: 'Successful',
                value: state.successfulCount.toString(),
                icon: Icons.verified_outlined,
              ),
              MetricChip(
                label: 'Unsuccessful',
                value: state.unsuccessfulCount.toString(),
                icon: Icons.close_outlined,
              ),
              MetricChip(
                label: 'Completion Rate',
                value: '${(state.completionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.timelapse_outlined,
              ),
              MetricChip(
                label: 'Success Rate',
                value: '${(state.successRate * 100).toStringAsFixed(1)}%',
                icon: Icons.percent_outlined,
              ),
              MetricChip(
                label: 'Retry Total',
                value: state.cumulativeRetryCount.toString(),
                icon: Icons.refresh_outlined,
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
              MetricChip(
                label: 'Target Completion',
                value:
                '${(state.currentItem.targetCompletion * 100).toStringAsFixed(0)}%',
                icon: Icons.flag_outlined,
              ),
              MetricChip(
                label: 'Expected Pace',
                value:
                '${(state.currentItem.expectedPace * 100).toStringAsFixed(0)}%',
                icon: Icons.speed_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}