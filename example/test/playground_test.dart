import 'package:adaptive_gamification_example/playground/playground_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaygroundPage', () {
    testWidgets('renders playground shell', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlaygroundPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Playground'), findsWidgets);
      expect(find.text('Manual State Input'), findsOneWidget);
      expect(find.text('Runtime Output'), findsOneWidget);
      expect(find.text('Recommendation'), findsOneWidget);
      expect(find.text('Decision Trace'), findsOneWidget);
      expect(find.text('Analytics Snapshot'), findsOneWidget);
      expect(find.text('Run Playground'), findsOneWidget);
    });
  });
}