import 'adaptive_gamification_exception.dart';

/// Exception thrown when adaptive runtime execution fails.
///
/// Typical causes include:
/// - using the runtime before proper initialization
/// - unexpected execution-state inconsistencies
/// - internal runtime processing failures
class RuntimeExecutionException extends AdaptiveGamificationException {
  /// Creates a runtime execution exception.
  const RuntimeExecutionException(
      super.message, {
        super.details,
      });

  @override
  String toString() {
    if (details == null) {
      return 'RuntimeExecutionException: $message';
    }

    return 'RuntimeExecutionException: $message '
        '(details: $details)';
  }
}