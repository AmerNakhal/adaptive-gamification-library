import '../domain/state/adaptive_state.dart';
import '../utils/normalization_utils.dart';
import 'state_adapter.dart';

/// A quiz-oriented adapter that maps common quiz telemetry into [AdaptiveState].
///
/// Expected input keys are flexible, but the following are supported:
/// - `correctness` or `accuracy`
/// - `responseTime`
/// - `streak`
/// - `completion`
///
/// Heuristic mapping:
/// - performance <- correctness/accuracy
/// - motivation <- streak/completion blend
/// - engagement <- completion with a light streak contribution
/// - flow <- blended correctness/completion/response-time alignment
class QuizStateAdapter extends StateAdapter<Map<String, dynamic>> {
  /// Creates a quiz-state adapter.
  const QuizStateAdapter({
    this.clampValues = true,
    this.maxResponseTime = 60.0,
    this.maxStreak = 10.0,
  });

  /// Whether final adaptive-state values should be clamped into [0.0, 1.0].
  final bool clampValues;

  /// Expected maximum response time used for normalization.
  ///
  /// Larger response times are treated as lower flow alignment.
  final double maxResponseTime;

  /// Expected maximum streak used for normalization.
  final double maxStreak;

  @override
  AdaptiveState adapt(Map<String, dynamic> input) {
    final correctness = _readFirstNumeric(
      input,
      const <String>['correctness', 'accuracy', 'score'],
    ) ??
        0.5;

    final responseTime = _readFirstNumeric(
      input,
      const <String>['responseTime', 'response_time', 'duration'],
    );

    final streak = _readFirstNumeric(
      input,
      const <String>['streak', 'currentStreak', 'current_streak'],
    ) ??
        0.0;

    final completion = _readFirstNumeric(
      input,
      const <String>['completion', 'completionRate', 'completion_rate'],
    ) ??
        correctness;

    final normalizedCorrectness = NormalizationUtils.clamp01(correctness);
    final normalizedCompletion = NormalizationUtils.clamp01(completion);
    final normalizedStreak = NormalizationUtils.clamp01(
      maxStreak <= 0 ? 0.0 : streak / maxStreak,
    );

    final normalizedResponseAlignment = responseTime == null
        ? 0.5
        : _invertNormalizedResponseTime(responseTime);

    final performance = normalizedCorrectness;

    final engagement = NormalizationUtils.clamp01(
      (0.75 * normalizedCompletion) + (0.25 * normalizedStreak),
    );

    final motivation = NormalizationUtils.clamp01(
      (0.60 * normalizedStreak) + (0.40 * normalizedCompletion),
    );

    final flow = NormalizationUtils.clamp01(
      (0.40 * normalizedCorrectness) +
          (0.30 * normalizedCompletion) +
          (0.30 * normalizedResponseAlignment),
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

  double _invertNormalizedResponseTime(double responseTime) {
    if (maxResponseTime <= 0) return 0.5;

    final normalized =
    NormalizationUtils.clamp01(responseTime / maxResponseTime);
    return 1.0 - normalized;
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
        'QuizStateAdapter field "$key" must be numeric when provided, '
            'but got ${value.runtimeType}.',
      );
    }
    return null;
  }

  @override
  String toString() {
    return 'QuizStateAdapter('
        'clampValues: $clampValues, '
        'maxResponseTime: $maxResponseTime, '
        'maxStreak: $maxStreak'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is QuizStateAdapter &&
            other.clampValues == clampValues &&
            other.maxResponseTime == maxResponseTime &&
            other.maxStreak == maxStreak);
  }

  @override
  int get hashCode => Object.hash(
    clampValues,
    maxResponseTime,
    maxStreak,
  );
}