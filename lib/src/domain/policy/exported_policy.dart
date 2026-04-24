import 'policy_entry.dart';
import 'policy_metadata.dart';
import 'policy_validation_result.dart';

/// Represents a fully parsed exported adaptive policy.
///
/// This model combines:
/// - exported metadata
/// - typed policy entries
/// - validation results
///
/// It serves as the primary domain-level representation of the exported policy
/// before runtime indexing and execution.
class ExportedPolicy {
  /// Exported policy metadata.
  final PolicyMetadata metadata;

  /// Typed policy entries.
  final List<PolicyEntry> entries;

  /// Validation result associated with this policy.
  final PolicyValidationResult validationResult;

  /// Creates an exported policy.
  const ExportedPolicy({
    required this.metadata,
    required this.entries,
    required this.validationResult,
  });

  /// Creates an exported policy from a generic map.
  ///
  /// Expected keys:
  /// - `metadata` (optional)
  /// - `entries` (required)
  /// - `validationResult` (optional)
  ///
  /// Note:
  /// This constructor expects already-normalized policy-entry objects.
  /// Raw Python export formats should typically be converted by a loader first.
  factory ExportedPolicy.fromMap(Map<String, dynamic> map) {
    final metadataValue = map['metadata'];
    final entriesValue = map['entries'];
    final validationResultValue = map['validationResult'];

    if (entriesValue == null) {
      throw const FormatException(
        'Missing required ExportedPolicy field: entries',
      );
    }

    if (metadataValue != null && metadataValue is! Map<String, dynamic>) {
      throw FormatException(
        'ExportedPolicy field "metadata" must be a Map<String, dynamic> when provided, '
            'but got ${metadataValue.runtimeType}.',
      );
    }

    if (entriesValue is! List) {
      throw FormatException(
        'ExportedPolicy field "entries" must be a List, '
            'but got ${entriesValue.runtimeType}.',
      );
    }

    if (validationResultValue != null &&
        validationResultValue is! Map<String, dynamic>) {
      throw FormatException(
        'ExportedPolicy field "validationResult" must be a Map<String, dynamic> when provided, '
            'but got ${validationResultValue.runtimeType}.',
      );
    }

    final parsedEntries = <PolicyEntry>[];
    for (final item in entriesValue) {
      if (item is! Map<String, dynamic>) {
        throw FormatException(
          'ExportedPolicy field "entries" must contain only Map<String, dynamic> values, '
              'but found ${item.runtimeType}.',
        );
      }
      parsedEntries.add(PolicyEntry.fromMap(item));
    }

    return ExportedPolicy(
      metadata: metadataValue == null
          ? const PolicyMetadata()
          : PolicyMetadata.fromMap(metadataValue as Map<String, dynamic>),
      entries: List<PolicyEntry>.unmodifiable(parsedEntries),
      validationResult: validationResultValue == null
          ? PolicyValidationResult.valid()
          : PolicyValidationResult.fromMap(
        validationResultValue as Map<String, dynamic>,
      ),
    );
  }

  /// Returns this exported policy as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'metadata': metadata.toMap(),
      'entries': entries.map((entry) => entry.toMap()).toList(growable: false),
      'validationResult': validationResult.toMap(),
    };
  }

  /// Returns whether the exported policy is valid.
  bool get isValid => validationResult.isValid;

  /// Returns the number of entries in the exported policy.
  int get entryCount => entries.length;

  /// Returns whether this policy contains any entries.
  bool get isEmpty => entries.isEmpty;

  /// Returns whether this policy contains at least one entry.
  bool get isNotEmpty => entries.isNotEmpty;

  /// Returns whether exported metadata is available.
  bool get hasMetadata => metadata != const PolicyMetadata();

  /// Returns the first matching policy entry for [stateKey], if any.
  PolicyEntry? entryForKey(String stateKey) {
    for (final entry in entries) {
      if (entry.stateKey == stateKey) {
        return entry;
      }
    }
    return null;
  }

  /// Returns whether the policy contains an entry for [stateKey].
  bool containsKey(String stateKey) {
    return entryForKey(stateKey) != null;
  }

  /// Returns a copy of this exported policy with selected values replaced.
  ExportedPolicy copyWith({
    PolicyMetadata? metadata,
    List<PolicyEntry>? entries,
    PolicyValidationResult? validationResult,
  }) {
    return ExportedPolicy(
      metadata: metadata ?? this.metadata,
      entries: entries ?? this.entries,
      validationResult: validationResult ?? this.validationResult,
    );
  }

  @override
  String toString() {
    return 'ExportedPolicy('
        'metadata: $metadata, '
        'entryCount: $entryCount, '
        'validationResult: $validationResult'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ExportedPolicy &&
            other.metadata == metadata &&
            _listEquals(other.entries, entries) &&
            other.validationResult == validationResult);
  }

  @override
  int get hashCode {
    return Object.hash(
      metadata,
      Object.hashAll(entries),
      validationResult,
    );
  }

  static bool _listEquals(List<PolicyEntry> a, List<PolicyEntry> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}