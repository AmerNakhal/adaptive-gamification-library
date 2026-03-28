# adaptive_gamification — Example App

This directory contains a small Flutter app that demonstrates how to integrate the **adaptive_gamification** package in a real project.

The app:
- loads an RL policy JSON from the app’s assets,
- initializes `AdaptiveEngine`,
- builds a `UserState` from simple user interactions,
- calls `engine.decide(...)` to obtain an `AdaptiveDecision`,
- displays the **next difficulty** and the **reason** returned by the policy.

> The policy file belongs to the **application** (this example), not the library. The library simply consumes any compatible policy JSON you provide.

---

## What this example demonstrates

- Adding **adaptive_gamification** as a dependency (path dependency for local development).
- Declaring a policy JSON file as a Flutter **asset**.
- Initializing the engine using `initFromAsset()`.
- Calling `decide()` and reading:
  - `nextDifficulty`
  - `reason`

---

## Directory structure

- `lib/main.dart` — Example UI + integration code
- `assets/data/adaptive_policy.json` — Sample policy (exported by the Python RL training pipeline)
- `pubspec.yaml` — Declares assets + dependencies

---

## Prerequisites

- Flutter SDK installed (includes Dart)

---

## Run the example

From the **example/** directory:

1) Install dependencies

```bash
flutter pub get
```

2) Run the app

```bash
flutter run
```

---

## Configure / replace the policy file

This example expects a policy JSON file at:

- `example/assets/data/adaptive_policy_seed_42.json`

Make sure it is declared in `example/pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/data/adaptive_policy_seed_42.json
```

The engine is initialized (see `lib/main.dart`) like this:

```dart
final engine = AdaptiveEngine();
await engine.initFromAsset(
  policyAssetPath: 'assets/data/adaptive_policy_seed_42.json',
);
```

### Policy format expectation

The policy JSON must be a **List** of entries where each entry contains:

- `state`: `{ eng, mot, flow, perf }` (0.0–1.0, discretized on the same grid used during training)
- `decision`: `{ next_difficulty, reason, ... }`

If you export the policy from the provided Python training pipeline, it will already match this format.

---

## Troubleshooting

### “No file or variants found for asset: …adaptive_policy.json”

- Confirm the file exists at the exact path declared in `example/pubspec.yaml`.
- Run:

```bash
flutter clean
flutter pub get
```

### “AdaptiveEngine not initialized”

- Ensure `initFromAsset()` (or `initFromString()`) is called **before** `decide()`.

---

## License

This example app is distributed under the same license as the main package.
