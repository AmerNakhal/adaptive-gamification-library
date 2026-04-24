import '../domain/state/adaptive_state.dart';
import '../utils/normalization_utils.dart';
import 'state_adapter.dart';

/// A task-progression-oriented adapter that maps task/session telemetry into
/// [AdaptiveState].
///
/// Supported input keys include:
/// - `completion` or `completionRate`
/// - `successRate` or `success`
/// - `pace`
/// - `retryCount`
/// - `fatigue`
///
/// Heuristic mapping:
/// - performance <- success rate
/// - engagement <- completion blended with pace
/// - motivation <- completion blended with inverse fatigue/retry pressure
/// - flow <- balance of completion, success, and pace alignment
class TaskProgressionStateAdapter extends StateAdapter<Map<String, dynamic>> {
  /// Creates a task-progression state adapter.
  const TaskProgressionStateAdapter({
    this.clampValues = true,
    this.maxRetryCount = 5.0,
  });

  /// Whether final adaptive-state values should be clamped into [0.0, 1.0].
  final bool clampValues;

  /// Expected maximum retry count used for normalization.
  final double maxRetryCount;

  @override
  AdaptiveState adapt(Map<String, dynamic> input) {
    final completion = _readFirstNumeric(
      input,
      const <String>['completion', 'completionRate', 'completion_rate'],
    ) ??
        0.5;

    final successRate = _readFirstNumeric(
      input,
      const <String>['successRate', 'success_rate', 'success'],
    ) ??
        completion;

    final pace = _readFirstNumeric(
      input,
      const <String>['pace', 'progressPace', 'progress_pace'],
    ) ??
        0.5;

    final retryCount = _readFirstNumeric(
      input,
      const <String>['retryCount', 'retry_count', 'retries'],
    ) ??
        0.0;

    final fatigue = _readFirstNumeric(
      input,
      const <String>['fatigue', 'fatigueLevel', 'fatigue_level'],
    ) ??
        0.0;

    final normalizedCompletion = NormalizationUtils.clamp01(completion);
    final normalizedSuccess = NormalizationUtils.clamp01(successRate);
    final normalizedPace = NormalizationUtils.clamp01(pace);
    final normalizedFatigue = NormalizationUtils.clamp01(fatigue);
    final normalizedRetryPressure = NormalizationUtils.clamp01(
      maxRetryCount <= 0 ? 0.0 : retryCount / maxRetryCount,
    );

    final performance = normalizedSuccess;

    final engagement = NormalizationUtils.clamp01(
      (0.65 * normalizedCompletion) + (0.35 * normalizedPace),
    );

    final motivation = NormalizationUtils.clamp01(
      (0.55 * normalizedCompletion) +
          (0.25 * normalizedSuccess) +
          (0.20 * (1.0 - normalizedFatigue)) -
          (0.10 * normalizedRetryPressure),
    );

    final flow = NormalizationUtils.clamp01(
      (0.40 * normalizedCompletion) +
          (0.35 * normalizedSuccess) +
          (0.25 * normalizedPace) -
          (0.10 * normalizedFatigue),
    );

    if (!clampValues) {
      return AdaptiveState(
        engagement: engagement,
        motivation: motivation,
        flow: flow,
        performance: performance,
      );
    }

    return AdaptiveState.clamped(
      engagement: engagement,
      motivation: motivation,
      flow: flow,
      performance: performance,
    );
  }

  double? _readFirstNumeric(
      Map<String, dynamic> input,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = input[key];
      if (value == null) continue;
      if (value is num) {
        return value.toDouble();
      }
      throw FormatException(
        'TaskProgressionStateAdapter field "$key" must be numeric when provided, '
            'but got ${value.runtimeType}.',
      );
    }
    return null;
  }

  @override
  String toString() {
    return 'TaskProgressionStateAdapter('
        'clampValues: $clampValues, '
        'maxRetryCount: $maxRetryCount'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TaskProgressionStateAdapter &&
            other.clampValues == clampValues &&
            other.maxRetryCount == maxRetryCount);
  }

  @override
  int get hashCode => Object.hash(
    clampValues,
    maxRetryCount,
  );
}