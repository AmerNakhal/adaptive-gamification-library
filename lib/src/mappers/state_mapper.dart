import '../adapters/default_state_adapter.dart';
import '../adapters/state_adapter.dart';
import '../domain/state/adaptive_state.dart';

/// High-level helper for mapping external input into [AdaptiveState].
///
/// This class provides a thin orchestration layer over state adapters so
/// consuming code can use a single consistent entry point for state mapping.
class StateMapper {
  /// Default adapter used for generic map-based inputs.
  final DefaultStateAdapter defaultAdapter;

  /// Creates a state mapper.
  const StateMapper({
    this.defaultAdapter = const DefaultStateAdapter(),
  });

  /// Maps a generic input [map] into [AdaptiveState] using the default adapter.
  AdaptiveState fromMap(Map<String, dynamic> map) {
    return defaultAdapter.adapt(map);
  }

  /// Maps [input] using the provided [adapter].
  AdaptiveState mapWith<T>(
      T input,
      StateAdapter<T> adapter,
      ) {
    return adapter.adapt(input);
  }

  @override
  String toString() {
    return 'StateMapper('
        'defaultAdapter: $defaultAdapter'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StateMapper &&
            other.defaultAdapter == defaultAdapter);
  }

  @override
  int get hashCode => defaultAdapter.hashCode;
}