import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/material.dart';

import '../utils/example_formatters.dart';
import 'metric_chip.dart';
import 'section_card.dart';

class RecommendationPanel extends StatelessWidget {
  final AdaptiveRecommendation? recommendation;
  final String emptyMessage;

  const RecommendationPanel({
    super.key,
    required this.recommendation,
    this.emptyMessage = 'No recommendation available yet.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Recommendation',
      subtitle:
      'High-level adaptive output derived from the runtime decision and current session context.',
      child: recommendation == null
          ? Text(
        emptyMessage,
        style: theme.textTheme.bodyMedium,
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recommendation!.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recommendation!.message,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MetricChip(
                label: 'Priority',
                value: recommendation!.priority,
                icon: Icons.flag_outlined,
              ),
              MetricChip(
                label: 'Type',
                value: recommendation!.type,
                icon: Icons.category_outlined,
              ),
              MetricChip(
                label: 'Action Group',
                value: recommendation!.actionGroup ?? '—',
                icon: Icons.account_tree_outlined,
              ),
              MetricChip(
                label: 'Support Strategy',
                value: recommendation!.supportStrategy ?? '—',
                icon: Icons.support_agent_outlined,
              ),
              MetricChip(
                label: 'Pedagogical Effect',
                value: recommendation!.pedagogicalEffect ?? '—',
                icon: Icons.school_outlined,
              ),
              MetricChip(
                label: 'Next Difficulty',
                value:
                recommendation!.decision.nextDifficulty.toString(),
                icon: Icons.trending_up_outlined,
              ),
            ],
          ),
          if (recommendation!.transition != null) ...[
            const SizedBox(height: 16),
            Text(
              'Transition',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ExampleFormatters.formatTransitionSummary(
                recommendation!.transition,
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (recommendation!.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tags',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recommendation!.tags
                  .map(
                    (tag) => Chip(
                  label: Text(tag),
                ),
              )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}