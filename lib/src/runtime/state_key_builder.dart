import '../domain/state/adaptive_state.dart';
import '../utils/normalization_utils.dart';

/// Builds deterministic runtime state keys from [AdaptiveState].
///
/// The generated key follows the compact ordered format:
/// `engagement|motivation|flow|performance`
///
/// Example with 2 decimals:
/// `0.70|0.60|0.50|0.80`
class StateKeyBuilder {
  /// Creates a deterministic state-key builder.
  const StateKeyBuilder({
    this.decimals = 2,
    this.clampValues = true,
    this.delimiter = '|',
  });

  /// Number of decimal places used when formatting state values.
  final int decimals;

  /// Whether values should be clamped into [0.0, 1.0] before formatting.
  final bool clampValues;

  /// Delimiter used between formatted state dimensions.
  final String delimiter;

  /// Builds a deterministic state key from [state].
  String build(AdaptiveState state) {
    final effectiveState = clampValues ? state.clamped() : state;

    final values = <double>[
      effectiveState.engagement,
      effectiveState.motivation,
      effectiveState.flow,
      effectiveState.performance,
    ];

    final formatted = values.map(_formatValue).join(delimiter);
    return formatted;
  }

  /// Returns the normalized state actually used for key generation.
  AdaptiveState normalizeState(AdaptiveState state) {
    return clampValues ? state.clamped() : state;
  }

  /// Returns a copy of this builder with selected values replaced.
  StateKeyBuilder copyWith({
    int? decimals,
    bool? clampValues,
    String? delimiter,
  }) {
    return StateKeyBuilder(
      decimals: decimals ?? this.decimals,
      clampValues: clampValues ?? this.clampValues,
      delimiter: delimiter ?? this.delimiter,
    );
  }

  @override
  String toString() {
    return 'StateKeyBuilder('
        'decimals: $decimals, '
        'clampValues: $clampValues, '
        'delimiter: $delimiter'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StateKeyBuilder &&
            other.decimals == decimals &&
            other.clampValues == clampValues &&
            other.delimiter == delimiter);
  }

  @override
  int get hashCode => Object.hash(decimals, clampValues, delimiter);

  String _formatValue(double value) {
    final effectiveValue =
    clampValues ? NormalizationUtils.clamp01(value) : value;

    final rounded = NormalizationUtils.roundTo(effectiveValue, decimals);
    return rounded.toStringAsFixed(decimals);
  }
}