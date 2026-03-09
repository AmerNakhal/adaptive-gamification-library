import 'package:flutter/foundation.dart';

enum DifficultyLevel { veryEasy, easy, medium, hard, veryHard }

DifficultyLevel difficultyFromString(String s) {
  final key = s.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
  switch (key) {
    case 'veryeasy':
      return DifficultyLevel.veryEasy;
    case 'easy':
      return DifficultyLevel.easy;
    case 'medium':
      return DifficultyLevel.medium;
    case 'hard':
      return DifficultyLevel.hard;
    case 'veryhard':
      return DifficultyLevel.veryHard;
    default:
      return DifficultyLevel.easy;
  }
}

String difficultyToString(DifficultyLevel d) {
  switch (d) {
    case DifficultyLevel.veryEasy:
      return 'veryEasy';
    case DifficultyLevel.easy:
      return 'easy';
    case DifficultyLevel.medium:
      return 'medium';
    case DifficultyLevel.hard:
      return 'hard';
    case DifficultyLevel.veryHard:
      return 'veryHard';
  }
}

class QuestionModel {
  final int? id; // optional id if provided
  final String question;
  final List<String> options;
  final String? answer; // textual answer if provided
  final int? answerIndex; // index-based answer if provided
  final DifficultyLevel difficulty;

  QuestionModel({
    this.id,
    required this.question,
    required this.options,
    this.answer,
    this.answerIndex,
    required this.difficulty,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // id
    int? id;
    if (json.containsKey('id')) {
      final v = json['id'];
      if (v is int) id = v;
      else if (v is String) id = int.tryParse(v);
    }

    // question
    final String question = json['question']?.toString() ?? '';

    // options — accept 'options' or 'choices'
    List<String> options = [];
    if (json.containsKey('options')) {
      final raw = json['options'];
      if (raw is List) options = raw.map((e) => e.toString()).toList();
    } else if (json.containsKey('choices')) {
      final raw = json['choices'];
      if (raw is List) options = raw.map((e) => e.toString()).toList();
    }

    // answer textual
    String? answer;
    if (json.containsKey('answer')) {
      answer = json['answer']?.toString();
    } else if (json.containsKey('correct_answer')) {
      answer = json['correct_answer']?.toString();
    }

    // answer index (several possible key names)
    int? answerIndex;
    for (final key in ['answer_index', 'correctOption', 'correct_option', 'correctIndex']) {
      if (json.containsKey(key)) {
        final v = json[key];
        if (v is int) answerIndex = v;
        else if (v is String) answerIndex = int.tryParse(v);
        break;
      }
    }

    // difficulty: accept many formats
    String diffRaw = 'easy';
    if (json.containsKey('difficulty')) diffRaw = json['difficulty']?.toString() ?? 'easy';
    else if (json.containsKey('level')) diffRaw = json['level']?.toString() ?? 'easy';

    final difficulty = difficultyFromString(diffRaw);

    return QuestionModel(
      id: id,
      question: question,
      options: options,
      answer: answer,
      answerIndex: answerIndex,
      difficulty: difficulty,
    );
  }

  int? resolvedAnswerIndex() {
    if (answerIndex != null) return answerIndex;
    if (answer != null && options.isNotEmpty) {
      final idx = options.indexWhere((opt) => opt.trim().toLowerCase() == answer!.trim().toLowerCase());
      if (idx != -1) return idx;
    }
    return null;
  }

  bool isSelectedIndexCorrect(int selectedIndex) {
    final idx = resolvedAnswerIndex();
    if (idx != null) return idx == selectedIndex;
    // if cannot resolve index, fall back to comparing the option string with answer
    if (selectedIndex >= 0 && selectedIndex < options.length && answer != null) {
      return options[selectedIndex].trim().toLowerCase() == answer!.trim().toLowerCase();
    }
    return false;
  }

  bool isSelectedTextCorrect(String selectedText) {
    if (answer != null) {
      return selectedText.trim().toLowerCase() == answer!.trim().toLowerCase();
    }
    final idx = resolvedAnswerIndex();
    if (idx != null && idx >= 0 && idx < options.length) {
      return options[idx].trim().toLowerCase() == selectedText.trim().toLowerCase();
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'question': question,
      'options': options,
      if (answer != null) 'answer': answer,
      if (answerIndex != null) 'answer_index': answerIndex,
      'difficulty': difficultyToString(difficulty),
    };
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, difficulty: ${difficultyToString(difficulty)}, question: $question, options: $options, answer: $answer, answerIndex: $answerIndex)';
  }
}
