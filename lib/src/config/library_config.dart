import 'diagnostics_config.dart';
import 'runtime_config.dart';

/// Top-level configuration for the adaptive_gamification library.
///
/// This configuration groups the major configurable concerns of the library:
/// - runtime behavior
/// - diagnostics and traceability behavior
///
/// It is intended to be passed into the high-level library facade so that
/// consumers can configure the library through a single coherent entry point.
class LibraryConfig {
  /// Creates a top-level library configuration.
  const LibraryConfig({
    this.runtime = const RuntimeConfig(),
    this.diagnostics = const DiagnosticsConfig(),
  });

  /// Configuration for runtime policy loading and execution.
  final RuntimeConfig runtime;

  /// Configuration for diagnostics, traces, and analytics-oriented visibility.
  final DiagnosticsConfig diagnostics;

  /// Returns a copy of this config with selected values replaced.
  LibraryConfig copyWith({
    RuntimeConfig? runtime,
    DiagnosticsConfig? diagnostics,
  }) {
    return LibraryConfig(
      runtime: runtime ?? this.runtime,
      diagnostics: diagnostics ?? this.diagnostics,
    );
  }

  /// Returns this configuration as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'runtime': runtime.toMap(),
      'diagnostics': diagnostics.toMap(),
    };
  }

  @override
  String toString() {
    return 'LibraryConfig('
        'runtime: $runtime, '
        'diagnostics: $diagnostics'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LibraryConfig &&
            other.runtime == runtime &&
            other.diagnostics == diagnostics);
  }

  @override
  int get hashCode => Object.hash(runtime, diagnostics);
}