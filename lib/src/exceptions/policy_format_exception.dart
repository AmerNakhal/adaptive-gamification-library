import 'adaptive_gamification_exception.dart';

/// Exception thrown when an exported policy has an invalid or unsupported
/// structural format.
///
/// Typical causes include:
/// - malformed JSON
/// - missing required fields
/// - invalid field types
/// - unsupported exported schema shapes
class PolicyFormatException extends AdaptiveGamificationException {
  /// Creates a policy format exception.
  const PolicyFormatException(
      super.message, {
        super.details,
      });

  @override
  String toString() {
    if (details == null) {
      return 'PolicyFormatException: $message';
    }

    return 'PolicyFormatException: $message '
        '(details: $details)';
  }
}