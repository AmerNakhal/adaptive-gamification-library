import '../domain/decisions/adaptive_decision.dart';
import '../domain/policy/exported_policy.dart';
import '../domain/policy/policy_metadata.dart';
import '../domain/policy/policy_validation_result.dart';

/// Represents a policy that has been loaded and prepared for runtime use.
///
/// A loaded policy keeps:
/// - exported domain policy information
/// - runtime-indexed decision lookup table
/// - validation status
///
/// This is the runtime-facing representation used by the execution engine.
class LoadedPolicy {
  /// The original exported policy representation.
  final ExportedPolicy exportedPolicy;

  /// Runtime-indexed decisions keyed by deterministic state key.
  final Map<String, AdaptiveDecision> indexedDecisions;

  /// Creates a loaded policy.
  const LoadedPolicy({
    required this.exportedPolicy,
    required this.indexedDecisions,
  });

  /// Returns exported metadata.
  PolicyMetadata get metadata => exportedPolicy.metadata;

  /// Returns validation result.
  PolicyValidationResult get validationResult =>
      exportedPolicy.validationResult;

  /// Returns whether the loaded policy is valid.
  bool get isValid => exportedPolicy.isValid;

  /// Returns the number of indexed decisions.
  int get policySize => indexedDecisions.length;

  /// Returns whether indexed policy is empty.
  bool get isEmpty => indexedDecisions.isEmpty;

  /// Returns whether indexed policy is not empty.
  bool get isNotEmpty => indexedDecisions.isNotEmpty;

  /// Returns whether a decision exists for [stateKey].
  bool containsKey(String stateKey) {
    return indexedDecisions.containsKey(stateKey);
  }

  /// Returns the decision associated with [stateKey], if any.
  AdaptiveDecision? decisionForKey(String stateKey) {
    return indexedDecisions[stateKey];
  }

  /// Returns this loaded policy as a serializable map.
  ///
  /// Note:
  /// This is mainly intended for debugging, diagnostics, and testing.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'exportedPolicy': exportedPolicy.toMap(),
      'indexedDecisions': indexedDecisions.map(
            (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }

  /// Returns a copy of this loaded policy with selected values replaced.
  LoadedPolicy copyWith({
    ExportedPolicy? exportedPolicy,
    Map<String, AdaptiveDecision>? indexedDecisions,
  }) {
    return LoadedPolicy(
      exportedPolicy: exportedPolicy ?? this.exportedPolicy,
      indexedDecisions: indexedDecisions ?? this.indexedDecisions,
    );
  }

  @override
  String toString() {
    return 'LoadedPolicy('
        'isValid: $isValid, '
        'policySize: $policySize, '
        'metadata: $metadata'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LoadedPolicy &&
            other.exportedPolicy == exportedPolicy &&
            _mapEquals(other.indexedDecisions, indexedDecisions));
  }

  @override
  int get hashCode {
    return Object.hash(
      exportedPolicy,
      Object.hashAll(
        indexedDecisions.entries.map(
              (entry) => Object.hash(entry.key, entry.value),
        ),
      ),
    );
  }

  static bool _mapEquals(
      Map<String, AdaptiveDecision> a,
      Map<String, AdaptiveDecision> b,
      ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}