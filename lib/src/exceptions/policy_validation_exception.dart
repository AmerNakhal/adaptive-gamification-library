import '../domain/policy/policy_validation_result.dart';
import 'adaptive_gamification_exception.dart';

/// Exception thrown when an exported policy fails validation.
///
/// This exception is intended for cases where the policy structure is readable
/// but logically invalid according to the library's validation rules.
class PolicyValidationException extends AdaptiveGamificationException {
  /// Fatal validation errors associated with the failed policy.
  final List<String> errors;

  /// Non-fatal warnings associated with the failed policy.
  final List<String> warnings;

  /// Optional validation result attached to the exception.
  final PolicyValidationResult? validationResult;

  /// Creates a policy validation exception.
  const PolicyValidationException(
      super.message, {
        required this.errors,
        this.warnings = const <String>[],
        this.validationResult,
        super.details,
      });

  @override
  String toString() {
    return 'PolicyValidationException('
        'message: $message, '
        'errors: $errors, '
        'warnings: $warnings, '
        'details: $details'
        ')';
  }
}