import 'quiz_demo_models.dart';

abstract class QuizDemoSeedData {
  static const List<QuizQuestion> questions = <QuizQuestion>[
    QuizQuestion(
      id: 'q1',
      prompt: 'What does JSON primarily represent in software systems?',
      options: <String>[
        'A compiled binary format',
        'A structured data interchange format',
        'A machine learning algorithm',
        'A UI rendering engine',
      ],
      correctIndex: 1,
      baseDifficultyRank: 1,
      baseDifficultyLabel: 'easy',
      explanation:
      'JSON is a lightweight structured data interchange format commonly used for serialization and configuration.',
    ),
    QuizQuestion(
      id: 'q2',
      prompt: 'Why is deterministic runtime policy execution useful in deployment?',
      options: <String>[
        'It removes the need for any evaluation',
        'It ensures predictable and reproducible runtime decisions',
        'It guarantees optimal policy learning',
        'It replaces all session analytics',
      ],
      correctIndex: 1,
      baseDifficultyRank: 2,
      baseDifficultyLabel: 'medium',
      explanation:
      'Deterministic execution helps ensure that the same normalized state produces the same runtime decision, which supports reproducibility and debugging.',
    ),
    QuizQuestion(
      id: 'q3',
      prompt:
      'Which adaptive-state dimension is most directly associated with task success quality?',
      options: <String>[
        'Performance',
        'Flow',
        'Engagement',
        'Motivation',
      ],
      correctIndex: 0,
      baseDifficultyRank: 2,
      baseDifficultyLabel: 'medium',
      explanation:
      'Performance most directly reflects success quality or achievement outcomes within the compact adaptive-state representation.',
    ),
    QuizQuestion(
      id: 'q4',
      prompt:
      'What is the main role of a recommendation layer above raw runtime decisions?',
      options: <String>[
        'To retrain PPO during app execution',
        'To convert low-level decisions into developer-facing adaptive outputs',
        'To remove policy metadata from the system',
        'To replace state normalization entirely',
      ],
      correctIndex: 1,
      baseDifficultyRank: 3,
      baseDifficultyLabel: 'hard',
      explanation:
      'The recommendation layer translates low-level runtime decisions into more interpretable and application-facing outputs such as support strategies and pedagogical effects.',
    ),
    QuizQuestion(
      id: 'q5',
      prompt:
      'Why do session snapshots and analytics snapshots matter in an adaptive library?',
      options: <String>[
        'They provide observability and session-aware runtime summaries',
        'They eliminate the need for policy validation',
        'They convert Flutter apps into Python apps',
        'They make every decision a fallback decision',
      ],
      correctIndex: 0,
      baseDifficultyRank: 3,
      baseDifficultyLabel: 'hard',
      explanation:
      'They provide structured observability, session progression insight, and analytics-friendly outputs for downstream application logic.',
    ),
  ];

  static QuizQuestion questionByIndex(int index) {
    return questions[index % questions.length];
  }
}