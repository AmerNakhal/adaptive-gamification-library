import 'package:adaptive_gamification_example/task_progression_demo/task_progression_demo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskProgressionDemoPage', () {
    testWidgets('renders task progression demo shell', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TaskProgressionDemoPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Task Progression Demo'), findsWidgets);
      expect(find.text('Task Progress'), findsOneWidget);
      expect(find.text('Task Progress Input'), findsOneWidget);
      expect(find.text('Runtime Output'), findsOneWidget);
      expect(find.text('Recommendation'), findsOneWidget);
      expect(find.text('Decision Trace'), findsOneWidget);
      expect(find.text('Analytics Snapshot'), findsOneWidget);
    });
  });
}