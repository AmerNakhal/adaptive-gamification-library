import 'difficulty_change_type.dart';
import 'difficulty_level.dart';

/// Represents a semantic transition between two difficulty levels.
///
/// This model is used to describe how difficulty changes as a result of an
/// adaptive decision, including:
/// - the previous difficulty
/// - the next difficulty
/// - the rank delta
/// - the canonical change type
class DifficultyTransition {
  /// Previous difficulty rank.
  final int beforeRank;

  /// Next difficulty rank.
  final int afterRank;

  /// Previous difficulty semantic label.
  final String beforeLevel;

  /// Next difficulty semantic label.
  final String afterLevel;

  /// Canonical change type.
  ///
  /// See [DifficultyChangeType].
  final String changeType;

  /// Numeric difference between [afterRank] and [beforeRank].
  final int delta;

  /// Creates a difficulty transition.
  const DifficultyTransition({
    required this.beforeRank,
    required this.afterRank,
    required this.beforeLevel,
    required this.afterLevel,
    required this.changeType,
    required this.delta,
  });

  /// Creates a difficulty transition from ranks.
  factory DifficultyTransition.fromRanks({
    required int beforeRank,
    required int afterRank,
  }) {
    final delta = afterRank - beforeRank;

    final changeType = delta > 0
        ? DifficultyChangeType.increase
        : delta < 0
        ? DifficultyChangeType.decrease
        : DifficultyChangeType.maintain;

    return DifficultyTransition(
      beforeRank: beforeRank,
      afterRank: afterRank,
      beforeLevel: DifficultyLevel.fromRank(beforeRank),
      afterLevel: DifficultyLevel.fromRank(afterRank),
      changeType: changeType,
      delta: delta,
    );
  }

  /// Creates a difficulty transition from a generic map.
  ///
  /// Expected keys:
  /// - `beforeRank` (required, numeric)
  /// - `afterRank` (required, numeric)
  /// - `beforeLevel` (optional)
  /// - `afterLevel` (optional)
  /// - `changeType` (optional)
  /// - `delta` (optional)
  ///
  /// If semantic fields are missing, they are derived from the rank values.
  factory DifficultyTransition.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('beforeRank')) {
      throw const FormatException(
        'Missing required DifficultyTransition field: beforeRank',
      );
    }

    if (!map.containsKey('afterRank')) {
      throw const FormatException(
        'Missing required DifficultyTransition field: afterRank',
      );
    }

    final beforeRankValue = map['beforeRank'];
    final afterRankValue = map['afterRank'];
    final beforeLevelValue = map['beforeLevel'];
    final afterLevelValue = map['afterLevel'];
    final changeTypeValue = map['changeType'];
    final deltaValue = map['delta'];

    if (beforeRankValue is! num) {
      throw FormatException(
        'DifficultyTransition field "beforeRank" must be numeric, '
            'but got ${beforeRankValue.runtimeType}.',
      );
    }

    if (afterRankValue is! num) {
      throw FormatException(
        'DifficultyTransition field "afterRank" must be numeric, '
            'but got ${afterRankValue.runtimeType}.',
      );
    }

    if (beforeLevelValue != null && beforeLevelValue is! String) {
      throw FormatException(
        'DifficultyTransition field "beforeLevel" must be a String when provided, '
            'but got ${beforeLevelValue.runtimeType}.',
      );
    }

    if (afterLevelValue != null && afterLevelValue is! String) {
      throw FormatException(
        'DifficultyTransition field "afterLevel" must be a String when provided, '
            'but got ${afterLevelValue.runtimeType}.',
      );
    }

    if (changeTypeValue != null && changeTypeValue is! String) {
      throw FormatException(
        'DifficultyTransition field "changeType" must be a String when provided, '
            'but got ${changeTypeValue.runtimeType}.',
      );
    }

    if (deltaValue != null && deltaValue is! num) {
      throw FormatException(
        'DifficultyTransition field "delta" must be numeric when provided, '
            'but got ${deltaValue.runtimeType}.',
      );
    }

    final beforeRank = beforeRankValue.toInt();
    final afterRank = afterRankValue.toInt();
    final derivedDelta = afterRank - beforeRank;

    final normalizedBeforeLevel = DifficultyLevel.normalize(
      beforeLevelValue as String?,
    );
    final normalizedAfterLevel = DifficultyLevel.normalize(
      afterLevelValue as String?,
    );

    final normalizedChangeType = DifficultyChangeType.normalize(
      changeTypeValue as String?,
    );

    return DifficultyTransition(
      beforeRank: beforeRank,
      afterRank: afterRank,
      beforeLevel: beforeLevelValue == null
          ? DifficultyLevel.fromRank(beforeRank)
          : normalizedBeforeLevel,
      afterLevel: afterLevelValue == null
          ? DifficultyLevel.fromRank(afterRank)
          : normalizedAfterLevel,
      changeType: changeTypeValue == null
          ? (derivedDelta > 0
          ? DifficultyChangeType.increase
          : derivedDelta < 0
          ? DifficultyChangeType.decrease
          : DifficultyChangeType.maintain)
          : normalizedChangeType,
      delta: deltaValue == null ? derivedDelta : (deltaValue as num).toInt(),
    );
  }

  /// Returns this transition as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'beforeRank': beforeRank,
      'afterRank': afterRank,
      'beforeLevel': beforeLevel,
      'afterLevel': afterLevel,
      'changeType': changeType,
      'delta': delta,
    };
  }

  /// Returns whether difficulty increased.
  bool get isIncrease => changeType == DifficultyChangeType.increase;

  /// Returns whether difficulty decreased.
  bool get isDecrease => changeType == DifficultyChangeType.decrease;

  /// Returns whether difficulty stayed the same.
  bool get isMaintain => changeType == DifficultyChangeType.maintain;

  /// Returns a copy of this transition with selected values replaced.
  DifficultyTransition copyWith({
    int? beforeRank,
    int? afterRank,
    String? beforeLevel,
    String? afterLevel,
    String? changeType,
    int? delta,
  }) {
    return DifficultyTransition(
      beforeRank: beforeRank ?? this.beforeRank,
      afterRank: afterRank ?? this.afterRank,
      beforeLevel: beforeLevel ?? this.beforeLevel,
      afterLevel: afterLevel ?? this.afterLevel,
      changeType: changeType ?? this.changeType,
      delta: delta ?? this.delta,
    );
  }

  @override
  String toString() {
    return 'DifficultyTransition('
        'beforeRank: $beforeRank, '
        'afterRank: $afterRank, '
        'beforeLevel: $beforeLevel, '
        'afterLevel: $afterLevel, '
        'changeType: $changeType, '
        'delta: $delta'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DifficultyTransition &&
            other.beforeRank == beforeRank &&
            other.afterRank == afterRank &&
            other.beforeLevel == beforeLevel &&
            other.afterLevel == afterLevel &&
            other.changeType == changeType &&
            other.delta == delta);
  }

  @override
  int get hashCode {
    return Object.hash(
      beforeRank,
      afterRank,
      beforeLevel,
      afterLevel,
      changeType,
      delta,
    );
  }
}