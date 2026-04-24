import 'task_progression_demo_models.dart';

abstract class TaskProgressionSeedData {
  static const List<TaskProgressionItem> items = <TaskProgressionItem>[
    TaskProgressionItem(
      id: 'task_1',
      title: 'Warm-up onboarding task',
      description:
      'A lightweight introductory task intended to establish rhythm and confirm baseline responsiveness.',
      baseDifficultyRank: 1,
      baseDifficultyLabel: 'easy',
      targetCompletion: 0.60,
      expectedPace: 0.55,
    ),
    TaskProgressionItem(
      id: 'task_2',
      title: 'Core progression checkpoint',
      description:
      'A medium-complexity task used to observe sustained completion behavior and pacing quality.',
      baseDifficultyRank: 2,
      baseDifficultyLabel: 'medium',
      targetCompletion: 0.75,
      expectedPace: 0.65,
    ),
    TaskProgressionItem(
      id: 'task_3',
      title: 'Focused challenge task',
      description:
      'A higher-challenge task intended to test whether performance and pace remain stable under increased demand.',
      baseDifficultyRank: 3,
      baseDifficultyLabel: 'hard',
      targetCompletion: 0.80,
      expectedPace: 0.70,
    ),
    TaskProgressionItem(
      id: 'task_4',
      title: 'Recovery-aware task',
      description:
      'A controlled progression step used when retry pressure or fatigue begins to accumulate.',
      baseDifficultyRank: 2,
      baseDifficultyLabel: 'medium',
      targetCompletion: 0.70,
      expectedPace: 0.60,
    ),
    TaskProgressionItem(
      id: 'task_5',
      title: 'Stretch objective',
      description:
      'A more ambitious progression target used to inspect adaptive escalation behavior in later stages.',
      baseDifficultyRank: 4,
      baseDifficultyLabel: 'veryHard',
      targetCompletion: 0.85,
      expectedPace: 0.75,
    ),
  ];

  static TaskProgressionItem itemByIndex(int index) {
    return items[index % items.length];
  }
}