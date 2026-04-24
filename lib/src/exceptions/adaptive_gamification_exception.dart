/// Base exception type for the adaptive_gamification library.
///
/// All library-specific exceptions should extend this type so consumers can
/// catch a single shared exception family when needed.
class AdaptiveGamificationException implements Exception {
  /// Human-readable exception message.
  final String message;

  /// Optional additional details attached to the exception.
  final Object? details;

  /// Creates a library exception.
  const AdaptiveGamificationException(
      this.message, {
        this.details,
      });

  @override
  String toString() {
    if (details == null) {
      return 'AdaptiveGamificationException: $message';
    }

    return 'AdaptiveGamificationException: $message '
        '(details: $details)';
  }
}