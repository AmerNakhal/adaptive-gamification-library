import 'package:adaptive_gamification_example/quiz_demo/quiz_demo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizDemoPage', () {
    testWidgets('renders quiz demo shell', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizDemoPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Quiz Demo'), findsWidgets);
      expect(find.text('Quiz Progress'), findsOneWidget);
      expect(find.text('Question Interaction'), findsOneWidget);
      expect(find.text('Runtime Output'), findsOneWidget);
      expect(find.text('Recommendation'), findsOneWidget);
      expect(find.text('Decision Trace'), findsOneWidget);
      expect(find.text('Analytics Snapshot'), findsOneWidget);
    });
  });
}