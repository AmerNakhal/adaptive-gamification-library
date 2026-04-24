import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/material.dart';

import '../../shared/utils/example_formatters.dart';
import '../../shared/widgets/metric_chip.dart';
import '../../shared/widgets/recommendation_panel.dart';
import '../../shared/widgets/section_card.dart';

class ManualDecisionResultPanel extends StatelessWidget {
  final AdaptiveState? adaptiveState;
  final AdaptiveDecision? decision;
  final AdaptiveRecommendation? recommendation;

  const ManualDecisionResultPanel({
    super.key,
    required this.adaptiveState,
    required this.decision,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (adaptiveState == null && decision == null && recommendation == null) {
      return SectionCard(
        title: 'Runtime Output',
        subtitle:
        'Manual execution results will appear here after running the playground.',
        child: Text(
          'No manual runtime output available yet.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: [
        SectionCard(
          title: 'Runtime Output',
          subtitle:
          'Immediate adaptive-state and deterministic decision output produced from the manual playground input.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (adaptiveState != null) ...[
                Text(
                  'Adaptive State',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ExampleFormatters.formatAdaptiveState(adaptiveState),
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
                        adaptiveState!.engagement,
                      ),
                      icon: Icons.favorite_border,
                    ),
                    MetricChip(
                      label: 'Motivation',
                      value: ExampleFormatters.formatDouble(
                        adaptiveState!.motivation,
                      ),
                      icon: Icons.bolt_outlined,
                    ),
                    MetricChip(
                      label: 'Flow',
                      value: ExampleFormatters.formatDouble(
                        adaptiveState!.flow,
                      ),
                      icon: Icons.water_drop_outlined,
                    ),
                    MetricChip(
                      label: 'Performance',
                      value: ExampleFormatters.formatDouble(
                        adaptiveState!.performance,
                      ),
                      icon: Icons.insights_outlined,
                    ),
                  ],
                ),
              ],
              if (decision != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Decision',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
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
                      value: decision!.source,
                      icon: Icons.hub_outlined,
                    ),
                    MetricChip(
                      label: 'Next Difficulty',
                      value: decision!.nextDifficulty.toString(),
                      icon: Icons.trending_up_outlined,
                    ),
                    MetricChip(
                      label: 'Action Label',
                      value: decision!.actionLabel ?? '—',
                      icon: Icons.smart_toy_outlined,
                    ),
                    MetricChip(
                      label: 'Reason',
                      value: decision!.reason ?? '—',
                      icon: Icons.info_outline,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        RecommendationPanel(
          recommendation: recommendation,
          emptyMessage: 'No manual recommendation available yet.',
        ),
      ],
    );
  }
}