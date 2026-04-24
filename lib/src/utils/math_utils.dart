import 'dart:math' as math;

/// Utility helpers for lightweight mathematical operations used across
/// the library.
abstract class MathUtils {
  /// Returns the sum of [values].
  static double sum(Iterable<double> values) {
    return values.fold<double>(0.0, (acc, value) => acc + value);
  }

  /// Returns the arithmetic mean of [values], or null if empty.
  static double? mean(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return null;
    return sum(list) / list.length;
  }

  /// Returns the arithmetic mean of non-null values, or null if no values exist.
  static double? meanNullable(Iterable<double?> values) {
    final filtered = values.whereType<double>().toList(growable: false);
    if (filtered.isEmpty) return null;
    return mean(filtered);
  }

  /// Returns the minimum value of [values], or null if empty.
  static double? minValue(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return null;
    return list.reduce(math.min);
  }

  /// Returns the maximum value of [values], or null if empty.
  static double? maxValue(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return null;
    return list.reduce(math.max);
  }

  /// Returns the sample-free population variance of [values], or null if empty.
  static double? variance(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return null;

    final avg = mean(list)!;
    final squaredDiffSum = list.fold<double>(
      0.0,
          (acc, value) => acc + math.pow(value - avg, 2).toDouble(),
    );

    return squaredDiffSum / list.length;
  }

  /// Returns the standard deviation of [values], or null if empty.
  static double? standardDeviation(Iterable<double> values) {
    final v = variance(values);
    if (v == null) return null;
    return math.sqrt(v);
  }

  /// Returns the median of [values], or null if empty.
  static double? median(Iterable<double> values) {
    final list = values.toList(growable: false)..sort();
    if (list.isEmpty) return null;

    final middle = list.length ~/ 2;
    if (list.length.isOdd) {
      return list[middle];
    }

    return (list[middle - 1] + list[middle]) / 2.0;
  }

  /// Returns [numerator] / [denominator], or [fallback] if denominator is zero.
  static double safeDivide(
      num numerator,
      num denominator, {
        double fallback = 0.0,
      }) {
    if (denominator == 0) return fallback;
    return numerator / denominator;
  }

  /// Returns [value] rounded to [decimals] decimal places.
  static double roundTo(double value, int decimals) {
    final factor = math.pow(10, decimals).toDouble();
    return (value * factor).round() / factor;
  }

  /// Returns whether [value] is approximately equal to [other] within [epsilon].
  static bool approximatelyEqual(
      double value,
      double other, {
        double epsilon = 1e-9,
      }) {
    return (value - other).abs() <= epsilon;
  }

  /// Returns the percentage value for [part] over [whole].
  ///
  /// If [whole] is zero, returns [fallback].
  static double percentage(
      num part,
      num whole, {
        double fallback = 0.0,
      }) {
    if (whole == 0) return fallback;
    return (part / whole) * 100.0;
  }

  /// Returns a value linearly interpolated between [start] and [end].
  ///
  /// [t] is typically expected in [0.0, 1.0], but is not clamped here.
  static double lerp(
      double start,
      double end,
      double t,
      ) {
    return start + ((end - start) * t);
  }

  /// Returns the absolute distance between [a] and [b].
  static double distance(
      double a,
      double b,
      ) {
    return (a - b).abs();
  }
}