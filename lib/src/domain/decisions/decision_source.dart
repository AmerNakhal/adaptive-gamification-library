/// Canonical source labels describing how an adaptive decision was produced.
abstract class DecisionSource {
  /// Decision came from an exact policy match.
  static const String exactMatch = 'exact_match';

  /// Decision came from fallback logic.
  static const String fallback = 'fallback';

  /// Decision was inferred or derived from a higher-level mapping step.
  static const String inferred = 'inferred';

  /// Decision was mapped from an external or intermediate representation.
  static const String mapped = 'mapped';

  /// Stable ordered list of all supported decision source labels.
  static const List<String> supported = <String>[
    exactMatch,
    fallback,
    inferred,
    mapped,
  ];

  /// Returns whether [value] is a supported decision source label.
  static bool isSupported(String value) {
    return supported.contains(value);
  }

  /// Returns a normalized decision source label.
  ///
  /// If [value] is null, empty, or unsupported, [exactMatch] is returned by
  /// default.
  static String normalize(String? value) {
    if (value == null) return exactMatch;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return exactMatch;

    return isSupported(trimmed) ? trimmed : exactMatch;
  }
}