# Changelog

All notable changes to **adaptive_gamification** will be documented in this file.

The format is based on **Keep a Changelog** (https://keepachangelog.com/en/1.1.0/),
and this project follows **Semantic Versioning** (https://semver.org/).

## [Unreleased]

### Added
- _None._

### Changed
- _None._

### Deprecated
- _None._

### Removed
- _None._

### Fixed
- _None._

### Security
- _None._

## [0.0.2] - 2026-03-29

Major update of the Flutter deployment library to align with the finalized Python reinforcement learning pipeline and structured policy export format.

### Added
- Support for the **structured exported policy format** with:
    - top-level `metadata`
    - top-level `policy`
- Export metadata exposure through `AdaptiveEngine`, including:
    - parsed policy metadata
    - structured-format detection
    - policy size
- Richer `AdaptiveDecision` model with optional runtime metadata:
    - `supportStrategy`
    - `sourceActionName`
    - `lookupKey`
    - `foundExactMatch`
- Improved example application that demonstrates:
    - policy metadata display
    - runtime session state
    - latest adaptive decision details
    - exact-match vs fallback visibility

### Changed
- Updated `PolicyLoader` to support the finalized Python export structure and Python-compatible policy keys.
- Updated `StateMapper` to use the deployment-facing state representation:
    - `engagement`
    - `motivation`
    - `flow`
    - `performance`
- Updated runtime key generation to the finalized format:
    - `eng=0.25|mot=0.50|flow=0.75|perf=1.00`
- Improved `DecisionEngine` to read full policy entries rather than decision-only values.
- Improved fallback logic to use deployment-facing state signals instead of relying only on accuracy.
- Updated `AdaptiveEngine` to pass export metadata such as `stateDecimals` into runtime lookup logic.
- Improved `UserState` handling with safer normalization and parsing.
- Improved package documentation and README to reflect the finalized deployment-oriented architecture.
- Improved test coverage to validate the structured export format and richer adaptive decision outputs.

### Fixed
- Fixed incompatibility with the older list-based policy assumption.
- Fixed mismatch between Flutter policy lookup format and finalized Python export key format.
- Fixed outdated example and README content that no longer matched the final Python pipeline.
- Fixed analyzer issues and package-quality issues so the package passes:
    - `flutter analyze`
    - `flutter test`
    - `flutter pub publish --dry-run`

### Security
- _None._

## [0.0.1] - 2026-03-23

Initial public release of the package.

### Added
- **Core API**
    - `AdaptiveEngine` with:
        - `initFromAsset({ required String policyAssetPath, AssetBundle? bundle })`
        - `initFromString(String jsonString)`
    - `AdaptiveEngine.decide(UserState)` returning an `AdaptiveDecision`.
- **Models**
    - `UserState` (difficulty index, accuracy, response time, correct streak).
    - `AdaptiveDecision` (next difficulty label and a human-readable reason).
- **Policy loading & indexing**
    - `PolicyLoader` to load and index an RL policy exported as JSON.
    - Deterministic lookup by a discretized RL-state key (fixed 2 decimals).
- **RL state mapping utilities**
    - `StateMapper.toRlState()` mapping app telemetry → RL state `(eng, mot, flow, perf)`.
    - Grid discretization aligned with a **0.25** state resolution.
    - Stable key formatting to prevent lookup mismatches.
- **Fallback behavior**
    - Deterministic fallback decision logic when the exact policy entry is missing.

[Unreleased]: https://github.com/AmerNakhal/adaptive-gamification-library/compare/v0.0.2...HEAD
[0.0.2]: https://github.com/AmerNakhal/adaptive-gamification-library/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/AmerNakhal/adaptive-gamification-library/releases/tag/v0.0.1