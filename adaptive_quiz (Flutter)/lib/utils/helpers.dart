enum Difficulty { veryEasy, easy, medium, hard, veryHard }

class Helpers {
  static Difficulty fromString(String s) {
    switch (s) {
      case "veryEasy":
        return Difficulty.veryEasy;
      case "easy":
        return Difficulty.easy;
      case "medium":
        return Difficulty.medium;
      case "hard":
        return Difficulty.hard;
      default:
        return Difficulty.veryHard;
    }
  }

  static String toStringDiff(Difficulty d) => d.name;

  static double difficultyToProgress(Difficulty d) {
    return (d.index + 1) / 5.0;
  }

  static Difficulty increase(Difficulty d) {
    if (d.index < 4) return Difficulty.values[d.index + 1];
    return d;
  }

  static Difficulty decrease(Difficulty d) {
    if (d.index > 0) return Difficulty.values[d.index - 1];
    return d;
  }
}
