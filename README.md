# adaptive_gamification

A Flutter library for integrating exported adaptive policies into Flutter-based applications through deterministic decision execution, state adaptation, recommendations, traces, and session-aware analytics.

The library is intended as the application-side software artifact of a broader adaptive pipeline:

- policy learning and evaluation happen offline, typically in Python
- trained policies are exported as structured JSON artifacts
- Flutter loads those exported artifacts and applies adaptive behavior through a reusable library API

This makes `adaptive_gamification` suitable as a reusable Flutter library for adaptive application scenarios.

---

## Overview

`adaptive_gamification` is a reusable Flutter library that provides:

- exported policy loading and validation
- deterministic adaptive decision execution
- pluggable state adaptation from application telemetry
- high-level recommendation generation
- decision tracing and execution tracing
- session tracking and lightweight analytics snapshots
- reusable integration patterns demonstrated through a runnable example app

The library does **not** perform reinforcement learning training inside Flutter. Instead, it provides the application-side library layer for consuming exported adaptive policies in Flutter applications.

---

## What this library is

This library is:

- a reusable Flutter library
- an adaptive decision layer for Flutter applications
- a deterministic policy integration engine
- a bridge between exported adaptive policy artifacts and host-application logic
- a developer-facing toolkit for recommendations, traces, and session-aware analytics
- a reusable software artifact for multi-scenario integration

---

## What this library is not

This library is not:

- an RL training implementation
- an on-device retraining framework
- a mandatory backend service
- a replacement for the external training or research pipeline
- a claim of online policy optimization inside Flutter

Policy learning remains external. The library focuses on structured integration, deterministic execution, inspection, and reuse inside Flutter applications.

---

## Core Design Philosophy

The library follows a strict separation between:

- **offline policy learning and export**
- **application-side adaptive integration and execution**

This separation keeps the Flutter side:

- lightweight
- deterministic
- reproducible
- easier to inspect and debug
- suitable for offline application execution when policy assets are bundled locally

Rather than embedding PPO or other training logic inside the host application, the learned policy is exported into a structured artifact and consumed through a stable Flutter library interface.

---

## Main Features

- deterministic execution of exported adaptive policies
- structured policy loading, parsing, and validation
- support for normalized entries format and Python-style policy map format
- state adaptation through pluggable state adapters
- recommendation generation on top of raw runtime decisions
- explainable decision traces and formatted execution traces
- session tracking, summaries, and analytics snapshots
- compatibility with externally trained adaptive policies exported from Python pipelines
- a runnable example application demonstrating quiz, task progression, and manual playground scenarios

---

## Public API

The main public entry point is:

- `AdaptiveGamificationLibrary`

Key configuration types include:

- `LibraryConfig`
- `RuntimeConfig`
- `DiagnosticsConfig`
- `FallbackStrategy`

Core domain types include:

- `AdaptiveState`
- `AdaptiveDecision`
- `AdaptiveRecommendation`
- `DecisionTrace`
- `ExecutionTrace`
- `AnalyticsSnapshot`
- `InteractionEvent`
- `SessionSnapshot`
- `AdaptiveSessionSummary`
- `DifficultyTransition`

Included adapters include:

- `DefaultStateAdapter`
- `QuizStateAdapter`
- `TaskProgressionStateAdapter`

Runtime-facing utility types include:

- `LoadedPolicy`
- `PolicyLoader`
- `PolicyValidator`
- `SessionTracker`

Common facade methods include:

- `initializeFromMap(...)`
- `initializeFromJsonString(...)`
- `execute(...)`
- `getDecision(...)`
- `getRecommendation(...)`
- `getDecisionTrace(...)`
- `getExecutionTrace(...)`
- `formatExecutionTrace(...)`
- `getAnalyticsSnapshot(...)`
- `getSessionSummary(...)`

---

## Quick Start

