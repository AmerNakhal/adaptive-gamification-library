import 'package:flutter/material.dart';

class ManualStateInputForm extends StatelessWidget {
  final TextEditingController engagementController;
  final TextEditingController motivationController;
  final TextEditingController flowController;
  final TextEditingController performanceController;
  final TextEditingController difficultyRankController;
  final Future<void> Function() onRun;
  final bool isLoading;

  const ManualStateInputForm({
    super.key,
    required this.engagementController,
    required this.motivationController,
    required this.flowController,
    required this.performanceController,
    required this.difficultyRankController,
    required this.onRun,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manual State Input',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Provide explicit adaptive-state values to inspect how the library responds at runtime.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: 'Engagement',
                    controller: engagementController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputField(
                    label: 'Motivation',
                    controller: motivationController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: 'Flow',
                    controller: flowController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputField(
                    label: 'Performance',
                    controller: performanceController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InputField(
              label: 'Current Difficulty Rank',
              controller: difficultyRankController,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onRun,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run Playground'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _InputField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }
}