import '../core/policy_loader.dart';
import '../models/user_state.dart';

/// Maps application-level user telemetry into the deployment-facing RL state:
/// [engagement, motivation, flow, performance]
///
/// The exported policy is built over a discretized state grid, so runtime values
/// are first converted to continuous normalized features, then snapped to the
/// nearest export grid before lookup.
///
/// Current telemetry inputs expected from [UserState]:
/// - accuracy
/// - responseTime
/// - correctStreak
/// - currentDifficultyIndex
class StateMapper {
  /// Default discretization grid used by Python export.
  ///
  /// Example:
  /// 0.25 -> {0.00, 0.25, 0.50, 0.75, 1.00}
  static const double defaultGrid = 0.25;

  /// Converts a [UserState] into a continuous RL state vector:
  /// [eng, mot, flow, perf]
  ///
  /// Feature design goals:
  /// - performance reflects recent correctness
  /// - motivation reflects persistence/confidence tendency
  /// - engagement reflects responsiveness + sustained activity
  /// - flow reflects challenge-skill balance using both performance and
  ///   current difficulty context
  static List<double> toRlState(UserState s) {
    final double perf = clamp01(s.accuracy);

    // Faster response -> higher responsiveness.
    // This uses a saturating inverse relation and then clamps.
    final double speedFactor = clamp01(1.0 / (1.0 + s.responseTime));

    // Streak-based persistence signal.
    final double streakFactor = clamp01(s.correctStreak / 5.0);

    // Current difficulty normalized to [0,1].
    // Assumes typical app difficulty indices in a small bounded range.
    final double difficultyFactor = clamp01(s.currentDifficultyIndex / 4.0);

    // Engagement:
    // Blend responsiveness, recent performance, and a smaller streak component.
    final double eng = clamp01(
      (0.45 * speedFactor) +
          (0.40 * perf) +
          (0.15 * streakFactor),
    );

    // Motivation:
    // More persistence-oriented than engagement; combines streak and performance.
    final double mot = clamp01(
      (0.55 * streakFactor) +
          (0.35 * perf) +
          (0.10 * (1.0 - clamp01(s.responseTime / 10.0))),
    );

    // Flow:
    // Approximate challenge-skill balance.
    // If difficulty is too high/low relative to performance, flow decreases.
    final double balanceGap = (difficultyFactor - perf).abs();
    final double flow = clamp01(
      (0.60 * (1.0 - balanceGap)) +
          (0.25 * eng) +
          (0.15 * mot),
    );

    return <double>[eng, mot, flow, perf];
  }

  /// Discretizes a value to the nearest point on the export grid.
  static double discretize(
      double v, {
        double grid = defaultGrid,
      }) {
    final double snapped = (v / grid).round() * grid;
    return clamp01(snapped);
  }

  /// Discretizes a continuous RL state vector.
  static List<double> discretizeRlState(
      List<double> rl, {
        double grid = defaultGrid,
      }) {
    if (rl.length != 4) {
      throw ArgumentError(
        'RL state must have exactly 4 values: [eng, mot, flow, perf].',
      );
    }

    return rl
        .map((double x) => discretize(x, grid: grid))
        .toList(growable: false);
  }

  /// Builds the exported policy lookup key using the Python-compatible format:
  ///
  /// eng=0.25|mot=0.50|flow=0.75|perf=1.00
  static String buildKeyFromRlState(
      List<double> rl, {
        double grid = defaultGrid,
        int decimals = 2,
      }) {
    final List<double> d = discretizeRlState(rl, grid: grid);

    return PolicyLoader.buildStateKey(
      eng: d[0],
      mot: d[1],
      flow: d[2],
      perf: d[3],
      decimals: decimals,
    );
  }

  /// Convenience method:
  /// Converts a [UserState] directly into a lookup key.
  static String buildKeyFromUserState(
      UserState s, {
        double grid = defaultGrid,
        int decimals = 2,
      }) {
    final List<double> rl = toRlState(s);
    return buildKeyFromRlState(
      rl,
      grid: grid,
      decimals: decimals,
    );
  }

  /// Clamps a numeric value into [0.0, 1.0].
  static double clamp01(double v) => v.clamp(0.0, 1.0);
}