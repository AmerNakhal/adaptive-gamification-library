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

## [0.2.1] - 2026-04-21

Minor-version release focused on consolidating the package as a reusable Flutter library for adaptive policy integration, with aligned public API presentation, stronger documentation, cleaner example positioning, and finalized release-readiness improvements.

### Added
- Clearer public library-facing support for:
  - deterministic adaptive decision execution
  - higher-level recommendation generation
  - decision traces and execution traces
  - session-aware summaries and analytics snapshots
- A more complete developer-facing example application covering:
  - quiz integration
  - task progression integration
  - manual playground-based inspection
- Improved library-facing documentation describing:
  - policy loading
  - state adaptation
  - recommendations
  - traces
  - session-aware analytics

### Changed
- Reframed the package more precisely as a reusable Flutter library centered on exported adaptive policy integration.
- Refined README structure and package description so the public presentation matches the implemented library surface more accurately.
- Improved public API presentation around configuration, decisions, recommendations, transitions, sessions, analytics, and policy handling.
- Cleaned example application presentation so it is positioned as a runnable integration artifact for the library rather than a standalone product claim.
- Updated release metadata, changelog organization, and package-facing documentation to align with version `0.2.0`.

### Deprecated
- _None._

### Removed
- Removed outdated wording that described the package too narrowly as a minimal runtime wrapper.
- Removed older documentation wording and examples that no longer matched the evolved library structure.

### Fixed
- Fixed final documentation and release-bookkeeping inconsistencies remaining after the `0.1.x` release line.
- Fixed residual package-readiness issues affecting the final publishable `0.2.0` release state.
- Fixed remaining mismatches between the documented library surface and the implemented package structure.

### Security
- _None._

## [0.1.2] - 2026-04-21

Patch release focused on final documentation alignment, example cleanup, and release-readiness improvements after the `0.1.1` release.

### Added
- _None._

### Changed
- Refined package positioning and documentation to better reflect the package as a reusable Flutter library for adaptive policy integration.
- Finalized README structure and public-facing package description for the `0.1.2` patch release.
- Cleaned example application presentation and package metadata for the `0.1.2` release.

### Deprecated
- _None._

### Removed
- _None._

### Fixed
- Fixed final documentation and release-bookkeeping inconsistencies remaining after the `0.1.1` release.
- Fixed residual package-readiness issues affecting the final publishable patch state.

### Security
- _None._

## [0.1.1] - 2026-04-21

Patch release focused on package-evaluation compatibility, API-surface cleanup, and final publish-readiness fixes.

### Added
- _None._

### Changed
- Replaced the `AdaptiveDecision.fromMap(...)` factory constructor with a static `fromMap(...)` helper for safer package compatibility and evaluation behavior.
- Finalized package metadata, examples, and supporting documentation for the `0.1.1` patch release.

### Deprecated
- _None._

### Removed
- _None._

### Fixed
- Fixed package-evaluation issues related to `AdaptiveDecision` deserialization behavior.
- Fixed final publish-readiness inconsistencies identified after the `0.1.0` library-maturation release.

### Security
- _None._

## [0.1.0] - 2026-04-21

Library maturation release focused on making the package clearer and stronger as a reusable Flutter library for adaptive policy integration.

### Added
- Richer public library support for:
  - deterministic adaptive decision execution
  - higher-level recommendation generation
  - decision traces and execution traces
  - session-aware summaries and analytics snapshots
- Stronger structured policy-handling support for exported policy artifacts and public runtime utilities.
- Improved example application visibility for:
  - decision outcomes
  - recommendation outputs
  - traces and diagnostics
  - session-aware behavior across multiple integration scenarios

### Changed
- Reframed the package more precisely as a reusable Flutter library centered on exported adaptive policy integration.
- Improved public API clarity around configuration, decisions, recommendations, transitions, sessions, analytics, and policy handling.
- Improved structured policy loading, runtime execution flow, and fallback traceability.
- Improved package/example organization so the library is exposed more clearly as a reusable software artifact rather than a narrow lookup wrapper.
- Updated README and package documentation to align with the matured library surface.

### Deprecated
- _None._

### Removed
- Removed outdated package wording and examples that no longer matched the evolved library structure.

### Fixed
- Fixed package/example mismatches in documentation and integration examples.
- Fixed runtime integration issues uncovered while aligning the Flutter package with the finalized structured export workflow.
- Fixed package quality issues so the package remains compatible with:
  - `flutter analyze`
  - `flutter test`
  - `dart pub publish --dry-run`

### Security
- _None._

## [0.0.2] - 2026-03-29

Major update of the Flutter package to align with the finalized external policy export pipeline and structured exported-policy format.

### Added
- Support for the structured exported policy format with:
  - top-level `metadata`
  - top-level `policy`
- Richer exported-policy metadata handling and lookup support.
- Improved example application visibility for:
  - policy metadata display
  - runtime state inspection
  - adaptive decision details
  - exact-match versus fallback visibility

### Changed
- Updated policy loading to support the finalized exported-policy structure and Python-compatible policy keys.
- Updated deployment-facing state handling to use the compact state representation:
  - `engagement`
  - `motivation`
  - `flow`
  - `performance`
- Updated runtime key generation to the finalized export-compatible format.
- Improved fallback behavior to use deployment-facing state signals rather than relying on a narrower earlier assumption.
- Improved package documentation and README to reflect the finalized deployment-oriented architecture.
- Improved test coverage to validate structured exported-policy handling and richer adaptive decision outputs.

### Deprecated
- _None._

### Removed
- _None._

### Fixed
- Fixed incompatibility with older list-based policy assumptions.
- Fixed mismatch between Flutter policy lookup format and finalized exported-policy key format.
- Fixed outdated example and README content that no longer matched the finalized export workflow.
- Fixed analyzer issues and package-quality issues so the package passes:
  - `flutter analyze`
  - `flutter test`
  - `flutter pub publish --dry-run`

### Security
- _None._

## [0.0.1] - 2026-03-23

Initial public release of the package.

### Added
- Core package support for deterministic exported-policy loading and lookup.
- Initial adaptive decision model and basic runtime policy execution flow.
- Initial state-mapping utilities for converting application telemetry into deployment-facing adaptive state.
- Deterministic fallback behavior when the exact exported policy entry is missing.
- Initial package structure, README, and example scaffolding.

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

[Unreleased]: https://github.com/AmerNakhal/adaptive-gamification-library/compare/v0.2.0...HEAD
[0.2.1]: https://github.com/AmerNakhal/adaptive-gamification-library/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/AmerNakhal/adaptive-gamification-library/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/AmerNakhal/adaptive-gamification-library/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/AmerNakhal/adaptive-gamification-library/compare/v0.0.2...v0.1.0
[0.0.2]: https://github.com/AmerNakhal/adaptive-gamification-library/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/AmerNakhal/adaptive-gamification-library/releases/tag/v0.0.1