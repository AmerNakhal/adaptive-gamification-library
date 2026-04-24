import '../domain/state/adaptive_state.dart';
import 'state_adapter.dart';

/// Default adapter that converts a generic map into [AdaptiveState].
///
/// Expected keys:
/// - `engagement`
/// - `motivation`
/// - `flow`
/// - `performance`
class DefaultStateAdapter extends StateAdapter<Map<String, dynamic>> {
  /// Creates a default state adapter.
  const DefaultStateAdapter({
    this.clampValues = true,
  });

  /// Whether values should be clamped into [0.0, 1.0].
  final bool clampValues;

  @override
  AdaptiveState adapt(Map<String, dynamic> input) {
    return AdaptiveState.fromMap(
      input,
      clampValues: clampValues,
    );
  }

  @override
  String toString() {
    return 'DefaultStateAdapter('
        'clampValues: $clampValues'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DefaultStateAdapter &&
            other.clampValues == clampValues);
  }

  @override
  int get hashCode => clampValues.hashCode;
}