import 'fallback_strategy.dart';

/// Configuration controlling runtime policy loading and execution behavior.
///
/// This configuration is focused on the operational behavior of the adaptive
/// runtime layer, including:
/// - policy validation strictness
/// - support for partial metadata
/// - state clamping behavior
/// - deterministic key precision
/// - fallback behavior
class RuntimeConfig {
  /// Creates a runtime configuration.
  const RuntimeConfig({
    this.strictValidation = true,
    this.allowPartialMetadata = true,
    this.clampStateValues = true,
    this.stateKeyDecimals = 2,
    this.fallbackStrategy = const DefaultFallbackStrategy(),
  });

  /// Whether policy validation should be treated strictly.
  ///
  /// If `true`, policy validation failures should typically prevent successful
  /// loading and initialization.
  ///
  /// If `false`, the library may continue when possible and expose warnings
  /// through validation results or diagnostics.
  final bool strictValidation;

  /// Whether partially available metadata is allowed.
  ///
  /// This is useful for working with legacy or minimal exported policies.
  final bool allowPartialMetadata;

  /// Whether adaptive state values should be clamped into [0.0, 1.0]
  /// before deterministic key generation and runtime execution.
  final bool clampStateValues;

  /// Number of decimal places used during deterministic state-key formatting.
  ///
  /// Example:
  /// - `2` -> `0.70|0.60|0.50|0.80`
  final int stateKeyDecimals;

  /// Strategy used when an exact runtime policy match is unavailable.
  final FallbackStrategy fallbackStrategy;

  /// Returns a copy of this config with selected values replaced.
  RuntimeConfig copyWith({
    bool? strictValidation,
    bool? allowPartialMetadata,
    bool? clampStateValues,
    int? stateKeyDecimals,
    FallbackStrategy? fallbackStrategy,
  }) {
    return RuntimeConfig(
      strictValidation: strictValidation ?? this.strictValidation,
      allowPartialMetadata:
      allowPartialMetadata ?? this.allowPartialMetadata,
      clampStateValues: clampStateValues ?? this.clampStateValues,
      stateKeyDecimals: stateKeyDecimals ?? this.stateKeyDecimals,
      fallbackStrategy: fallbackStrategy ?? this.fallbackStrategy,
    );
  }

  /// Returns this configuration as a serializable map.
  ///
  /// Note:
  /// The fallback strategy is represented by its runtime type name only,
  /// because strategy instances are not generally serializable.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'strictValidation': strictValidation,
      'allowPartialMetadata': allowPartialMetadata,
      'clampStateValues': clampStateValues,
      'stateKeyDecimals': stateKeyDecimals,
      'fallbackStrategy': fallbackStrategy.runtimeType.toString(),
    };
  }

  @override
  String toString() {
    return 'RuntimeConfig('
        'strictValidation: $strictValidation, '
        'allowPartialMetadata: $allowPartialMetadata, '
        'clampStateValues: $clampStateValues, '
        'stateKeyDecimals: $stateKeyDecimals, '
        'fallbackStrategy: ${fallbackStrategy.runtimeType}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RuntimeConfig &&
            other.strictValidation == strictValidation &&
            other.allowPartialMetadata == allowPartialMetadata &&
            other.clampStateValues == clampStateValues &&
            other.stateKeyDecimals == stateKeyDecimals &&
            other.fallbackStrategy.runtimeType ==
                fallbackStrategy.runtimeType);
  }

  @override
  int get hashCode {
    return Object.hash(
      strictValidation,
      allowPartialMetadata,
      clampStateValues,
      stateKeyDecimals,
      fallbackStrategy.runtimeType,
    );
  }
}