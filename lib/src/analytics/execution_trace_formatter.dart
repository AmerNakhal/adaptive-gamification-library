import '../domain/analytics/decision_trace.dart';
import '../domain/analytics/execution_trace.dart';

/// Formats execution and decision traces into developer-friendly text output.
///
/// This formatter is useful for:
/// - debugging
/// - logs
/// - example apps
/// - lightweight developer-facing trace inspection
class ExecutionTraceFormatter {
  /// Creates an execution trace formatter.
  const ExecutionTraceFormatter();

  /// Formats an [ExecutionTrace] into a human-readable multiline string.
  String formatExecutionTrace(ExecutionTrace trace) {
    final buffer = StringBuffer()
      ..writeln('ExecutionTrace')
      ..writeln('  traceId: ${trace.traceId}')
      ..writeln('  phase: ${trace.phase ?? 'n/a'}')
      ..writeln('  indexedPolicySize: ${trace.indexedPolicySize ?? 'n/a'}')
      ..writeln('  durationMs: ${trace.durationMs ?? 'n/a'}')
      ..writeln('  timestamp: ${trace.timestamp?.toIso8601String() ?? 'n/a'}');

    if (trace.hasPolicyMetadata) {
      buffer
        ..writeln('  policyMetadata:')
        ..writeln(
          '    formatVersion: ${trace.policyMetadata?.formatVersion ?? 'n/a'}',
        )
        ..writeln(
          '    policyType: ${trace.policyMetadata?.policyType ?? 'n/a'}',
        )
        ..writeln(
          '    exportMode: ${trace.policyMetadata?.exportMode ?? 'n/a'}',
        );
    }

    if (trace.hasDiagnostics) {
      final diagnostics = trace.diagnostics!;
      buffer
        ..writeln('  diagnostics:')
        ..writeln('    generatedStateKey: ${diagnostics.generatedStateKey}')
        ..writeln('    usedExactMatch: ${diagnostics.usedExactMatch}')
        ..writeln('    usedFallback: ${diagnostics.usedFallback}')
        ..writeln(
          '    fallbackReason: ${diagnostics.fallbackReason ?? 'n/a'}',
        )
        ..writeln('    indexedPolicySize: ${diagnostics.indexedPolicySize}');
    }

    if (trace.hasDecisionTrace) {
      buffer
        ..writeln('  decisionTrace:')
        ..write(_indent(formatDecisionTrace(trace.decisionTrace!), 4));
    }

    if (trace.hasWarnings) {
      buffer.writeln('  warnings:');
      for (final warning in trace.warnings) {
        buffer.writeln('    - $warning');
      }
    }

    if (trace.note != null && trace.note!.trim().isNotEmpty) {
      buffer.writeln('  note: ${trace.note}');
    }

    return buffer.toString().trimRight();
  }

  /// Formats a [DecisionTrace] into a human-readable multiline string.
  String formatDecisionTrace(DecisionTrace trace) {
    final buffer = StringBuffer()
      ..writeln('DecisionTrace')
      ..writeln('  traceId: ${trace.traceId}')
      ..writeln('  source: ${trace.decision.source}')
      ..writeln('  nextDifficulty: ${trace.decision.nextDifficulty}')
      ..writeln('  actionLabel: ${trace.decision.actionLabel ?? 'n/a'}')
      ..writeln('  reason: ${trace.decision.reason ?? 'n/a'}')
      ..writeln('  generatedStateKey: ${trace.context.generatedStateKey}')
      ..writeln('  usedFallback: ${trace.usedFallback}')
      ..writeln('  timestamp: ${trace.timestamp?.toIso8601String() ?? 'n/a'}');

    if (trace.hasTransition) {
      final transition = trace.transition!;
      buffer
        ..writeln('  transition:')
        ..writeln('    beforeRank: ${transition.beforeRank}')
        ..writeln('    afterRank: ${transition.afterRank}')
        ..writeln('    beforeLevel: ${transition.beforeLevel}')
        ..writeln('    afterLevel: ${transition.afterLevel}')
        ..writeln('    changeType: ${transition.changeType}')
        ..writeln('    delta: ${transition.delta}');
    }

    if (trace.hasRecommendation) {
      final recommendation = trace.recommendation!;
      buffer
        ..writeln('  recommendation:')
        ..writeln('    id: ${recommendation.id}')
        ..writeln('    type: ${recommendation.type}')
        ..writeln('    priority: ${recommendation.priority}')
        ..writeln('    title: ${recommendation.title}')
        ..writeln('    message: ${recommendation.message}');
    }

    if (trace.hasWarnings) {
      buffer.writeln('  warnings:');
      for (final warning in trace.warnings) {
        buffer.writeln('    - $warning');
      }
    }

    if (trace.note != null && trace.note!.trim().isNotEmpty) {
      buffer.writeln('  note: ${trace.note}');
    }

    return buffer.toString().trimRight();
  }

  String _indent(String text, int spaces) {
    final prefix = ' ' * spaces;
    return text
        .split('\n')
        .map((line) => '$prefix$line')
        .join('\n');
  }

  @override
  String toString() => 'ExecutionTraceFormatter()';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is ExecutionTraceFormatter;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}