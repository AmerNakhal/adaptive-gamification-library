import 'package:flutter/material.dart';

import '../core/example_constants.dart';
import 'task_progression_demo_controller.dart';
import 'task_progression_demo_state.dart';
import 'widgets/task_analytics_panel.dart';
import 'widgets/task_progress_panel.dart';
import 'widgets/task_recommendation_panel.dart';
import 'widgets/task_runtime_panel.dart';
import 'widgets/task_trace_panel.dart';

class TaskProgressionDemoPage extends StatefulWidget {
  const TaskProgressionDemoPage({super.key});

  @override
  State<TaskProgressionDemoPage> createState() =>
      _TaskProgressionDemoPageState();
}

class _TaskProgressionDemoPageState extends State<TaskProgressionDemoPage> {
  late final TaskProgressionDemoController _controller;

  final _completionController = TextEditingController(text: '0.80');
  final _successRateController = TextEditingController(text: '0.70');
  final _paceController = TextEditingController(text: '0.65');
  final _fatigueController = TextEditingController(text: '0.20');
  final _retryCountController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _controller = TaskProgressionDemoController()..initialize();
  }

  @override
  void dispose() {
    _completionController.dispose();
    _successRateController.dispose();
    _paceController.dispose();
    _fatigueController.dispose();
    _retryCountController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitProgress() async {
    final completion = double.tryParse(_completionController.text.trim());
    final successRate = double.tryParse(_successRateController.text.trim());
    final pace = double.tryParse(_paceController.text.trim());
    final fatigue = double.tryParse(_fatigueController.text.trim());
    final retryCount = int.tryParse(_retryCountController.text.trim());

    if (completion == null ||
        successRate == null ||
        pace == null ||
        fatigue == null ||
        retryCount == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numeric values for all fields.'),
        ),
      );
      return;
    }

    await _controller.submitProgress(
      completion: completion,
      successRate: successRate,
      pace: pace,
      fatigue: fatigue,
      retryCount: retryCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;

        return Scaffold(
          appBar: AppBar(
            title: const Text(ExampleConstants.taskProgressionDemoTitle),
            actions: [
              IconButton(
                tooltip: 'Refresh analytics',
                onPressed: state.isLoading ? null : _controller.refreshAnalytics,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Reset demo',
                onPressed: state.isLoading ? null : _controller.resetDemo,
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
          body: SafeArea(
            child: state.hasError
                ? _ErrorView(
              message: state.errorMessage!,
              onRetry: _controller.initialize,
            )
                : _TaskProgressionBody(
              state: state,
              completionController: _completionController,
              successRateController: _successRateController,
              paceController: _paceController,
              fatigueController: _fatigueController,
              retryCountController: _retryCountController,
              onSubmit: _submitProgress,
            ),
          ),
        );
      },
    );
  }
}

class _TaskProgressionBody extends StatelessWidget {
  final TaskProgressionDemoState state;
  final TextEditingController completionController;
  final TextEditingController successRateController;
  final TextEditingController paceController;
  final TextEditingController fatigueController;
  final TextEditingController retryCountController;
  final Future<void> Function() onSubmit;

  const _TaskProgressionBody({
    required this.state,
    required this.completionController,
    required this.successRateController,
    required this.paceController,
    required this.fatigueController,
    required this.retryCountController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1100;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderBanner(
                    isLoading: state.isLoading,
                    isInitialized: state.isInitialized,
                    sessionId: state.sessionId,
                  ),
                  const SizedBox(height: 20),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              TaskProgressPanel(state: state),
                              const SizedBox(height: 16),
                              _TaskInputCard(
                                state: state,
                                completionController: completionController,
                                successRateController: successRateController,
                                paceController: paceController,
                                fatigueController: fatigueController,
                                retryCountController: retryCountController,
                                onSubmit: onSubmit,
                              ),
                              const SizedBox(height: 16),
                              TaskRuntimePanel(state: state),
                              const SizedBox(height: 16),
                              TaskRecommendationPanel(state: state),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              TaskTracePanel(state: state),
                              const SizedBox(height: 16),
                              TaskAnalyticsPanel(state: state),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        TaskProgressPanel(state: state),
                        const SizedBox(height: 16),
                        _TaskInputCard(
                          state: state,
                          completionController: completionController,
                          successRateController: successRateController,
                          paceController: paceController,
                          fatigueController: fatigueController,
                          retryCountController: retryCountController,
                          onSubmit: onSubmit,
                        ),
                        const SizedBox(height: 16),
                        TaskRuntimePanel(state: state),
                        const SizedBox(height: 16),
                        TaskRecommendationPanel(state: state),
                        const SizedBox(height: 16),
                        TaskTracePanel(state: state),
                        const SizedBox(height: 16),
                        TaskAnalyticsPanel(state: state),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  final bool isLoading;
  final bool isInitialized;
  final String sessionId;

  const _HeaderBanner({
    required this.isLoading,
    required this.isInitialized,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.timeline_outlined, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ExampleConstants.taskProgressionDemoTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ExampleConstants.taskProgressionDemoDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Session: $sessionId',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(
                isLoading
                    ? 'Loading'
                    : isInitialized
                    ? 'Ready'
                    : 'Not initialized',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskInputCard extends StatelessWidget {
  final TaskProgressionDemoState state;
  final TextEditingController completionController;
  final TextEditingController successRateController;
  final TextEditingController paceController;
  final TextEditingController fatigueController;
  final TextEditingController retryCountController;
  final Future<void> Function() onSubmit;

  const _TaskInputCard({
    required this.state,
    required this.completionController,
    required this.successRateController,
    required this.paceController,
    required this.fatigueController,
    required this.retryCountController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = state.currentItem;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Progress Input',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: 'Completion',
                    controller: completionController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputField(
                    label: 'Success Rate',
                    controller: successRateController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: 'Pace',
                    controller: paceController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputField(
                    label: 'Fatigue',
                    controller: fatigueController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InputField(
              label: 'Retry Count',
              controller: retryCountController,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Chip(
                  label: Text('Base difficulty: ${item.baseDifficultyLabel}'),
                ),
                Chip(
                  label: Text(
                    'Target completion: ${(item.targetCompletion * 100).toStringAsFixed(0)}%',
                  ),
                ),
                Chip(
                  label: Text(
                    'Expected pace: ${(item.expectedPace * 100).toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.isLoading ? null : onSubmit,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Submit Progress'),
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

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Task progression demo failed to initialize',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}