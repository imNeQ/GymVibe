import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/navigation/main_navigation.dart';
import 'package:trening_tracker/features/dashboard/dashboard_page.dart';
import 'package:trening_tracker/features/workouts/workout_list_page.dart';
import 'package:trening_tracker/features/plans/plan_page.dart';
import 'package:trening_tracker/features/statistics/statistics_page.dart';
import 'package:trening_tracker/features/profile/profile_page.dart';

/// Testy funkcjonalne dla nawigacji między ekranami.
/// Testują pełne przepływy użytkownika związane z nawigacją.
void main() {
  group('Navigation Integration Tests', () {
    testWidgets('should navigate between all tabs using bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dashboard is initially displayed
      expect(find.byType(DashboardPage), findsOneWidget);

      // Navigate to Workouts tab
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutListPage), findsOneWidget);

      // Navigate to Plan tab
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(PlanPage), findsOneWidget);

      // Navigate to Statistics tab
      await tester.tap(find.byIcon(Icons.bar_chart_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(StatisticsPage), findsOneWidget);

      // Navigate to Profile tab
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);

      // Navigate back to Dashboard
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('should show FloatingActionButton only on dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // FAB should be visible on dashboard
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Navigate to another tab
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pumpAndSettle();

      // FAB should not be visible on other tabs
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should update app bar title when switching tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Check initial title
      expect(find.text('GymVibe'), findsOneWidget);

      // Navigate to Workouts
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pumpAndSettle();
      
      // Title should change (check for workouts text)
      final workoutsTitle = find.textContaining('Treningi', findRichText: true);
      final workoutsTitleEn = find.textContaining('Workouts', findRichText: true);
      expect(workoutsTitle.evaluate().isNotEmpty || workoutsTitleEn.evaluate().isNotEmpty, true);
    });

    testWidgets('should open AddWorkoutHistoryPage when FAB is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should navigate to AddWorkoutHistoryPage
      // Check for form elements
      expect(find.byType(Form), findsOneWidget);
    });
  });
}
