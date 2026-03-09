enum Difficulty { veryEasy, easy, medium, hard, veryHard }
class DifficultyMapper {
  static Difficulty mapActionToDifficulty(int action) {
    switch (action) {
      case 0: return Difficulty.veryEasy;
      case 1: return Difficulty.easy;
      case 2: return Difficulty.medium;
      case 3: return Difficulty.hard;
      case 4: return Difficulty.veryHard;
      default: return Difficulty.medium;
    }
  }
  static String difficultyName(Difficulty d) {
    switch (d) {
      case Difficulty.veryEasy: return 'very_easy';
      case Difficulty.easy: return 'easy';
      case Difficulty.medium: return 'medium';
      case Difficulty.hard: return 'hard';
      case Difficulty.veryHard: return 'very_hard';
    }
  }
}