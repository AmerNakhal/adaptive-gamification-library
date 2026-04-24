abstract class ExampleConstants {
  static const String appTitle = 'Adaptive Gamification Library Example';
  static const String appSubtitle =
      'A multi-scenario demonstration of policy-driven adaptive gamification in Flutter applications.';

  static const String quizPolicyAsset = 'assets/policies/quiz_policy.json';
  static const String taskProgressionPolicyAsset =
      'assets/policies/task_progression_policy.json';

  static const String quizSessionsAsset = 'assets/sample_data/quiz_sessions.json';
  static const String taskProgressionSessionsAsset =
      'assets/sample_data/task_progression_sessions.json';

  static const String quizDemoTitle = 'Quiz Demo';
  static const String quizDemoDescription =
      'Demonstrates adaptive decision execution, recommendation generation, trace inspection, and session analytics in a quiz-oriented flow.';

  static const String taskProgressionDemoTitle = 'Task Progression Demo';
  static const String taskProgressionDemoDescription =
      'Demonstrates adaptive difficulty and support behavior in a task progression scenario with runtime traces and session summaries.';

  static const String playgroundTitle = 'Playground';
  static const String playgroundDescription =
      'Allows manual state input to inspect runtime decisions, recommendations, diagnostics, and traces directly.';

  static const String quizDemoSessionPrefix = 'quiz_session';
  static const String taskDemoSessionPrefix = 'task_session';
  static const String playgroundSessionPrefix = 'playground_session';

  static const String defaultRuntimePhase = 'runtime_execution';
}