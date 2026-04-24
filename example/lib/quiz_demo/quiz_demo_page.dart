import 'package:flutter/material.dart';

import '../core/example_constants.dart';
import 'quiz_demo_controller.dart';
import 'quiz_demo_state.dart';
import 'widgets/quiz_analytics_panel.dart';
import 'widgets/quiz_progress_panel.dart';
import 'widgets/quiz_recommendation_panel.dart';
import 'widgets/quiz_runtime_panel.dart';
import 'widgets/quiz_trace_panel.dart';

class QuizDemoPage extends StatefulWidget {
  const QuizDemoPage({super.key});

  @override
  State<QuizDemoPage> createState() => _QuizDemoPageState();
}

class _QuizDemoPageState extends State<QuizDemoPage> {
  late final QuizDemoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuizDemoController()..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAnswer(int selectedIndex) async {
    await _controller.submitAnswer(
      selectedIndex: selectedIndex,
      responseTimeSeconds: 8 + selectedIndex.toDouble() * 2,
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
            title: const Text(ExampleConstants.quizDemoTitle),
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
                : _QuizDemoBody(
              state: state,
              onAnswerSelected: _handleAnswer,
            ),
          ),
        );
      },
    );
  }
}

class _QuizDemoBody extends StatelessWidget {
  final QuizDemoState state;
  final ValueChanged<int> onAnswerSelected;

  const _QuizDemoBody({
    required this.state,
    required this.onAnswerSelected,
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
                              QuizProgressPanel(state: state),
                              const SizedBox(height: 16),
                              _QuestionAnswerCard(
                                state: state,
                                onAnswerSelected: onAnswerSelected,
                              ),
                              const SizedBox(height: 16),
                              QuizRuntimePanel(state: state),
                              const SizedBox(height: 16),
                              QuizRecommendationPanel(state: state),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              QuizTracePanel(state: state),
                              const SizedBox(height: 16),
                              QuizAnalyticsPanel(state: state),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        QuizProgressPanel(state: state),
                        const SizedBox(height: 16),
                        _QuestionAnswerCard(
                          state: state,
                          onAnswerSelected: onAnswerSelected,
                        ),
                        const SizedBox(height: 16),
                        QuizRuntimePanel(state: state),
                        const SizedBox(height: 16),
                        QuizRecommendationPanel(state: state),
                        const SizedBox(height: 16),
                        QuizTracePanel(state: state),
                        const SizedBox(height: 16),
                        QuizAnalyticsPanel(state: state),
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
            const Icon(Icons.quiz_outlined, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ExampleConstants.quizDemoTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ExampleConstants.quizDemoDescription,
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

class _QuestionAnswerCard extends StatelessWidget {
  final QuizDemoState state;
  final ValueChanged<int> onAnswerSelected;

  const _QuestionAnswerCard({
    required this.state,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = state.currentQuestion;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question Interaction',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              question.prompt,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(question.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: state.isLoading ? null : () => onAnswerSelected(index),
                    icon: const Icon(Icons.radio_button_unchecked),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(question.options[index]),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              'Base difficulty: ${question.baseDifficultyLabel} (${question.baseDifficultyRank})',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Explanation: ${question.explanation}',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ],
        ),
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
                  'Quiz demo failed to initialize',
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