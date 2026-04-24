/// Canonical priority labels for adaptive recommendations.
abstract class RecommendationPriority {
  /// Low-priority recommendation.
  static const String low = 'low';

  /// Medium-priority recommendation.
  static const String medium = 'medium';

  /// High-priority recommendation.
  static const String high = 'high';

  /// Urgent-priority recommendation.
  static const String urgent = 'urgent';

  /// Stable ordered list of all supported priority labels.
  static const List<String> supported = <String>[
    low,
    medium,
    high,
    urgent,
  ];

  /// Returns whether [value] is a supported recommendation priority.
  static bool isSupported(String value) {
    return supported.contains(value);
  }

  /// Returns a normalized priority label.
  ///
  /// If [value] is null, empty, or unsupported, [medium] is returned by
  /// default.
  static String normalize(String? value) {
    if (value == null) return medium;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return medium;

    return isSupported(trimmed) ? trimmed : medium;
  }
}