```dart
import 'package:adaptive_gamification/adaptive_gamification.dart';

final library = AdaptiveGamificationLibrary();

void main() {
  library.initializeFromMap(
    {
      'metadata': {
        'format_version': '2.1',
        'policy_type': 'deterministic_lookup_table',
      },
      'policy': {
        'eng=0.50|mot=0.50|flow=0.50|perf=0.50': {
          'state_key': 'eng=0.50|mot=0.50|flow=0.50|perf=0.50',
          'state': {
            'eng': 0.5,
            'mot': 0.5,
            'flow': 0.5,
            'perf': 0.5,
          },
          'action': 2,
          'action_label': 'Medium task',
          'decision': {
            'source_action_id': 2,
            'source_action_name': 'medium_task',
            'action_group': 'challenge_adjustment',
            'decision_type': 'difficulty_adjustment',
            'difficulty_change': 'maintain',
            'difficulty_rank_before': 2,
            'difficulty_rank_after': 2,
            'difficulty_delta': 0,
            'current_difficulty': 'medium',
            'next_difficulty': 'medium',
            'support_strategy': 'maintain_challenge',
            'reason': 'Balanced state supports maintaining challenge.',
            'pedagogical_effect': 'Maintain stable challenge and progression.',
          },
          'probs': [0.05, 0.10, 0.65, 0.10, 0.05, 0.05],
          'value': 0.42,
        },
      },
    },
  );

  const state = AdaptiveState(
    engagement: 0.5,
    motivation: 0.5,
    flow: 0.5,
    performance: 0.5,
  );

  final decision = library.getDecision(state: state);
  final recommendation = library.getRecommendation(
    state: state,
    currentDifficultyRank: 2,
  );

  print('Next difficulty: ${decision.nextDifficulty}');
  print('Reason: ${decision.reason}');
  print('Recommendation type: ${recommendation.type}');
}
```

### Loading from an asset

```dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:adaptive_gamification/adaptive_gamification.dart';

final library = AdaptiveGamificationLibrary();

Future<void> setupLibrary() async {
  final jsonString = await rootBundle.loadString(
    'assets/policies/quiz_policy.json',
  );
  library.initializeFromJsonString(jsonString);
}
```

---

## Execution Flow

A typical execution flow is:

1. Load an exported policy artifact.
2. Initialize the library runtime engine.
3. Build or adapt application telemetry into `AdaptiveState`.
4. Execute deterministic lookup for the normalized state.
5. Retrieve the resulting `AdaptiveDecision`.
6. Optionally derive an `AdaptiveRecommendation`.
7. Optionally generate decision traces, execution traces, and analytics outputs.
8. Optionally track interactions and generate session-level summaries.

---

## Exported Policy Format

The library supports structured exported policy artifacts generated by an external pipeline.

### Supported top-level formats

#### 1. Normalized entries format

```json
{
  "metadata": {
    "format_version": "2.1",
    "policy_type": "deterministic_lookup_table"
  },
  "entries": []
}
```

#### 2. Python-style policy map format

```json
{
  "metadata": {
    "format_version": "2.1",
    "policy_type": "deterministic_lookup_table",
    "export_mode": "deterministic_policy_lookup_export",
    "state_order": ["eng", "mot", "flow", "perf"],
    "state_key_format": "eng=<v>|mot=<v>|flow=<v>|perf=<v>",
    "state_decimals": 2,
    "export_resolution": 0.25,
    "state_dim": 4,
    "num_exported_states": 625,
    "num_actions": 6,
    "action_selection": "deterministic_argmax"
  },
  "policy": {
    "eng=0.25|mot=0.50|flow=0.75|perf=1.00": {
      "state_key": "eng=0.25|mot=0.50|flow=0.75|perf=1.00",
      "state": {
        "eng": 0.25,
        "mot": 0.50,
        "flow": 0.75,
        "perf": 1.00
      },
      "action": 3,
      "action_label": "Hard task",
      "decision": {
        "source_action_id": 3,
        "source_action_name": "hard_task",
        "action_group": "challenge_adjustment",
        "decision_type": "difficulty_adjustment",
        "difficulty_change": "increase",
        "difficulty_rank_before": 3,
        "difficulty_rank_after": 4,
        "difficulty_delta": 1,
        "current_difficulty": "hard",
        "next_difficulty": "veryHard",
        "support_strategy": "increase_challenge",
        "reason": "High performance and flow support progression.",
        "pedagogical_effect": "Increase challenge while preserving productive engagement."
      },
      "probs": [0.01, 0.03, 0.10, 0.78, 0.04, 0.04],
      "value": 0.82
    }
  }
}
```

### Policy key format

For Python-style exports, the runtime key is expected to follow the exported policy format, for example:

- `eng=0.25|mot=0.50|flow=0.75|perf=1.00`

---

## State Representation

The deployment-facing runtime state is represented by:

- `engagement`
- `motivation`
- `flow`
- `performance`

These values are normalized to the range:

- `0.0` to `1.0`

