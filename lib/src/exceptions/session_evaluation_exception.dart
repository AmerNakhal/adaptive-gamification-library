import 'adaptive_gamification_exception.dart';

/// Exception thrown when session-level evaluation or summarization fails.
///
/// Typical causes include:
/// - insufficient session data
/// - invalid interaction history
/// - inconsistent session statistics inputs
/// - internal session aggregation failures
class SessionEvaluationException extends AdaptiveGamificationException {
  /// Creates a session evaluation exception.
  const SessionEvaluationException(
      super.message, {
        super.details,
      });

  @override
  String toString() {
    if (details == null) {
      return 'SessionEvaluationException: $message';
    }

    return 'SessionEvaluationException: $message '
        '(details: $details)';
  }
}