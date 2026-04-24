/// Utility helpers for working with string-based enum-like labels.
abstract class EnumUtils {
  /// Returns [fallback] if [value] is null, empty, or unsupported.
  ///
  /// Otherwise returns the trimmed [value].
  static String normalizeLabel(
      String? value, {
        required List<String> supported,
        required String fallback,
      }) {
    if (value == null) return fallback;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return fallback;

    return supported.contains(trimmed) ? trimmed : fallback;
  }

  /// Returns whether [value] is one of the [supported] labels.
  static bool isSupported(
      String value, {
        required List<String> supported,
      }) {
    return supported.contains(value);
  }

  /// Returns the index of [value] in [supported], or -1 if unsupported.
  static int indexOf(
      String? value, {
        required List<String> supported,
      }) {
    if (value == null) return -1;
    return supported.indexOf(value);
  }

  /// Returns the supported label at [index], clamped to valid bounds.
  ///
  /// If [supported] is empty, [fallback] is returned.
  static String labelFromIndex(
      int index, {
        required List<String> supported,
        required String fallback,
      }) {
    if (supported.isEmpty) return fallback;
    if (index <= 0) return supported.first;
    if (index >= supported.length - 1) return supported.last;
    return supported[index];
  }
}