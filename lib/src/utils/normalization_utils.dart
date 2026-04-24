import 'dart:math' as math;

/// Utility helpers for numeric normalization and bounded runtime processing.
abstract class NormalizationUtils {
  /// Clamps [value] into the range [min, max].
  ///
  /// NaN returns [min].
  static double clamp(
      double value, {
        required double min,
        required double max,
      }) {
    if (value.isNaN) return min;
    if (value.isInfinite && value.isNegative) return min;
    if (value.isInfinite && !value.isNegative) return max;
    return value.clamp(min, max);
  }

  /// Clamps [value] into the range [0.0, 1.0].
  static double clamp01(double value) {
    return clamp(value, min: 0.0, max: 1.0);
  }

  /// Returns whether [value] lies in the range [0.0, 1.0].
  static bool isNormalized01(double value) {
    return value >= 0.0 && value <= 1.0;
  }

  /// Normalizes [value] from [sourceMin, sourceMax] into [0.0, 1.0].
  ///
  /// If [clampResult] is true, the result is clamped to [0.0, 1.0].
  /// If the source range is degenerate, returns 0.0.
  static double normalizeToUnit(
      double value, {
        required double sourceMin,
        required double sourceMax,
        bool clampResult = true,
      }) {
    if (sourceMax == sourceMin) return 0.0;

    final normalized = (value - sourceMin) / (sourceMax - sourceMin);
    return clampResult ? clamp01(normalized) : normalized;
  }

  /// Maps [value] from [sourceMin, sourceMax] into [targetMin, targetMax].
  ///
  /// If the source range is degenerate, returns [targetMin].
  static double remap(
      double value, {
        required double sourceMin,
        required double sourceMax,
        required double targetMin,
        required double targetMax,
        bool clampSource = false,
      }) {
    if (sourceMax == sourceMin) return targetMin;

    final effectiveValue = clampSource
        ? clamp(value, min: sourceMin, max: sourceMax)
        : value;

    final t = (effectiveValue - sourceMin) / (sourceMax - sourceMin);
    return targetMin + (t * (targetMax - targetMin));
  }

  /// Safely converts a nullable numeric-like value to double.
  ///
  /// Returns null if [value] is null.
  /// Throws [FormatException] if [value] is not numeric.
  static double? asNullableDouble(
      dynamic value, {
        String? fieldName,
      }) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    final label = fieldName == null ? 'value' : 'field "$fieldName"';
    throw FormatException('Expected numeric $label, but got ${value.runtimeType}.');
  }

  /// Safely converts a nullable numeric-like value to int.
  ///
  /// Returns null if [value] is null.
  /// Throws [FormatException] if [value] is not numeric.
  static int? asNullableInt(
      dynamic value, {
        String? fieldName,
      }) {
    if (value == null) return null;
    if (value is num) return value.toInt();

    final label = fieldName == null ? 'value' : 'field "$fieldName"';
    throw FormatException('Expected numeric $label, but got ${value.runtimeType}.');
  }

  /// Rounds [value] to [decimals] decimal places.
  static double roundTo(double value, int decimals) {
    final factor = math.pow(10, decimals).toDouble();
    return (value * factor).round() / factor;
  }

  /// Returns the arithmetic mean of [values].
  ///
  /// Returns null if [values] is empty.
  static double? average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return null;

    final sum = list.fold<double>(0.0, (acc, v) => acc + v);
    return sum / list.length;
  }

  /// Returns the arithmetic mean of non-null values from [values].
  ///
  /// Returns null if no non-null values exist.
  static double? averageNullable(Iterable<double?> values) {
    final filtered = values.whereType<double>().toList(growable: false);
    if (filtered.isEmpty) return null;
    return average(filtered);
  }

  /// Returns the minimum integer value from [values], or null if empty.
  static int? minInt(Iterable<int> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return null;
    return list.reduce(math.min);
  }

  /// Returns the maximum integer value from [values], or null if empty.
  static int? maxInt(Iterable<int> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return null;
    return list.reduce(math.max);
  }
}