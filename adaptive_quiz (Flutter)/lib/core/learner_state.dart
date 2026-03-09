class LearnerState {
  double engagement;
  double motivation;
  double flow;
  double performance;
  LearnerState({
    this.engagement = 0.5,
    this.motivation = 0.5,
    this.flow = 0.5,
    this.performance = 0.5,
  });
  List<double> toList() => [engagement, motivation, flow, performance];
  void clampAll() {
    engagement = engagement.clamp(0.0, 1.0);
    motivation = motivation.clamp(0.0, 1.0);
    flow = flow.clamp(0.0, 1.0);
    performance = performance.clamp(0.0, 1.0);
  }
}