import '../utils/math_utils.dart';

/// Builds lightweight summaries for probability distributions.
///
/// This builder is useful for:
/// - analytics
/// - debugging
/// - trace enrichment
/// - developer-facing inspection of action distributions
class ProbabilitySummaryBuilder {
  /// Creates a probability summary builder.
  const ProbabilitySummaryBuilder();

  /// Builds a summary from [probabilities].
  ///
  /// The returned map contains:
  /// - `count`
  /// - `sum`
  /// - `mean`
  /// - `min`
  /// - `max`
  /// - `argMaxIndex`
  /// - `argMaxValue`
  /// - `isEmpty`
  /// - `isNormalizedDistribution`
  Map<String, dynamic> build(List<double> probabilities) {
    final immutable = List<double>.unmodifiable(probabilities);

    if (immutable.isEmpty) {
      return <String, dynamic>{
        'count': 0,
        'sum': 0.0,
        'mean': null,
        'min': null,
        'max': null,
        'argMaxIndex': null,
        'argMaxValue': null,
        'isEmpty': true,
        'isNormalizedDistribution': false,
      };
    }

    final sum = MathUtils.sum(immutable);
    final mean = MathUtils.mean(immutable);
    final min = MathUtils.minValue(immutable);
    final max = MathUtils.maxValue(immutable);
    final argMaxIndex = _argMaxIndex(immutable);
    final argMaxValue = immutable[argMaxIndex];
    final isNormalizedDistribution =
    MathUtils.approximatelyEqual(sum, 1.0, epsilon: 1e-6);

    return <String, dynamic>{
      'count': immutable.length,
      'sum': sum,
      'mean': mean,
      'min': min,
      'max': max,
      'argMaxIndex': argMaxIndex,
      'argMaxValue': argMaxValue,
      'isEmpty': false,
      'isNormalizedDistribution': isNormalizedDistribution,
    };
  }

  /// Builds a labeled probability summary from [probabilities].
  ///
  /// If [labels] is provided and has the same length as [probabilities],
  /// the returned map additionally contains:
  /// - `argMaxLabel`
  /// - `labeledProbabilities`
  ///
  /// If labels are missing or mismatched in length, unlabeled output is still
  /// returned safely.
  Map<String, dynamic> buildLabeled(
      List<double> probabilities, {
        List<String>? labels,
      }) {
    final summary = Map<String, dynamic>.from(build(probabilities));

    final immutableProbabilities = List<double>.unmodifiable(probabilities);
    final immutableLabels = labels == null
        ? null
        : List<String>.unmodifiable(labels);

    if (immutableProbabilities.isEmpty) {
      summary['argMaxLabel'] = null;
      summary['labeledProbabilities'] = const <Map<String, dynamic>>[];
      return Map<String, dynamic>.unmodifiable(summary);
    }

    if (immutableLabels == null ||
        immutableLabels.length != immutableProbabilities.length) {
      summary['argMaxLabel'] = null;
      summary['labeledProbabilities'] = const <Map<String, dynamic>>[];
      return Map<String, dynamic>.unmodifiable(summary);
    }

    final argMaxIndex = summary['argMaxIndex'] as int;
    summary['argMaxLabel'] = immutableLabels[argMaxIndex];

    final labeled = <Map<String, dynamic>>[];
    for (var i = 0; i < immutableProbabilities.length; i++) {
      labeled.add(<String, dynamic>{
        'index': i,
        'label': immutableLabels[i],
        'value': immutableProbabilities[i],
      });
    }

    summary['labeledProbabilities'] =
    List<Map<String, dynamic>>.unmodifiable(labeled);

    return Map<String, dynamic>.unmodifiable(summary);
  }

  int _argMaxIndex(List<double> values) {
    var bestIndex = 0;
    var bestValue = values[0];

    for (var i = 1; i < values.length; i++) {
      if (values[i] > bestValue) {
        bestValue = values[i];
        bestIndex = i;
      }
    }

    return bestIndex;
  }

  @override
  String toString() => 'ProbabilitySummaryBuilder()';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is ProbabilitySummaryBuilder;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}