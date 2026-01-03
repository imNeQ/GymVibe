import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/features/plans/plan_page.dart';

void main() {
  group('PlanPage Widget Tests', () {
    testWidgets('should display plan page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlanPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PlanPage), findsOneWidget);
    });

    testWidgets('should display edit button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlanPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Check if edit button is present
      final editFinder = find.textContaining('Edytuj', findRichText: true);
      final editFinderEn = find.textContaining('Edit', findRichText: true);
      expect(editFinder.evaluate().isNotEmpty || editFinderEn.evaluate().isNotEmpty, true);
    });

    testWidgets('should display weekly schedule cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlanPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display cards for each day of the week
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should display day names', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlanPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Check if at least one day name is displayed
      final mondayFinder = find.textContaining('Poniedziałek', findRichText: true);
      final mondayFinderEn = find.textContaining('Monday', findRichText: true);
      expect(mondayFinder.evaluate().isNotEmpty || mondayFinderEn.evaluate().isNotEmpty, true);
    });

    testWidgets('should show snackbar when edit button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlanPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap edit button
      final editButton = find.textContaining('Edytuj', findRichText: true);
      if (editButton.evaluate().isEmpty) {
        final editButtonEn = find.textContaining('Edit', findRichText: true);
        await tester.tap(editButtonEn.first);
      } else {
        await tester.tap(editButton.first);
      }
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
