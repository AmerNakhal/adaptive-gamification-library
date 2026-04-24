/// Canonical labels for the adaptive state dimensions used by the library.
abstract class StateDimensionLabels {
  /// Engagement dimension label.
  static const String engagement = 'engagement';

  /// Motivation dimension label.
  static const String motivation = 'motivation';

  /// Flow dimension label.
  static const String flow = 'flow';

  /// Performance dimension label.
  static const String performance = 'performance';

  /// Stable ordered list of all state dimension labels.
  static const List<String> ordered = <String>[
    engagement,
    motivation,
    flow,
    performance,
  ];

  /// Returns whether [label] is a supported state dimension label.
  static bool isSupported(String label) {
    return ordered.contains(label);
  }
}