import 'dart:math' as math;

/// Represents the compact adaptive state consumed by the library.
///
/// This state is intentionally deployment-oriented and bounded to four
/// normalized dimensions:
/// - [engagement]
/// - [motivation]
/// - [flow]
/// - [performance]
///
/// Each value is expected to be in the range [0.0, 1.0].
class AdaptiveState {
  /// Creates an adaptive state.
  ///
  /// Use this constructor when the values are already normalized or when you
  /// intentionally want to preserve the raw values as provided.
  const AdaptiveState({
    required this.engagement,
    required this.motivation,
    required this.flow,
    required this.performance,
  });

  /// Creates an adaptive state while clamping all values into [0.0, 1.0].
  factory AdaptiveState.clamped({
    required double engagement,
    required double motivation,
    required double flow,
    required double performance,
  }) {
    return AdaptiveState(
      engagement: _clamp01(engagement),
      motivation: _clamp01(motivation),
      flow: _clamp01(flow),
      performance: _clamp01(performance),
    );
  }

  /// Creates an adaptive state from a generic map.
  ///
  /// Expected keys:
  /// - `engagement`
  /// - `motivation`
  /// - `flow`
  /// - `performance`
  ///
  /// If [clampValues] is true, values are clamped into [0.0, 1.0].
  factory AdaptiveState.fromMap(
      Map<String, dynamic> map, {
        bool clampValues = false,
      }) {
    final engagement = _readDouble(map, 'engagement');
    final motivation = _readDouble(map, 'motivation');
    final flow = _readDouble(map, 'flow');
    final performance = _readDouble(map, 'performance');

    if (clampValues) {
      return AdaptiveState.clamped(
        engagement: engagement,
        motivation: motivation,
        flow: flow,
        performance: performance,
      );
    }

    return AdaptiveState(
      engagement: engagement,
      motivation: motivation,
      flow: flow,
      performance: performance,
    );
  }

  /// Engagement indicator in the range [0.0, 1.0].
  final double engagement;

  /// Motivation indicator in the range [0.0, 1.0].
  final double motivation;

  /// Flow indicator in the range [0.0, 1.0].
  final double flow;

  /// Performance indicator in the range [0.0, 1.0].
  final double performance;

  /// Returns this state as a serializable map.
  Map<String, double> toMap() {
    return <String, double>{
      'engagement': engagement,
      'motivation': motivation,
      'flow': flow,
      'performance': performance,
    };
  }

  /// Returns the values in the stable internal order:
  /// [engagement, motivation, flow, performance].
  List<double> toList() {
    return <double>[
      engagement,
      motivation,
      flow,
      performance,
    ];
  }

  /// Returns whether all dimensions are within the normalized range [0.0, 1.0].
  bool get isNormalized {
    return _is01(engagement) &&
        _is01(motivation) &&
        _is01(flow) &&
        _is01(performance);
  }

  /// Returns the number of state dimensions.
  int get dimensionCount => 4;

  /// Returns a clamped copy of this state.
  AdaptiveState clamped() {
    return AdaptiveState.clamped(
      engagement: engagement,
      motivation: motivation,
      flow: flow,
      performance: performance,
    );
  }

  /// Returns a rounded copy of this state to [decimals] decimal places.
  AdaptiveState rounded([int decimals = 2]) {
    final factor = math.pow(10, decimals).toDouble();

    double roundValue(double value) => (value * factor).round() / factor;

    return AdaptiveState(
      engagement: roundValue(engagement),
      motivation: roundValue(motivation),
      flow: roundValue(flow),
      performance: roundValue(performance),
    );
  }

  /// Returns a copy of this state with selected values replaced.
  AdaptiveState copyWith({
    double? engagement,
    double? motivation,
    double? flow,
    double? performance,
  }) {
    return AdaptiveState(
      engagement: engagement ?? this.engagement,
      motivation: motivation ?? this.motivation,
      flow: flow ?? this.flow,
      performance: performance ?? this.performance,
    );
  }

  @override
  String toString() {
    return 'AdaptiveState('
        'engagement: $engagement, '
        'motivation: $motivation, '
        'flow: $flow, '
        'performance: $performance'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdaptiveState &&
            other.engagement == engagement &&
            other.motivation == motivation &&
            other.flow == flow &&
            other.performance == performance);
  }

  @override
  int get hashCode {
    return Object.hash(
      engagement,
      motivation,
      flow,
      performance,
    );
  }

  static double _readDouble(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) {
      throw FormatException('Missing required AdaptiveState field: $key');
    }

    final value = map[key];
    if (value is num) {
      return value.toDouble();
    }

    throw FormatException(
      'AdaptiveState field "$key" must be numeric, but got ${value.runtimeType}.',
    );
  }

  static double _clamp01(double value) {
    if (value.isNaN) return 0.0;
    if (value.isInfinite && value.isNegative) return 0.0;
    if (value.isInfinite && !value.isNegative) return 1.0;
    return value.clamp(0.0, 1.0);
  }

  static bool _is01(double value) {
    return value >= 0.0 && value <= 1.0;
  }
}