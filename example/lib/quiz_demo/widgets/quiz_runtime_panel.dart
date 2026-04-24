import 'package:flutter/material.dart';

import '../../shared/utils/example_formatters.dart';
import '../../shared/widgets/metric_chip.dart';
import '../../shared/widgets/section_card.dart';
import '../quiz_demo_state.dart';

class QuizRuntimePanel extends StatelessWidget {
  final QuizDemoState state;

  const QuizRuntimePanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewData = state.viewData;
    final decision = viewData?.decision;

    return SectionCard(
      title: 'Runtime Output',
      subtitle:
      'Current adaptive state and latest deterministic runtime decision produced by the library.',
      child: viewData == null
          ? Text(
        'Runtime data is not available yet.',
        style: theme.textTheme.bodyMedium,
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adaptive State',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ExampleFormatters.formatAdaptiveState(viewData.adaptiveState),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MetricChip(
                label: 'Engagement',
                value: ExampleFormatters.formatDouble(
                  viewData.adaptiveState.engagement,
                ),
                icon: Icons.favorite_border,
              ),
              MetricChip(
                label: 'Motivation',
                value: ExampleFormatters.formatDouble(
                  viewData.adaptiveState.motivation,
                ),
                icon: Icons.bolt_outlined,
              ),
              MetricChip(
                label: 'Flow',
                value: ExampleFormatters.formatDouble(
                  viewData.adaptiveState.flow,
                ),
                icon: Icons.water_drop_outlined,
              ),
              MetricChip(
                label: 'Performance',
                value: ExampleFormatters.formatDouble(
                  viewData.adaptiveState.performance,
                ),
                icon: Icons.insights_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Decision',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (decision == null)
            Text(
              'No runtime decision available yet.',
              style: theme.textTheme.bodyMedium,
            )
          else ...[
            Text(
              ExampleFormatters.formatDecisionSummary(decision),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                MetricChip(
                  label: 'Source',
                  value: decision.source,
                  icon: Icons.hub_outlined,
                ),
                MetricChip(
                  label: 'Next Difficulty',
                  value: decision.nextDifficulty.toString(),
                  icon: Icons.trending_up_outlined,
                ),
                MetricChip(
                  label: 'Action Label',
                  value: decision.actionLabel ?? '—',
                  icon: Icons.smart_toy_outlined,
                ),
                MetricChip(
                  label: 'Reason',
                  value: decision.reason ?? '—',
                  icon: Icons.info_outline,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}