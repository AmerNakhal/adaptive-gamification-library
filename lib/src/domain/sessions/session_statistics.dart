/// Represents aggregated statistics for an adaptive session.
///
/// This model is intended to capture session-level quantitative summaries such
/// as counts, averages, and progression indicators.
class SessionStatistics {
  /// Total number of recorded interactions in the session.
  final int interactionCount;

  /// Total number of successful outcomes recorded in the session.
  final int successfulCount;

  /// Total number of unsuccessful outcomes recorded in the session.
  final int unsuccessfulCount;

  /// Optional average normalized score across outcomes.
  final double? averageScore;

  /// Optional average response time across interactions.
  final double? averageResponseTime;

  /// Optional average streak indicator across interactions.
  final double? averageStreak;

  /// Optional average difficulty rank across interactions.
  final double? averageDifficultyRank;

  /// Optional minimum observed difficulty rank.
  final int? minDifficultyRank;

  /// Optional maximum observed difficulty rank.
  final int? maxDifficultyRank;

  /// Optional total number of retries across outcomes.
  final int? totalRetryCount;

  /// Creates session statistics.
  const SessionStatistics({
    required this.interactionCount,
    required this.successfulCount,
    required this.unsuccessfulCount,
    this.averageScore,
    this.averageResponseTime,
    this.averageStreak,
    this.averageDifficultyRank,
    this.minDifficultyRank,
    this.maxDifficultyRank,
    this.totalRetryCount,
  });

