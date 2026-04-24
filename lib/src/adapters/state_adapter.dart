import '../domain/state/adaptive_state.dart';

/// Generic adapter contract for converting external input into [AdaptiveState].
///
/// This abstraction allows the library to remain independent from any single
/// telemetry/input schema used by consuming applications.
abstract class StateAdapter<T> {
  /// Creates a state adapter.
  const StateAdapter();

  /// Converts [input] into an [AdaptiveState].
  AdaptiveState adapt(T input);
}