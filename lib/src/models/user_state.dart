/// Represents the minimal runtime learner telemetry consumed by the package.
///
/// This object is provided by the host application and is later mapped into
/// the deployment-facing RL state:
/// - engagement
/// - motivation
/// - flow
/// - performance
class UserState {
  /// Creates an immutable user-state snapshot.
  const UserState({
    required this.currentDifficultyIndex,
    required this.accuracy,
    required this.responseTime,
    required this.correctStreak,
  });

  /// Creates a [UserState] from a map and normalizes the resulting values.
  factory UserState.fromMap(Map<String, dynamic> map) {
    return UserState(
      currentDifficultyIndex: _asInt(map['currentDifficultyIndex'], fallback: 0),
      accuracy: _asDouble(map['accuracy'], fallback: 0.0),
      responseTime: _asDouble(map['responseTime'], fallback: 0.0),
      correctStreak: _asInt(map['correctStreak'], fallback: 0),
    ).normalized();
  }

  /// Current application difficulty level index.
  ///
  /// Typical convention:
  /// - `0` = veryEasy
  /// - `1` = easy
  /// - `2` = medium
  /// - `3` = hard
  /// - `4` = veryHard
  final int currentDifficultyIndex;

  /// Recent or session-level accuracy in the range `[0.0, 1.0]`.
  final double accuracy;

  /// Response time in seconds.
  final double responseTime;

  /// Number of consecutive correct answers.
  final int correctStreak;

  /// Returns a normalized version of this state for safer downstream use.
  ///
  /// Normalization rules:
  /// - [accuracy] is clamped to `[0.0, 1.0]`
  /// - [responseTime] is forced to be non-negative
  /// - [correctStreak] is forced to be non-negative
  /// - [currentDifficultyIndex] is forced to be non-negative
  UserState normalized() {
    return UserState(
      currentDifficultyIndex:
      currentDifficultyIndex < 0 ? 0 : currentDifficultyIndex,
      accuracy: accuracy.clamp(0.0, 1.0),
      responseTime: responseTime < 0 ? 0.0 : responseTime,
      correctStreak: correctStreak < 0 ? 0 : correctStreak,
    );
  }

  /// Converts this state to a serializable map.
  Map<String, dynamic> toMap() => {
    'currentDifficultyIndex': currentDifficultyIndex,
    'accuracy': accuracy,
    'responseTime': responseTime,
    'correctStreak': correctStreak,
  };

  /// Returns a copy of this state with selected fields replaced.
  UserState copyWith({
    int? currentDifficultyIndex,
    double? accuracy,
    double? responseTime,
    int? correctStreak,
  }) {
    return UserState(
      currentDifficultyIndex:
      currentDifficultyIndex ?? this.currentDifficultyIndex,
      accuracy: accuracy ?? this.accuracy,
      responseTime: responseTime ?? this.responseTime,
      correctStreak: correctStreak ?? this.correctStreak,
    );
  }

  static int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  static double _asDouble(dynamic value, {required double fallback}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return fallback;
  }

  @override
  String toString() {
    return 'UserState('
        'diff=$currentDifficultyIndex, '
        'acc=$accuracy, '
        'rt=$responseTime, '
        'streak=$correctStreak'
        ')';
  }
}