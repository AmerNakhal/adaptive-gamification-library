import 'package:flutter/material.dart';

import 'core/example_routes.dart';
import 'core/example_theme.dart';
import 'home/example_home_page.dart';
import 'playground/playground_page.dart';
import 'quiz_demo/quiz_demo_page.dart';
import 'task_progression_demo/task_progression_demo_page.dart';

class AdaptiveGamificationExampleApp extends StatelessWidget {
  const AdaptiveGamificationExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Gamification Library Example',
      debugShowCheckedModeBanner: false,
      theme: ExampleTheme.light(),
      initialRoute: ExampleRoutes.home,
      routes: <String, WidgetBuilder>{
        ExampleRoutes.home: (_) => const ExampleHomePage(),
        ExampleRoutes.quizDemo: (_) => const QuizDemoPage(),
        ExampleRoutes.taskProgressionDemo: (_) =>
        const TaskProgressionDemoPage(),
        ExampleRoutes.playground: (_) => const PlaygroundPage(),
      },
    );
  }
}