import 'package:flutter/material.dart';

import 'section_card.dart';

class ExecutionTraceView extends StatelessWidget {
  final String? traceText;
  final String emptyMessage;
  final String title;
  final String? subtitle;

  const ExecutionTraceView({
    super.key,
    required this.traceText,
    this.emptyMessage = 'No execution trace available yet.',
    this.title = 'Execution Trace',
    this.subtitle =
    'Formatted developer-facing trace output for quick inspection and debugging.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: title,
      subtitle: subtitle,
      child: traceText == null || traceText!.trim().isEmpty
          ? Text(
        emptyMessage,
        style: theme.textTheme.bodyMedium,
      )
          : Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: SelectableText(
          traceText!,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            height: 1.45,
          ),
        ),
      ),
    );
  }
}