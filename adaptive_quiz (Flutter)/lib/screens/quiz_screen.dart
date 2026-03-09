import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';
import '../services/policy_service.dart';
import '../utils/helpers.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuestionService _questionService = QuestionService();
  final PolicyService _policyService = PolicyService();

  QuestionModel? currentQuestion;

  int stage = 1;
  int questionIndex = 0;
  int correctInStage = 0;

  final int questionsPerStage = 5;
  final int totalStages = 5;

  String currentDifficulty = "veryEasy";

  Map<String, double> learnerState = {
    "eng": 0.5,
    "mot": 0.5,
    "flow": 0.5,
    "perf": 0.5,
  };

  List<Map<String, dynamic>> sessionLog = [];

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  Future<void> _initQuiz() async {
    await _questionService.init();
    await _policyService.init();
    _loadNextQuestion();
  }

  void _loadNextQuestion() {
    currentQuestion =
        _questionService.getByDifficulty(currentDifficulty);
    setState(() {});
  }

  void _onAnswerSelected(int selectedIndex) {
    if (currentQuestion == null) return;

    bool isCorrect =
    currentQuestion!.isSelectedIndexCorrect(selectedIndex);

    learnerState = _updateLearnerState(learnerState, isCorrect);

    currentDifficulty = _policyService.nextDifficulty(isCorrect);

    // تسجيل الإجابة والتكيّف
    sessionLog.add({
      "stage": stage,
      "question_index": questionIndex + 1,
      "question": currentQuestion!.question,
      "selected_index": selectedIndex,
      "correct": isCorrect,
      "difficulty_before": currentQuestion!.difficulty,
      "difficulty_after": currentDifficulty,
      "learner_state": Map<String, double>.from(learnerState),
    });

    if (isCorrect) correctInStage++;
    questionIndex++;

    if (questionIndex >= questionsPerStage) {
      _handleStageEnd();
    } else {
      _loadNextQuestion();
    }
  }

  void _handleStageEnd() {
    // ترقية مستوى الصعوبة بعد المرحلة حسب الأداء
    if (correctInStage == questionsPerStage) {
      currentDifficulty = Helpers.toStringDiff(
          Helpers.increase(Helpers.fromString(currentDifficulty)));
    } else if (correctInStage == 0) {
    }

    stage++;
    questionIndex = 0;
    correctInStage = 0;

    _questionService.resetUsed();

    if (stage > totalStages) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(sessionLog: sessionLog),
        ),
      );
    } else {
      _loadNextQuestion();
    }
  }

  Map<String, double> _updateLearnerState(
      Map<String, double> state, bool correct) {
    double delta = correct ? 0.05 : -0.05;
    return {
      "eng": (state["eng"]! + delta).clamp(0.0, 1.0),
      "mot": (state["mot"]! + delta).clamp(0.0, 1.0),
      "flow": (state["flow"]! + delta).clamp(0.0, 1.0),
      "perf": (state["perf"]! + delta).clamp(0.0, 1.0),
    };
  }

  Widget _buildAdaptiveLine() {
    double progress =
    Helpers.difficultyToProgress(Helpers.fromString(currentDifficulty));
    return Column(
      children: [
        const Text("Adaptive Level Progress"),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Stage $stage • Q ${questionIndex + 1}/$questionsPerStage"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAdaptiveLine(),
            const SizedBox(height: 20),
            Text(
              currentQuestion!.question,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 30),
            ...currentQuestion!.options.asMap().entries.map((entry) {
              int idx = entry.key;
              String opt = entry.value;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _onAnswerSelected(idx),
                  child: Text(opt, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
            const SizedBox(height: 30),
            Text(
              "Eng: ${learnerState['eng']!.toStringAsFixed(2)} | "
                  "Mot: ${learnerState['mot']!.toStringAsFixed(2)} | "
                  "Flow: ${learnerState['flow']!.toStringAsFixed(2)} | "
                  "Perf: ${learnerState['perf']!.toStringAsFixed(2)}",
            ),
          ],
        ),
      ),
    );
  }
}
