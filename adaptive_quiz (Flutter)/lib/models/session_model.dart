class SessionModel {
  final double avgEng;
  final double avgMot;
  final double avgFlow;
  final double avgPerf;
  final double avgDifficulty;
  final int questionsCount;
  final String timestamp;

  SessionModel({
    required this.avgEng,
    required this.avgMot,
    required this.avgFlow,
    required this.avgPerf,
    required this.avgDifficulty,
    required this.questionsCount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'avgEng': avgEng,
      'avgMot': avgMot,
      'avgFlow': avgFlow,
      'avgPerf': avgPerf,
      'avgDifficulty': avgDifficulty,
      'questionsCount': questionsCount,
      'timestamp': timestamp,
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      avgEng: map['avgEng'],
      avgMot: map['avgMot'],
      avgFlow: map['avgFlow'],
      avgPerf: map['avgPerf'],
      avgDifficulty: map['avgDifficulty'],
      questionsCount: map['questionsCount'],
      timestamp: map['timestamp'],
    );
  }
}
