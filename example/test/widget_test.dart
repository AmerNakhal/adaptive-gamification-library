import 'package:adaptive_gamification_example/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveGamificationExampleApp', () {
    testWidgets('renders home page shell', (tester) async {
      await tester.pumpWidget(const AdaptiveGamificationExampleApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Adaptive Gamification Library Example'), findsWidgets);
      expect(find.text('Quiz Demo'), findsOneWidget);
      expect(find.text('Task Progression Demo'), findsOneWidget);
      expect(find.text('Playground'), findsOneWidget);
      expect(find.text('Open example'), findsNWidgets(3));
    });
  });
}