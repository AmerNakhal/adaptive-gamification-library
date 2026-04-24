import 'package:flutter/foundation.dart';

@immutable
class DemoUserInput {
  final String sessionId;
  final double engagement;
  final double motivation;
  final double flow;
  final double performance;
  final int currentDifficultyRank;
  final String? sourceScenario;
  final DateTime timestamp;

  const DemoUserInput({
    required this.sessionId,
    required this.engagement,
    required this.motivation,
    required this.flow,
    required this.performance,
    required this.currentDifficultyRank,
    required this.timestamp,
    this.sourceScenario,
  });

  DemoUserInput copyWith({
    String? sessionId,
    double? engagement,
    double? motivation,
    double? flow,
    double? performance,
    int? currentDifficultyRank,
    String? sourceScenario,
    DateTime? timestamp,
  }) {
    return DemoUserInput(
      sessionId: sessionId ?? this.sessionId,
      engagement: engagement ?? this.engagement,
      motivation: motivation ?? this.motivation,
      flow: flow ?? this.flow,
      performance: performance ?? this.performance,
      currentDifficultyRank:
      currentDifficultyRank ?? this.currentDifficultyRank,
      sourceScenario: sourceScenario ?? this.sourceScenario,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'engagement': engagement,
      'motivation': motivation,
      'flow': flow,
      'performance': performance,
      'currentDifficultyRank': currentDifficultyRank,
      'sourceScenario': sourceScenario,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DemoUserInput.fromMap(Map<String, dynamic> map) {
    final sessionId = map['sessionId'];
    final engagement = map['engagement'];
    final motivation = map['motivation'];
    final flow = map['flow'];
    final performance = map['performance'];
    final currentDifficultyRank = map['currentDifficultyRank'];
    final sourceScenario = map['sourceScenario'];
    final timestamp = map['timestamp'];

    if (sessionId is! String || sessionId.trim().isEmpty) {
      throw const FormatException(
        'DemoUserInput requires a non-empty string "sessionId".',
      );
    }
    if (engagement is! num) {
      throw const FormatException(
        'DemoUserInput requires numeric "engagement".',
      );
    }
    if (motivation is! num) {
      throw const FormatException(
        'DemoUserInput requires numeric "motivation".',
      );
    }
    if (flow is! num) {
      throw const FormatException(
        'DemoUserInput requires numeric "flow".',
      );
    }
    if (performance is! num) {
      throw const FormatException(
        'DemoUserInput requires numeric "performance".',
      );
    }
    if (currentDifficultyRank is! num) {
      throw const FormatException(
        'DemoUserInput requires numeric "currentDifficultyRank".',
      );
    }
    if (sourceScenario != null && sourceScenario is! String) {
      throw const FormatException(
        'DemoUserInput "sourceScenario" must be a string when provided.',
      );
    }
    if (timestamp is! String || timestamp.trim().isEmpty) {
      throw const FormatException(
        'DemoUserInput requires a non-empty ISO string "timestamp".',
      );
    }

    DateTime parsedTimestamp;
    try {
      parsedTimestamp = DateTime.parse(timestamp);
    } catch (_) {
      throw const FormatException(
        'DemoUserInput "timestamp" must be a valid ISO-8601 string.',
      );
    }

    return DemoUserInput(
      sessionId: sessionId,
      engagement: engagement.toDouble(),
      motivation: motivation.toDouble(),
      flow: flow.toDouble(),
      performance: performance.toDouble(),
      currentDifficultyRank: currentDifficultyRank.toInt(),
      sourceScenario: sourceScenario,
      timestamp: parsedTimestamp,
    );
  }

  @override
  String toString() {
    return 'DemoUserInput('
        'sessionId: $sessionId, '
        'engagement: $engagement, '
        'motivation: $motivation, '
        'flow: $flow, '
        'performance: $performance, '
        'currentDifficultyRank: $currentDifficultyRank, '
        'sourceScenario: $sourceScenario, '
        'timestamp: $timestamp'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DemoUserInput &&
            other.sessionId == sessionId &&
            other.engagement == engagement &&
            other.motivation == motivation &&
            other.flow == flow &&
            other.performance == performance &&
            other.currentDifficultyRank == currentDifficultyRank &&
            other.sourceScenario == sourceScenario &&
            other.timestamp == timestamp);
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    engagement,
    motivation,
    flow,
    performance,
    currentDifficultyRank,
    sourceScenario,
    timestamp,
  );
}