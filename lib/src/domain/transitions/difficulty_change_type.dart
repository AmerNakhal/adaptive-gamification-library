/// Canonical labels describing how difficulty changes between two states.
abstract class DifficultyChangeType {
  /// Difficulty should increase.
  static const String increase = 'increase';

  /// Difficulty should decrease.
  static const String decrease = 'decrease';

  /// Difficulty should remain the same.
  static const String maintain = 'maintain';

  /// Stable ordered list of all supported difficulty change labels.
  static const List<String> supported = <String>[
    increase,
    decrease,
    maintain,
  ];

  /// Returns whether [value] is a supported difficulty change label.
  static bool isSupported(String value) {
    return supported.contains(value);
  }

  /// Returns a normalized difficulty change label.
  ///
  /// If [value] is null, empty, or unsupported, [maintain] is returned by
  /// default.
  static String normalize(String? value) {
    if (value == null) return maintain;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return maintain;

    return isSupported(trimmed) ? trimmed : maintain;
  }
}