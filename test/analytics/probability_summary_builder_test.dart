import 'package:adaptive_gamification/src/analytics/probability_summary_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProbabilitySummaryBuilder', () {
    const builder = ProbabilitySummaryBuilder();

    test('build returns expected summary for non-empty probabilities', () {
      final summary = builder.build(<double>[0.1, 0.2, 0.7]);

      expect(summary['count'], 3);
      expect(summary['sum'], closeTo(1.0, 1e-9));
      expect(summary['mean'], closeTo((0.1 + 0.2 + 0.7) / 3, 1e-9));
      expect(summary['min'], 0.1);
      expect(summary['max'], 0.7);
      expect(summary['argMaxIndex'], 2);
      expect(summary['argMaxValue'], 0.7);
      expect(summary['isEmpty'], isFalse);
      expect(summary['isNormalizedDistribution'], isTrue);
    });

    test('build returns expected summary for non-normalized probabilities', () {
      final summary = builder.build(<double>[2.0, 3.0, 5.0]);

      expect(summary['count'], 3);
      expect(summary['sum'], closeTo(10.0, 1e-9));
      expect(summary['mean'], closeTo(10.0 / 3.0, 1e-9));
      expect(summary['min'], 2.0);
      expect(summary['max'], 5.0);
      expect(summary['argMaxIndex'], 2);
      expect(summary['argMaxValue'], 5.0);
      expect(summary['isEmpty'], isFalse);
      expect(summary['isNormalizedDistribution'], isFalse);
    });

    test('build returns expected summary for empty probabilities', () {
      final summary = builder.build(const <double>[]);

      expect(summary['count'], 0);
      expect(summary['sum'], 0.0);
      expect(summary['mean'], isNull);
      expect(summary['min'], isNull);
      expect(summary['max'], isNull);
      expect(summary['argMaxIndex'], isNull);
      expect(summary['argMaxValue'], isNull);
      expect(summary['isEmpty'], isTrue);
      expect(summary['isNormalizedDistribution'], isFalse);
    });

    test('build handles single-element probabilities', () {
      final summary = builder.build(<double>[1.0]);

      expect(summary['count'], 1);
      expect(summary['sum'], 1.0);
      expect(summary['mean'], 1.0);
      expect(summary['min'], 1.0);
      expect(summary['max'], 1.0);
      expect(summary['argMaxIndex'], 0);
      expect(summary['argMaxValue'], 1.0);
      expect(summary['isEmpty'], isFalse);
      expect(summary['isNormalizedDistribution'], isTrue);
    });

    test('buildLabeled adds argMaxLabel and labeledProbabilities when labels match',
            () {
          final summary = builder.buildLabeled(
            <double>[0.05, 0.15, 0.80],
            labels: const <String>['rest', 'easy_task', 'hard_task'],
          );

          expect(summary['count'], 3);
          expect(summary['argMaxIndex'], 2);
          expect(summary['argMaxValue'], 0.80);
          expect(summary['argMaxLabel'], 'hard_task');

          final labeled = summary['labeledProbabilities'];
          expect(labeled, isA<List<Map<String, dynamic>>>());
          expect((labeled as List).length, 3);

          expect(labeled[0]['index'], 0);
          expect(labeled[0]['label'], 'rest');
          expect(labeled[0]['value'], 0.05);

          expect(labeled[2]['index'], 2);
          expect(labeled[2]['label'], 'hard_task');
          expect(labeled[2]['value'], 0.80);
        });

    test('buildLabeled returns null argMaxLabel and empty labeledProbabilities when labels are missing',
            () {
          final summary = builder.buildLabeled(<double>[0.2, 0.8]);

          expect(summary['count'], 2);
          expect(summary['argMaxIndex'], 1);
          expect(summary['argMaxLabel'], isNull);
          expect(summary['labeledProbabilities'], isEmpty);
        });

    test('buildLabeled returns null argMaxLabel and empty labeledProbabilities when labels length mismatches',
            () {
          final summary = builder.buildLabeled(
            <double>[0.2, 0.8],
            labels: const <String>['only_one_label'],
          );

          expect(summary['count'], 2);
          expect(summary['argMaxIndex'], 1);
          expect(summary['argMaxLabel'], isNull);
          expect(summary['labeledProbabilities'], isEmpty);
        });

    test('buildLabeled handles empty probabilities safely', () {
      final summary = builder.buildLabeled(
        const <double>[],
        labels: const <String>['a', 'b'],
      );

      expect(summary['count'], 0);
      expect(summary['argMaxLabel'], isNull);
      expect(summary['labeledProbabilities'], isEmpty);
      expect(summary['isEmpty'], isTrue);
    });

    test('build uses first maximum index when values tie', () {
      final summary = builder.build(<double>[0.5, 0.5, 0.2]);

      expect(summary['argMaxIndex'], 0);
      expect(summary['argMaxValue'], 0.5);
    });

    test('toString returns readable type name', () {
      expect(
        builder.toString(),
        contains('ProbabilitySummaryBuilder'),
      );
    });

    test('equality works for identical builders', () {
      const a = ProbabilitySummaryBuilder();
      const b = ProbabilitySummaryBuilder();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}