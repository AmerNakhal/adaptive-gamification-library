import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/session_model.dart';
import '../services/database_helper.dart';

class ResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> sessionLog;

  const ResultScreen({super.key, required this.sessionLog});

  @override
  Widget build(BuildContext context) {
    String finalLevel = "Unknown";
    List<FlSpot> engSpots = [];
    List<FlSpot> motSpots = [];
    List<FlSpot> flowSpots = [];
    List<FlSpot> perfSpots = [];

    for (int i = 0; i < sessionLog.length; i++) {
      final state = sessionLog[i]['learner_state'];
      if (state != null) {
        engSpots.add(FlSpot(i.toDouble(), state['eng']));
        motSpots.add(FlSpot(i.toDouble(), state['mot']));
        flowSpots.add(FlSpot(i.toDouble(), state['flow']));
        perfSpots.add(FlSpot(i.toDouble(), state['perf']));
      }
    }

    if (sessionLog.isNotEmpty) {
      final lastState = sessionLog.last['learner_state'];
      final perf = lastState != null ? lastState['perf'] as double : 0.5;

      if (perf < 0.2) finalLevel = "Very Easy";
      else if (perf < 0.4) finalLevel = "Easy";
      else if (perf < 0.6) finalLevel = "Medium";
      else if (perf < 0.8) finalLevel = "Hard";
      else finalLevel = "Very Hard";
    }
    void saveSession() async {
      double eng = 0, mot = 0, flow = 0, perf = 0, diff = 0;

      for (var e in sessionLog) {
        final s = e['learner_state'];
        eng += s['eng'];
        mot += s['mot'];
        flow += s['flow'];
        perf += s['perf'];

        String d = e['difficulty_after'];
        switch (d) {
          case "veryEasy": diff += 0.2; break;
          case "easy": diff += 0.4; break;
          case "medium": diff += 0.6; break;
          case "hard": diff += 0.8; break;
          case "veryHard": diff += 1.0; break;
        }
      }

      int count = sessionLog.length;

      final session = SessionModel(
        avgEng: eng / count,
        avgMot: mot / count,
        avgFlow: flow / count,
        avgPerf: perf / count,
        avgDifficulty: diff / count,
        questionsCount: count,
        timestamp: DateTime.now().toString(),
      );

      await DatabaseHelper.instance.insertSession(session);
    }

    saveSession();


    return Scaffold(
      appBar: AppBar(title: const Text("Adaptive Log & Progress")),
      body: Column(
        children: [
          Card(
            color: Colors.blue[100],
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Final User Level: $finalLevel",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 1,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 0.2,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, _) => Text('${value.toInt()+1}',style: TextStyle(fontSize: 8),),
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: engSpots,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: motSpots,
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: flowSpots,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: perfSpots,
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: sessionLog.length,
              itemBuilder: (context, index) {
                final e = sessionLog[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 12),
                  child: ListTile(
                    title: Text(
                        "Stage ${e['stage']} • Q${e['question_index']}: ${e['question']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Selected Option Index: ${e['selected_index']}"),
                        Text("Correct: ${e['correct']}"),
                        Text(
                            "Difficulty: ${e['difficulty_before']} → ${e['difficulty_after']}"),
                        Text(
                            "Learner State: Eng=${e['learner_state']['eng'].toStringAsFixed(2)}, "
                                "Mot=${e['learner_state']['mot'].toStringAsFixed(2)}, "
                                "Flow=${e['learner_state']['flow'].toStringAsFixed(2)}, "
                                "Perf=${e['learner_state']['perf'].toStringAsFixed(2)}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
