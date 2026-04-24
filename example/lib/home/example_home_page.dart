import 'package:flutter/material.dart';

import '../core/example_constants.dart';
import '../core/example_routes.dart';

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ExampleConstants.appTitle),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroSection(
                        title: ExampleConstants.appTitle,
                        subtitle: ExampleConstants.appSubtitle,
                      ),
                      const SizedBox(height: 24),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Expanded(
                              child: _ExampleRouteCard(
                                title: ExampleConstants.quizDemoTitle,
                                description:
                                ExampleConstants.quizDemoDescription,
                                routeName: ExampleRoutes.quizDemo,
                                icon: Icons.quiz_outlined,
                                accentIcon: Icons.auto_awesome,
                                bulletPoints: <String>[
                                  'Policy loading from assets',
                                  'Runtime decision execution',
                                  'Recommendation and trace visualization',
                                  'Session analytics snapshot',
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: _ExampleRouteCard(
                                title:
                                ExampleConstants.taskProgressionDemoTitle,
                                description: ExampleConstants
                                    .taskProgressionDemoDescription,
                                routeName: ExampleRoutes.taskProgressionDemo,
                                icon: Icons.timeline_outlined,
                                accentIcon: Icons.insights_outlined,
                                bulletPoints: <String>[
                                  'Task progression state adaptation',
                                  'Adaptive recommendation rendering',
                                  'Execution trace inspection',
                                  'Session summary generation',
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: _ExampleRouteCard(
                                title: ExampleConstants.playgroundTitle,
                                description:
                                ExampleConstants.playgroundDescription,
                                routeName: ExampleRoutes.playground,
                                icon: Icons.tune_outlined,
                                accentIcon: Icons.science_outlined,
                                bulletPoints: <String>[
                                  'Manual adaptive-state input',
                                  'Immediate decision preview',
                                  'Diagnostics and trace inspection',
                                  'Developer-facing exploration',
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        const Column(
                          children: [
                            _ExampleRouteCard(
                              title: ExampleConstants.quizDemoTitle,
                              description:
                              ExampleConstants.quizDemoDescription,
                              routeName: ExampleRoutes.quizDemo,
                              icon: Icons.quiz_outlined,
                              accentIcon: Icons.auto_awesome,
                              bulletPoints: <String>[
                                'Policy loading from assets',
                                'Runtime decision execution',
                                'Recommendation and trace visualization',
                                'Session analytics snapshot',
                              ],
                            ),
                            SizedBox(height: 16),
                            _ExampleRouteCard(
                              title: ExampleConstants.taskProgressionDemoTitle,
                              description: ExampleConstants
                                  .taskProgressionDemoDescription,
                              routeName: ExampleRoutes.taskProgressionDemo,
                              icon: Icons.timeline_outlined,
                              accentIcon: Icons.insights_outlined,
                              bulletPoints: <String>[
                                'Task progression state adaptation',
                                'Adaptive recommendation rendering',
                                'Execution trace inspection',
                                'Session summary generation',
                              ],
                            ),
                            SizedBox(height: 16),
                            _ExampleRouteCard(
                              title: ExampleConstants.playgroundTitle,
                              description:
                              ExampleConstants.playgroundDescription,
                              routeName: ExampleRoutes.playground,
                              icon: Icons.tune_outlined,
                              accentIcon: Icons.science_outlined,
                              bulletPoints: <String>[
                                'Manual adaptive-state input',
                                'Immediate decision preview',
                                'Diagnostics and trace inspection',
                                'Developer-facing exploration',
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What this example application demonstrates',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'This example app is designed to show the adaptive_gamification package as a reusable Flutter library rather than a single hard-coded demo. Each route highlights a different integration style while sharing the same runtime concepts: policy loading, adaptive-state execution, recommendation generation, trace formatting, and session-aware analytics.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeroSection({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.10),
                colorScheme.secondary.withValues(alpha: 0.08),
                colorScheme.tertiary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.extension_outlined,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.45,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExampleRouteCard extends StatelessWidget {
  final String title;
  final String description;
  final String routeName;
  final IconData icon;
  final IconData accentIcon;
  final List<String> bulletPoints;

  const _ExampleRouteCard({
    required this.title,
    required this.description,
    required this.routeName,
    required this.icon,
    required this.accentIcon,
    required this.bulletPoints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  accentIcon,
                  color: colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ...bulletPoints.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(routeName);
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Open example'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}