  /// Creates session statistics from a generic map.
  factory SessionStatistics.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('interactionCount')) {
      throw const FormatException(
        'Missing required SessionStatistics field: interactionCount',
      );
    }

    if (!map.containsKey('successfulCount')) {
      throw const FormatException(
        'Missing required SessionStatistics field: successfulCount',
      );
    }

    if (!map.containsKey('unsuccessfulCount')) {
      throw const FormatException(
        'Missing required SessionStatistics field: unsuccessfulCount',
      );
    }

    final interactionCountValue = map['interactionCount'];
    final successfulCountValue = map['successfulCount'];
    final unsuccessfulCountValue = map['unsuccessfulCount'];
    final averageScoreValue = map['averageScore'];
    final averageResponseTimeValue = map['averageResponseTime'];
    final averageStreakValue = map['averageStreak'];
    final averageDifficultyRankValue = map['averageDifficultyRank'];
    final minDifficultyRankValue = map['minDifficultyRank'];
    final maxDifficultyRankValue = map['maxDifficultyRank'];
    final totalRetryCountValue = map['totalRetryCount'];

    if (interactionCountValue is! num) {
      throw FormatException(
        'SessionStatistics field "interactionCount" must be numeric, '
            'but got ${interactionCountValue.runtimeType}.',
      );
    }

    if (successfulCountValue is! num) {
      throw FormatException(
        'SessionStatistics field "successfulCount" must be numeric, '
            'but got ${successfulCountValue.runtimeType}.',
      );
    }

    if (unsuccessfulCountValue is! num) {
      throw FormatException(
        'SessionStatistics field "unsuccessfulCount" must be numeric, '
            'but got ${unsuccessfulCountValue.runtimeType}.',
      );
    }

    if (averageScoreValue != null && averageScoreValue is! num) {
      throw FormatException(
        'SessionStatistics field "averageScore" must be numeric when provided, '
            'but got ${averageScoreValue.runtimeType}.',
      );
    }

    if (averageResponseTimeValue != null && averageResponseTimeValue is! num) {
      throw FormatException(
        'SessionStatistics field "averageResponseTime" must be numeric when provided, '
            'but got ${averageResponseTimeValue.runtimeType}.',
      );
    }

    if (averageStreakValue != null && averageStreakValue is! num) {
      throw FormatException(
        'SessionStatistics field "averageStreak" must be numeric when provided, '
            'but got ${averageStreakValue.runtimeType}.',
      );
    }

    if (averageDifficultyRankValue != null &&
        averageDifficultyRankValue is! num) {
      throw FormatException(
        'SessionStatistics field "averageDifficultyRank" must be numeric when provided, '
            'but got ${averageDifficultyRankValue.runtimeType}.',
      );
    }

    if (minDifficultyRankValue != null && minDifficultyRankValue is! num) {
      throw FormatException(
        'SessionStatistics field "minDifficultyRank" must be numeric when provided, '
            'but got ${minDifficultyRankValue.runtimeType}.',
      );
    }

    if (maxDifficultyRankValue != null && maxDifficultyRankValue is! num) {
      throw FormatException(
        'SessionStatistics field "maxDifficultyRank" must be numeric when provided, '
            'but got ${maxDifficultyRankValue.runtimeType}.',
      );
    }

    if (totalRetryCountValue != null && totalRetryCountValue is! num) {
      throw FormatException(
        'SessionStatistics field "totalRetryCount" must be numeric when provided, '
            'but got ${totalRetryCountValue.runtimeType}.',
      );
    }

    return SessionStatistics(
      interactionCount: interactionCountValue.toInt(),
      successfulCount: successfulCountValue.toInt(),
      unsuccessfulCount: unsuccessfulCountValue.toInt(),
      averageScore: averageScoreValue == null
          ? null
          : (averageScoreValue as num).toDouble(),
      averageResponseTime: averageResponseTimeValue == null
          ? null
          : (averageResponseTimeValue as num).toDouble(),
      averageStreak: averageStreakValue == null
          ? null
          : (averageStreakValue as num).toDouble(),
      averageDifficultyRank: averageDifficultyRankValue == null
          ? null
          : (averageDifficultyRankValue as num).toDouble(),
      minDifficultyRank: minDifficultyRankValue == null
          ? null
          : (minDifficultyRankValue as num).toInt(),
      maxDifficultyRank: maxDifficultyRankValue == null
          ? null
          : (maxDifficultyRankValue as num).toInt(),
      totalRetryCount: totalRetryCountValue == null
          ? null
          : (totalRetryCountValue as num).toInt(),
    );
  }

  /// Returns this statistics object as a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'interactionCount': interactionCount,
      'successfulCount': successfulCount,
      'unsuccessfulCount': unsuccessfulCount,
      'averageScore': averageScore,
      'averageResponseTime': averageResponseTime,
      'averageStreak': averageStreak,
      'averageDifficultyRank': averageDifficultyRank,
      'minDifficultyRank': minDifficultyRank,
      'maxDifficultyRank': maxDifficultyRank,
      'totalRetryCount': totalRetryCount,
    };
  }

  /// Returns success ratio if interaction data is available.
  double get successRate {
    if (interactionCount == 0) return 0.0;
    return successfulCount / interactionCount;
  }

  /// Returns failure ratio if interaction data is available.
  double get failureRate {
    if (interactionCount == 0) return 0.0;
    return unsuccessfulCount / interactionCount;
  }

  /// Returns whether difficulty-range data is available.
  bool get hasDifficultyRange =>
      minDifficultyRank != null && maxDifficultyRank != null;

  /// Returns whether retry data is available.
  bool get hasRetryData => totalRetryCount != null;

  /// Returns a copy of this statistics object with selected values replaced.
  SessionStatistics copyWith({
    int? interactionCount,
    int? successfulCount,
    int? unsuccessfulCount,
    double? averageScore,
    double? averageResponseTime,
    double? averageStreak,
    double? averageDifficultyRank,
    int? minDifficultyRank,
    int? maxDifficultyRank,
    int? totalRetryCount,
  }) {
    return SessionStatistics(
      interactionCount: interactionCount ?? this.interactionCount,
      successfulCount: successfulCount ?? this.successfulCount,
      unsuccessfulCount: unsuccessfulCount ?? this.unsuccessfulCount,
      averageScore: averageScore ?? this.averageScore,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      averageStreak: averageStreak ?? this.averageStreak,
      averageDifficultyRank:
      averageDifficultyRank ?? this.averageDifficultyRank,
      minDifficultyRank: minDifficultyRank ?? this.minDifficultyRank,
      maxDifficultyRank: maxDifficultyRank ?? this.maxDifficultyRank,
      totalRetryCount: totalRetryCount ?? this.totalRetryCount,
    );
  }

  @override
  String toString() {
    return 'SessionStatistics('
        'interactionCount: $interactionCount, '
        'successfulCount: $successfulCount, '
        'unsuccessfulCount: $unsuccessfulCount, '
        'averageScore: $averageScore, '
        'averageResponseTime: $averageResponseTime, '
        'averageStreak: $averageStreak, '
        'averageDifficultyRank: $averageDifficultyRank, '
        'minDifficultyRank: $minDifficultyRank, '
        'maxDifficultyRank: $maxDifficultyRank, '
        'totalRetryCount: $totalRetryCount'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SessionStatistics &&
            other.interactionCount == interactionCount &&
            other.successfulCount == successfulCount &&
            other.unsuccessfulCount == unsuccessfulCount &&
            other.averageScore == averageScore &&
            other.averageResponseTime == averageResponseTime &&
            other.averageStreak == averageStreak &&
            other.averageDifficultyRank == averageDifficultyRank &&
            other.minDifficultyRank == minDifficultyRank &&
            other.maxDifficultyRank == maxDifficultyRank &&
            other.totalRetryCount == totalRetryCount);
  }

  @override
  int get hashCode {
    return Object.hash(
      interactionCount,
      successfulCount,
      unsuccessfulCount,
      averageScore,
      averageResponseTime,
      averageStreak,
      averageDifficultyRank,
      minDifficultyRank,
      maxDifficultyRank,
      totalRetryCount,
    );
  }
}