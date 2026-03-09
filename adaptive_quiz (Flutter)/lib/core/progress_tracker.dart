import 'learner_state.dart';

class ProgressTracker {
  static void updateState(LearnerState state, bool correct, int timeTaken) {
    if (correct) {
      state.performance += 0.06;
      state.flow += 0.04;
      state.engagement += 0.03;
      state.motivation += 0.02;
    } else {
      state.motivation -= 0.05;
      state.engagement -= 0.02;
    }
    if (timeTaken <= 5) state.flow += 0.03;
    else if (timeTaken >= 15) state.engagement -= 0.02;
    state.clampAll();
  }
}