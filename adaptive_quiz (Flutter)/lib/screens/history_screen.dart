import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_helper.dart';
import '../models/session_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SessionModel> sessions = [];

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    sessions = await DatabaseHelper.instance.getAllSessions();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> perfSpots = [];
    List<FlSpot> diffSpots = [];

    for (int i = 0; i < sessions.length; i++) {
      perfSpots.add(FlSpot(i.toDouble(), sessions[i].avgPerf));
      diffSpots.add(FlSpot(i.toDouble(), sessions[i].avgDifficulty));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("User Progress History")),
      body: sessions.isEmpty
          ? const Center(child: Text("No sessions recorded yet"))
          : Column(
        children: [
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: perfSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                  ),
                  LineChartBarData(
                    spots: diffSpots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final s = sessions[index];
                return ListTile(
                  title: Text("Session ${index + 1}"),
                  subtitle: Text(
                      "Perf: ${s.avgPerf.toStringAsFixed(2)} | Diff: ${s.avgDifficulty.toStringAsFixed(2)}"),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
