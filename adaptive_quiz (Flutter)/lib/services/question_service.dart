import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question_model.dart';

class QuestionService {
  late List<QuestionModel> _all;
  final Set<int> _used = {};

  Future<void> init() async {
    final String jsonString = await rootBundle.loadString('assets/data/questions.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _all = jsonList
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    _validateDifficulties();
  }

  QuestionModel getByDifficulty(String difficulty) {
    final filtered = _all
        .asMap()
        .entries
        .where((e) =>
    e.value.difficulty.toString().toLowerCase().contains(difficulty.toLowerCase()) &&
        !_used.contains(e.key))
        .toList();

    if (filtered.isEmpty) {
      _used.clear();
      return getByDifficulty(difficulty);
    }

    final entry = filtered.first;
    _used.add(entry.key);
    return entry.value;
  }

  void resetUsed() {
    _used.clear();
  }

  void _validateDifficulties() {
    const levels = ['veryEasy', 'easy', 'medium', 'hard', 'veryHard'];
    for (var l in levels) {
      if (!_all.any((q) => q.difficulty.toString().toLowerCase().contains(l.toLowerCase()))) {
        print("⚠ Warning: No questions found for difficulty $l");
      }
    }
  }

  List<QuestionModel> getAll() {
    return List<QuestionModel>.from(_all);
  }
}
