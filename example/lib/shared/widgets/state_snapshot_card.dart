import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/material.dart';

import '../utils/example_formatters.dart';
import 'metric_chip.dart';
import 'section_card.dart';

class StateSnapshotCard extends StatelessWidget {
  final StateSnapshot? stateSnapshot;
  final String emptyMessage;

  const StateSnapshotCard({
    super.key,
    required this.stateSnapshot,
    this.emptyMessage = 'No state snapshot available yet.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: 'State Snapshot',
      subtitle:
      'Current adaptive-state view used to represent engagement, motivation, flow, and performance.',
      child: stateSnapshot == null
          ? Text(
        emptyMessage,
        style: theme.textTheme.bodyMedium,
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ExampleFormatters.formatAdaptiveState(stateSnapshot!.state),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MetricChip(
                label: 'Session',
                value: stateSnapshot!.sessionId ?? '—',
                icon: Icons.badge_outlined,
              ),
              MetricChip(
                label: 'Timestamp',
                value: ExampleFormatters.formatDateTime(
                  stateSnapshot!.timestamp,
                ),
                icon: Icons.schedule_outlined,
              ),
              MetricChip(
                label: 'Engagement',
                value: ExampleFormatters.formatDouble(
                  stateSnapshot!.state.engagement,
                ),
                icon: Icons.favorite_border,
              ),
              MetricChip(
                label: 'Motivation',
                value: ExampleFormatters.formatDouble(
                  stateSnapshot!.state.motivation,
                ),
                icon: Icons.bolt_outlined,
              ),
              MetricChip(
                label: 'Flow',
                value: ExampleFormatters.formatDouble(
                  stateSnapshot!.state.flow,
                ),
                icon: Icons.water_drop_outlined,
              ),
              MetricChip(
                label: 'Performance',
                value: ExampleFormatters.formatDouble(
                  stateSnapshot!.state.performance,
                ),
                icon: Icons.insights_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}