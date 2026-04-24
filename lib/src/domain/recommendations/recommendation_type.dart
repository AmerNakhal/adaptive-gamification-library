/// Canonical type labels for adaptive recommendations.
abstract class RecommendationType {
  /// Recommendation focused on difficulty adjustment.
  static const String difficultyAdjustment = 'difficulty_adjustment';

  /// Recommendation focused on motivational support.
  static const String motivationalSupport = 'motivational_support';

  /// Recommendation focused on flow alignment.
  static const String flowAlignment = 'flow_alignment';

  /// Recommendation focused on recovery or rest.
  static const String recovery = 'recovery';

  /// Recommendation focused on maintaining the current course.
  static const String maintenance = 'maintenance';

  /// Stable ordered list of all supported recommendation types.
  static const List<String> supported = <String>[
    difficultyAdjustment,
    motivationalSupport,
    flowAlignment,
    recovery,
    maintenance,
  ];

  /// Returns whether [value] is a supported recommendation type.
  static bool isSupported(String value) {
    return supported.contains(value);
  }

  /// Returns a normalized recommendation type.
  ///
  /// If [value] is null, empty, or unsupported, [difficultyAdjustment] is
  /// returned by default.
  static String normalize(String? value) {
    if (value == null) return difficultyAdjustment;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return difficultyAdjustment;

    return isSupported(trimmed) ? trimmed : difficultyAdjustment;
  }
}