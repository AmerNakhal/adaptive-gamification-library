import 'dart:convert';
import 'package:flutter/services.dart';

class PolicyService {
  List<Map<String, dynamic>> policy = [];
  List<Map<String, dynamic>> sessionLog = [];

  double perf = 0.5;

  Future<void> init() async {
    final data = await rootBundle.loadString('assets/data/adaptive_policy.json');
    policy = List<Map<String, dynamic>>.from(json.decode(data));  // تحميل الـ JSON كـ List
  }

  String nextDifficulty(bool correct) {
    double before = perf;

    if (correct) {
      perf += 0.1;
    } else {
      perf -= 0.1;
    }

    perf = perf.clamp(0.0, 1.0);

    String diff;
    if (perf < 0.2) diff = "veryEasy";
    else if (perf < 0.4) diff = "easy";
    else if (perf < 0.6) diff = "medium";
    else if (perf < 0.8) diff = "hard";
    else diff = "veryHard";

    sessionLog.add({
      "before": before,
      "after": perf,
      "correct": correct,
      "difficulty": diff
    });

    return diff;
  }
}
