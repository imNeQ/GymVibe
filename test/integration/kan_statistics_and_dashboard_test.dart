import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/navigation/main_navigation.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:trening_tracker/core/models/completed_workout.dart';
import 'package:trening_tracker/core/models/strength_exercise.dart';
import 'package:trening_tracker/core/models/exercise_set.dart';
import 'package:trening_tracker/features/dashboard/dashboard_page.dart';
import 'package:trening_tracker/features/statistics/exercise_progress_page.dart';
import 'package:trening_tracker/features/workouts/add_workout_history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testy dla funkcjonalności statystyk i dashboardu (KAN-23, KAN-24, KAN-25, KAN-26, KAN-27, KAN-28)
void main() {
  group('KAN-23: Podstawowy licznik treningów', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display workout count on dashboard', (WidgetTester tester) async {
      // Add workouts
      for (int i = 0; i < 3; i++) {
        await WorkoutHistoryService.saveCustomWorkout(
          CompletedWorkout(
            completedAt: DateTime.now().subtract(Duration(days: i)),
            activityType: ActivityType.gym,
          ),
        );
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify workout count is displayed
      expect(find.text('3'), findsWidgets); // Should appear in stats
    });

    testWidgets('should count workouts this week', (WidgetTester tester) async {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));

      // Add workout from this week
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: monday.add(const Duration(days: 1)),
          activityType: ActivityType.gym,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify this week count
      expect(find.text('1'), findsWidgets);
    });
  });

  group('KAN-24: Prosty przegląd ostatnich wyników', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display recent workouts section', (WidgetTester tester) async {
      // Add multiple workouts
      for (int i = 0; i < 3; i++) {
        await WorkoutHistoryService.saveCustomWorkout(
          CompletedWorkout(
            completedAt: DateTime.now().subtract(Duration(days: i)),
            activityType: ActivityType.gym,
            customName: 'Trening ${i + 1}',
          ),
        );
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ostatnie treningi'), findsOneWidget);
      expect(find.text('Trening 1'), findsOneWidget);
    });

    testWidgets('should display empty state when no recent workouts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ostatnie treningi'), findsOneWidget);
      expect(find.textContaining('Brak ukończonych treningów'), findsOneWidget);
    });
  });

  group('KAN-25: Progres wybranego ćwiczenia', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display exercise progress page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseProgressPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ExerciseProgressPage), findsOneWidget);
      expect(find.text('Progres ćwiczenia'), findsOneWidget);
    });

    testWidgets('should display empty state when no strength exercises', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseProgressPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Brak ćwiczeń siłowych w historii'), findsOneWidget);
    });

    testWidgets('should display list of exercises when available', (WidgetTester tester) async {
      // Add workout with strength exercises
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
          strengthExercises: [
            StrengthExercise(
              name: 'Przysiad',
              sets: [
                ExerciseSet(weight: 100.0, reps: 10),
              ],
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseProgressPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display exercise name
      expect(find.text('Przysiad'), findsOneWidget);
    });

    testWidgets('should navigate to exercise detail when tapped', (WidgetTester tester) async {
      // Add workout with strength exercise
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
          strengthExercises: [
            StrengthExercise(
              name: 'Przysiad',
              sets: [
                ExerciseSet(weight: 100.0, reps: 10),
              ],
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseProgressPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on exercise
      await tester.tap(find.text('Przysiad'));
      await tester.pumpAndSettle();

      // Should navigate to detail page
      expect(find.text('Przysiad'), findsWidgets); // Should be in app bar
    });
  });

  group('KAN-26: Suma dystansu / czasu (card na dashboardzie)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display cardio stats card when data available', (WidgetTester tester) async {
      // Add cardio workouts
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
          activityType: ActivityType.running,
          distance: 5.0,
          durationMinutes: 30,
        ),
      );

      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          activityType: ActivityType.cycling,
          distance: 20.0,
          durationMinutes: 60,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify cardio stats section is displayed
      expect(find.text('Ostatnie 7 dni'), findsOneWidget);
      expect(find.text('Dystans [km]'), findsOneWidget);
      expect(find.text('Czas [min]'), findsOneWidget);
    });

    testWidgets('should hide cardio stats when no data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Cardio stats should not be visible
      expect(find.text('Ostatnie 7 dni'), findsNothing);
    });
  });

  group('KAN-27: Ekran główny (dashboard)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display dashboard with all sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all main sections
      expect(find.textContaining('Cześć'), findsOneWidget);
      expect(find.text('Dzisiejszy trening'), findsOneWidget);
      expect(find.text('Ten tydzień'), findsOneWidget);
      expect(find.text('Statystyki'), findsOneWidget);
      expect(find.text('Ostatnie treningi'), findsOneWidget);
      expect(find.text('Sugestie'), findsOneWidget);
    });

    testWidgets('should display today workout card', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dzisiejszy trening'), findsOneWidget);
      expect(find.text('Rozpocznij trening'), findsOneWidget);
    });
  });

  group('KAN-28: Szybkie dodanie treningu z dashboardu', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display FAB on dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // FAB should be visible on dashboard
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should open add workout page when FAB is tapped', (WidgetTester tester) async {
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
      expect(find.byType(AddWorkoutHistoryPage), findsOneWidget);
      expect(find.text('Dodaj trening do historii'), findsOneWidget);
    });

    testWidgets('should hide FAB on other tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to another tab
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pumpAndSettle();

      // FAB should not be visible
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
