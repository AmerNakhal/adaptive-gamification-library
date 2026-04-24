/// Represents the result of validating an exported policy.
///
/// A validation result can contain:
/// - an overall validity flag
/// - non-fatal warnings
/// - fatal or blocking errors
class PolicyValidationResult {
  /// Whether the validated policy is considered valid.
  final bool isValid;

  /// Fatal or blocking validation errors.
  final List<String> errors;

  /// Non-fatal validation warnings.
  final List<String> warnings;

  /// Creates a validation result.
  const PolicyValidationResult({
    required this.isValid,
    this.errors = const <String>[],
    this.warnings = const <String>[],
  });

  /// Creates a valid validation result.
  factory PolicyValidationResult.valid({
    List<String> warnings = const <String>[],
  }) {
    return PolicyValidationResult(
      isValid: true,
      errors: const <String>[],
      warnings: warnings,
    );
  }

  /// Creates an invalid validation result.
  factory PolicyValidationResult.invalid({
    required List<String> errors,
    List<String> warnings = const <String>[],
  }) {
    return PolicyValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Creates a validation result from a generic map.
  factory PolicyValidationResult.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('isValid')) {
      throw const FormatException(
        'Missing required PolicyValidationResult field: isValid',
      );
    }

    final isValidValue = map['isValid'];
    final errorsValue = map['errors'];
    final warningsValue = map['warnings'];

    if (isValidValue is! bool) {
      throw FormatException(
        'PolicyValidationResult field "isValid" must be a bool, '
            'but got ${isValidValue.runtimeType}.',
      );
    }

    return PolicyValidationResult(
      isValid: isValidValue,
      errors: _readStringList(
        errorsValue,
        fieldName: 'errors',
      ),
      warnings: _readStringList(
        warningsValue,
        fieldName: 'warnings',
      ),
    );
  }

  /// Returns this validation result as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isValid': isValid,
      'errors': errors,
      'warnings': warnings,
    };
  }

  /// Returns whether validation contains any errors.
  bool get hasErrors => errors.isNotEmpty;

  /// Returns whether validation contains any warnings.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Returns the total number of issues (errors + warnings).
  int get issueCount => errors.length + warnings.length;

  /// Returns a copy of this result with selected values replaced.
  PolicyValidationResult copyWith({
    bool? isValid,
    List<String>? errors,
    List<String>? warnings,
  }) {
    return PolicyValidationResult(
      isValid: isValid ?? this.isValid,
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
    );
  }

  @override
  String toString() {
    return 'PolicyValidationResult('
        'isValid: $isValid, '
        'errors: $errors, '
        'warnings: $warnings'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PolicyValidationResult &&
            other.isValid == isValid &&
            _listEquals(other.errors, errors) &&
            _listEquals(other.warnings, warnings));
  }

  @override
  int get hashCode {
    return Object.hash(
      isValid,
      Object.hashAll(errors),
      Object.hashAll(warnings),
    );
  }

  static List<String> _readStringList(
      dynamic value, {
        required String fieldName,
      }) {
    if (value == null) return const <String>[];

    if (value is! List) {
      throw FormatException(
        'PolicyValidationResult field "$fieldName" must be a List when provided, '
            'but got ${value.runtimeType}.',
      );
    }

    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'PolicyValidationResult field "$fieldName" must contain only String values, '
              'but found ${item.runtimeType}.',
        );
      }
      result.add(item);
    }

    return List<String>.unmodifiable(result);
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}