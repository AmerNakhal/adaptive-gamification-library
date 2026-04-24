/// Configuration controlling diagnostics, tracing, and analytics visibility.
///
/// This configuration determines how much runtime observability the library
/// should expose to the consuming application.
class DiagnosticsConfig {
  /// Creates a diagnostics configuration.
  const DiagnosticsConfig({
    this.enableRuntimeDiagnostics = false,
    this.enableDecisionTraces = false,
    this.enableExecutionTraces = false,
    this.enableAnalyticsSnapshots = false,
    this.includeWarnings = true,
  });

  /// Whether lightweight runtime diagnostics should be generated.
  ///
  /// Diagnostics typically include:
  /// - normalized state
  /// - generated state key
  /// - exact/fallback usage
  /// - warnings
  final bool enableRuntimeDiagnostics;

  /// Whether rich decision traces should be generated.
  ///
  /// Decision traces may include:
  /// - decision context
  /// - difficulty transition
  /// - support strategy
  /// - rich decision details
  final bool enableDecisionTraces;

  /// Whether execution traces should be generated.
  ///
  /// Execution traces can capture step-by-step runtime processing and are
  /// primarily useful for debugging, testing, and research-oriented analysis.
  final bool enableExecutionTraces;

  /// Whether analytics snapshots should be generated.
  ///
  /// Analytics snapshots are useful for session-level summaries, dashboards,
  /// and post-hoc analysis.
  final bool enableAnalyticsSnapshots;

  /// Whether warnings should be retained inside diagnostics outputs.
  final bool includeWarnings;

  /// Returns whether any diagnostics-related feature is enabled.
  bool get isAnyDiagnosticsEnabled {
    return enableRuntimeDiagnostics ||
        enableDecisionTraces ||
        enableExecutionTraces ||
        enableAnalyticsSnapshots;
  }

  /// Returns a copy of this config with selected values replaced.
  DiagnosticsConfig copyWith({
    bool? enableRuntimeDiagnostics,
    bool? enableDecisionTraces,
    bool? enableExecutionTraces,
    bool? enableAnalyticsSnapshots,
    bool? includeWarnings,
  }) {
    return DiagnosticsConfig(
      enableRuntimeDiagnostics:
      enableRuntimeDiagnostics ?? this.enableRuntimeDiagnostics,
      enableDecisionTraces:
      enableDecisionTraces ?? this.enableDecisionTraces,
      enableExecutionTraces:
      enableExecutionTraces ?? this.enableExecutionTraces,
      enableAnalyticsSnapshots:
      enableAnalyticsSnapshots ?? this.enableAnalyticsSnapshots,
      includeWarnings: includeWarnings ?? this.includeWarnings,
    );
  }

  /// Returns this configuration as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enableRuntimeDiagnostics': enableRuntimeDiagnostics,
      'enableDecisionTraces': enableDecisionTraces,
      'enableExecutionTraces': enableExecutionTraces,
      'enableAnalyticsSnapshots': enableAnalyticsSnapshots,
      'includeWarnings': includeWarnings,
    };
  }

  @override
  String toString() {
    return 'DiagnosticsConfig('
        'enableRuntimeDiagnostics: $enableRuntimeDiagnostics, '
        'enableDecisionTraces: $enableDecisionTraces, '
        'enableExecutionTraces: $enableExecutionTraces, '
        'enableAnalyticsSnapshots: $enableAnalyticsSnapshots, '
        'includeWarnings: $includeWarnings'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DiagnosticsConfig &&
            other.enableRuntimeDiagnostics == enableRuntimeDiagnostics &&
            other.enableDecisionTraces == enableDecisionTraces &&
            other.enableExecutionTraces == enableExecutionTraces &&
            other.enableAnalyticsSnapshots == enableAnalyticsSnapshots &&
            other.includeWarnings == includeWarnings);
  }

  @override
  int get hashCode {
    return Object.hash(
      enableRuntimeDiagnostics,
      enableDecisionTraces,
      enableExecutionTraces,
      enableAnalyticsSnapshots,
      includeWarnings,
    );
  }
}