The Flutter side does not reproduce the full hidden training environment used offline. Instead, it consumes a compact deployment-facing state representation aligned with the exported policy.

---

## State Adapters

The library supports converting application-specific telemetry into deployment-facing state through adapters.

### Included adapters

#### `DefaultStateAdapter`
General-purpose adapter for simple normalized runtime inputs.

#### `QuizStateAdapter`
Designed for quiz-like scenarios using signals such as correctness, streak, completion, and response time.

#### `TaskProgressionStateAdapter`
Designed for task progression scenarios using signals such as completion, success rate, pace, retry count, and fatigue.

These adapters allow host applications to keep their own telemetry model while still executing a common exported adaptive policy.

---

## Recommendations and Traces

Beyond raw runtime decisions, the library provides higher-level outputs for application integration and inspection.

### Recommendations

`AdaptiveRecommendation` adds an application-facing layer on top of a raw decision, including fields such as:

- recommendation type
- priority
- support strategy
- pedagogical effect
- transition information
- tags and contextual metadata

### Decision traces

`DecisionTrace` captures structured execution context, such as:

- decision source
- generated state key
- fallback behavior
- transition resolution
- warnings or notes

### Execution traces

`ExecutionTrace` combines diagnostics, policy metadata, and decision-trace output into a richer developer-facing execution artifact.

---

## Session Tracking and Analytics

The library also supports lightweight session-aware runtime tracking.

### Included session features

- `SessionTracker`
- interaction recording through `InteractionEvent`
- `SessionSnapshot`
- `AdaptiveSessionSummary`
- `AnalyticsSnapshot`

This allows host applications to keep per-session adaptive context without introducing a heavy analytics backend as a hard requirement.

---

## Installation

### Local path dependency

```yaml
dependencies:
  adaptive_gamification:
    path: ../adaptive_gamification
```

### Git dependency

```yaml
dependencies:
  adaptive_gamification:
    git:
      url: https://github.com/AmerNakhal/adaptive-gamification-library.git
      path: adaptive_gamification
```

---

## Supplying Policy Assets

The library does **not** bundle a policy by default.

Policies are generated by the external training and export pipeline and then supplied by the host application.

Example asset declaration:

```yaml
flutter:
  assets:
    - assets/policies/quiz_policy.json
    - assets/policies/task_progression_policy.json
```

---

## Example App

A runnable example application is included under `example/`.

The example demonstrates three integration scenarios:

- **Quiz Demo**
- **Task Progression Demo**
- **Playground** for manual state experimentation

Run the example app with:

```bash
cd example
flutter pub get
flutter run
```

---

## Testing

Run package tests with:

```bash
flutter test
```

Run static analysis with:

```bash
flutter analyze
```

---

## Library Structure

```text
adaptive_gamification/
├── lib/
│   ├── adaptive_gamification.dart
│   └── src/
│       ├── adapters/
│       ├── analytics/
│       ├── config/
│       ├── domain/
│       ├── exceptions/
│       ├── facade/
│       ├── gamification/
│       ├── mappers/
│       ├── runtime/
│       ├── sessions/
│       └── utils/
├── example/
├── test/
├── README.md
└── pubspec.yaml
```

---

## Integration with the External Training Pipeline

This library is designed to work with an external adaptive learning pipeline that:

- trains a policy offline
- evaluates the policy externally
- exports a deterministic policy artifact
- deploys that artifact into Flutter for runtime execution

In the full system:

- Python or another external environment is the **training and export side**
- Flutter is the **deployment and execution side**

The primary integration artifact is the exported policy JSON.

---

## Current Scope

The library currently supports:

- deterministic execution of exported adaptive policies
- initialization from raw maps and JSON-based policy artifacts
- deployment-facing state adaptation
- adaptive decision retrieval
- high-level recommendation generation
- decision and execution tracing
- lightweight session tracking and analytics snapshots

The library should be understood as a reusable **adaptive Flutter library** centered on policy integration and application-side adaptive behavior, not as a claim of online RL training or real-time policy optimization inside Flutter.

---

## Research Context

This library is part of a broader adaptive system that investigates how exported adaptive policies can support:

- sequential adaptive intervention selection
- learner-state-aware runtime decision making
- deployment-friendly adaptive execution
- reusable Flutter-based adaptive applications

Its contribution lies in making externally trained adaptive policies usable through a structured Flutter library layer.

---

## License

See `LICENSE`.