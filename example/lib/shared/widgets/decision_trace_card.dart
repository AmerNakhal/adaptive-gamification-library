import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/material.dart';

import '../utils/example_formatters.dart';
import 'metric_chip.dart';
import 'section_card.dart';

class DecisionTraceCard extends StatelessWidget {
  final DecisionTrace? trace;
  final String emptyMessage;

  const DecisionTraceCard({
    super.key,
    required this.trace,
    this.emptyMessage = 'No decision trace available yet.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Decision Trace',
      subtitle:
      'Structured runtime trace showing the decision source, generated state key, transition, and recommendation context.',
      child: trace == null
          ? Text(
        emptyMessage,
        style: theme.textTheme.bodyMedium,
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MetricChip(
                label: 'Trace ID',
                value: trace!.traceId,
                icon: Icons.route_outlined,
              ),
              MetricChip(
                label: 'Source',
                value: trace!.decision.source,
                icon: Icons.hub_outlined,
              ),
              MetricChip(
                label: 'Next Difficulty',
                value: trace!.decision.nextDifficulty.toString(),
                icon: Icons.trending_up_outlined,
              ),
              MetricChip(
                label: 'State Key',
                value: trace!.context.generatedStateKey,
                icon: Icons.vpn_key_outlined,
              ),
              MetricChip(
                label: 'Fallback',
                value: trace!.usedFallback ? 'Yes' : 'No',
                icon: Icons.rule_folder_outlined,
              ),
              MetricChip(
                label: 'Timestamp',
                value: ExampleFormatters.formatDateTime(trace!.timestamp),
                icon: Icons.schedule_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Decision',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ExampleFormatters.formatDecisionSummary(trace!.decision),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          if (trace!.transition != null) ...[
            const SizedBox(height: 16),
            Text(
              'Transition',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ExampleFormatters.formatTransitionSummary(trace!.transition),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (trace!.recommendation != null) ...[
            const SizedBox(height: 16),
            Text(
              'Recommendation',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ExampleFormatters.formatRecommendationSummary(
                trace!.recommendation,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (trace!.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Warnings',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...trace!.warnings.map(
                  (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (trace!.note != null && trace!.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Note',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trace!.note!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
        ],
      ),
    );
  }
}