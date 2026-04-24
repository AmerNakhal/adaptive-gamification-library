/// Canonical semantic difficulty level labels used by the library.
abstract class DifficultyLevel {
  /// Very easy difficulty.
  static const String veryEasy = 'veryEasy';

  /// Easy difficulty.
  static const String easy = 'easy';

  /// Medium difficulty.
  static const String medium = 'medium';

  /// Hard difficulty.
  static const String hard = 'hard';

  /// Very hard difficulty.
  static const String veryHard = 'veryHard';

  /// Stable ordered list of all supported difficulty level labels.
  static const List<String> supported = <String>[
    veryEasy,
    easy,
    medium,
    hard,
    veryHard,
  ];

  /// Returns whether [value] is a supported difficulty level label.
  static bool isSupported(String value) {
    return supported.contains(value);
  }

  /// Returns a normalized difficulty level label.
  ///
  /// If [value] is null, empty, or unsupported, [medium] is returned by
  /// default.
  static String normalize(String? value) {
    if (value == null) return medium;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return medium;

    return isSupported(trimmed) ? trimmed : medium;
  }

  /// Returns the index of a supported difficulty level.
  ///
  /// If [value] is unsupported, returns the index of [medium].
  static int rankOf(String? value) {
    final normalized = normalize(value);
    return supported.indexOf(normalized);
  }

  /// Returns the difficulty level label for [rank].
  ///
  /// If [rank] is out of bounds, the nearest valid level is returned.
  static String fromRank(int rank) {
    if (rank <= 0) return veryEasy;
    if (rank >= supported.length - 1) return veryHard;
    return supported[rank];
  }
}