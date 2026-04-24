import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/material.dart';

import '../utils/example_formatters.dart';
import 'metric_chip.dart';
import 'section_card.dart';

class AnalyticsSnapshotCard extends StatelessWidget {
  final AnalyticsSnapshot? snapshot;
  final String emptyMessage;

  const AnalyticsSnapshotCard({
    super.key,
    required this.snapshot,
    this.emptyMessage = 'No analytics snapshot available yet.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Analytics Snapshot',
      subtitle:
      'Lightweight session-aware analytics summarizing state, decisions, fallbacks, and recommendation output.',
      child: snapshot == null
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
                label: 'Snapshot ID',
                value: snapshot!.snapshotId,
                icon: Icons.analytics_outlined,
              ),
              MetricChip(
                label: 'Session',
                value: snapshot!.sessionId ?? '—',
                icon: Icons.badge_outlined,
              ),
              MetricChip(
                label: 'Scope',
                value: snapshot!.scope ?? '—',
                icon: Icons.layers_outlined,
              ),
              MetricChip(
                label: 'Decision Count',
                value: ExampleFormatters.formatInt(
                  snapshot!.decisionCount,
                ),
                icon: Icons.calculate_outlined,
              ),
              MetricChip(
                label: 'Fallback Count',
                value: ExampleFormatters.formatInt(
                  snapshot!.fallbackCount,
                ),
                icon: Icons.rule_folder_outlined,
              ),
              MetricChip(
                label: 'Fallback Rate',
                value: ExampleFormatters.formatPercent(
                  snapshot!.fallbackRate,
                ),
                icon: Icons.percent_outlined,
              ),
              MetricChip(
                label: 'Timestamp',
                value: ExampleFormatters.formatDateTime(
                  snapshot!.timestamp,
                ),
                icon: Icons.schedule_outlined,
              ),
            ],
          ),
          if (snapshot!.sessionStatistics != null) ...[
            const SizedBox(height: 16),
            Text(
              'Session Statistics',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ExampleFormatters.formatSessionStatisticsSummary(
                snapshot!.sessionStatistics,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (snapshot!.latestTransition != null) ...[
            const SizedBox(height: 16),
            Text(
              'Latest Transition',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ExampleFormatters.formatTransitionSummary(
                snapshot!.latestTransition,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (snapshot!.latestRecommendation != null) ...[
            const SizedBox(height: 16),
            Text(
              'Latest Recommendation',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ExampleFormatters.formatRecommendationSummary(
                snapshot!.latestRecommendation,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (snapshot!.stateSnapshot != null) ...[
            const SizedBox(height: 16),
            Text(
              'Current State',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ExampleFormatters.formatAdaptiveState(
                snapshot!.stateSnapshot!.state,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (snapshot!.note != null && snapshot!.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Note',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              snapshot!.note!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (snapshot!.tags.isNotEmpty) ...[
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
              children: snapshot!.tags
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