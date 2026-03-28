/// Canonical difficulty levels used by the adaptive system.
enum DifficultyLevel {
  /// Lowest difficulty level.
  veryEasy,

  /// Easy difficulty level.
  easy,

  /// Medium difficulty level.
  medium,

  /// Hard difficulty level.
  hard,

  /// Highest difficulty level.
  veryHard,
}

/// Utility helpers for converting difficulty levels between:
/// - string representation
/// - enum representation
/// - integer index representation
class DifficultyMapper {
  /// Converts a string value to a [DifficultyLevel].
  ///
  /// Supported values:
  /// - `veryEasy`
  /// - `easy`
  /// - `medium`
  /// - `hard`
  /// - `veryHard`
  ///
  /// Returns [DifficultyLevel.veryEasy] if the input is unknown.
  static DifficultyLevel fromString(String value) {
    switch (value) {
      case 'veryEasy':
        return DifficultyLevel.veryEasy;
      case 'easy':
        return DifficultyLevel.easy;
      case 'medium':
        return DifficultyLevel.medium;
      case 'hard':
        return DifficultyLevel.hard;
      case 'veryHard':
        return DifficultyLevel.veryHard;
      default:
        return DifficultyLevel.veryEasy;
    }
  }

  /// Converts a [DifficultyLevel] to its string representation.
  static String toStringValue(DifficultyLevel level) {
    return level.name;
  }

  /// Converts a [DifficultyLevel] to its integer index.
  static int toIndex(DifficultyLevel level) {
    return level.index;
  }

  /// Converts an integer index to a [DifficultyLevel].
  ///
  /// Returns [DifficultyLevel.veryEasy] if the index is out of range.
  static DifficultyLevel fromIndex(int index) {
    if (index < 0 || index >= DifficultyLevel.values.length) {
      return DifficultyLevel.veryEasy;
    }
    return DifficultyLevel.values[index];
  }

  /// Converts a string difficulty value directly to its index.
  static int stringToIndex(String value) {
    return fromString(value).index;
  }

  /// Converts an integer index directly to its string representation.
  static String indexToString(int index) {
    return fromIndex(index).name;
  }
}