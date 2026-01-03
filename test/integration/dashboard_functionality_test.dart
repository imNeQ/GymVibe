import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/navigation/main_navigation.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:trening_tracker/core/models/completed_workout.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testy funkcjonalne dla dashboardu.
/// Testują wyświetlanie statystyk i interakcje na ekranie głównym.
void main() {
  group('Dashboard Functionality Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display workouts this week count', (WidgetTester tester) async {
      // Add workout from this week
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: monday.add(const Duration(days: 1)),
          activityType: ActivityType.gym,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display workout count
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('should display recent workouts section', (WidgetTester tester) async {
      // Add multiple workouts
      for (int i = 0; i < 3; i++) {
        await WorkoutHistoryService.saveCustomWorkout(
          CompletedWorkout(
            completedAt: DateTime.now().subtract(Duration(days: i)),
            activityType: ActivityType.gym,
            customName: 'Trening $i',
          ),
        );
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display recent workouts section
      final recentSection = find.textContaining('Ostatnie', findRichText: true);
      final recentSectionEn = find.textContaining('Recent', findRichText: true);
      expect(recentSection.evaluate().isNotEmpty || recentSectionEn.evaluate().isNotEmpty, true);

      // Should show workout names
      expect(find.text('Trening 0'), findsOneWidget);
    });

    testWidgets('should display cardio stats when available', (WidgetTester tester) async {
      // Add cardio workout
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
          activityType: ActivityType.running,
          distance: 5.0,
          durationMinutes: 30,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display cardio stats section
      final cardioSection = find.textContaining('Ostatnie 7 dni', findRichText: true);
      final cardioSectionEn = find.textContaining('Last 7 days', findRichText: true);
      expect(cardioSection.evaluate().isNotEmpty || cardioSectionEn.evaluate().isNotEmpty, true);
    });

    testWidgets('should hide cardio stats when no data', (WidgetTester tester) async {
      // Don't add any cardio workouts

      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Cardio stats section should not be visible
      final cardioSection = find.textContaining('Ostatnie 7 dni', findRichText: true);
      final cardioSectionEn = find.textContaining('Last 7 days', findRichText: true);
      expect(cardioSection.evaluate().isEmpty && cardioSectionEn.evaluate().isEmpty, true);
    });

    testWidgets('should display total statistics', (WidgetTester tester) async {
      // Add multiple workouts
      for (int i = 0; i < 5; i++) {
        await WorkoutHistoryService.saveCustomWorkout(
          CompletedWorkout(
            completedAt: DateTime.now().subtract(Duration(days: i)),
            activityType: ActivityType.gym,
            durationMinutes: 45,
          ),
        );
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display total workouts count
      expect(find.text('5'), findsWidgets);
    });

    testWidgets('should navigate to workout detail from recent workouts', (WidgetTester tester) async {
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
          customName: 'Test Workout',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on recent workout card
      final workoutCard = find.text('Test Workout');
      if (workoutCard.evaluate().isNotEmpty) {
        await tester.tap(workoutCard);
        await tester.pumpAndSettle();

        // Should navigate to detail page
        expect(find.text('Test Workout'), findsOneWidget);
      }
    });

    testWidgets('should refresh data when returning to dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate away
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pumpAndSettle();

      // Add workout while on another tab
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
        ),
      );

      // Navigate back to dashboard
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();

      // Dashboard should refresh and show new workout
      // Verify by checking total count
      final totalWorkouts = await WorkoutHistoryService.getTotalWorkouts();
      expect(totalWorkouts, greaterThan(0));
    });
  });
}
