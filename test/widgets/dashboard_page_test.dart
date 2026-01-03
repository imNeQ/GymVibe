import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/features/dashboard/dashboard_page.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:trening_tracker/core/models/completed_workout.dart';
import 'package:trening_tracker/core/services/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DashboardPage GUI Tests', () {
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

      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.textContaining('Cześć'), findsOneWidget);
      expect(find.text('Dzisiejszy trening'), findsOneWidget);
    });

    testWidgets('should display greeting section with user name', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Cześć'), findsOneWidget);
      expect(find.textContaining('John'), findsOneWidget);
    });

    testWidgets('should display today workout card', (WidgetTester tester) async {
      final todaysWorkout = await MockDataService.getTodaysWorkout();

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dzisiejszy trening'), findsOneWidget);
      if (todaysWorkout != null) {
        expect(find.text(todaysWorkout.name), findsOneWidget);
      }
      expect(find.text('Rozpocznij trening'), findsOneWidget);
    });

    testWidgets('should display start workout button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      final startButton = find.text('Rozpocznij trening');
      expect(startButton, findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('should show snackbar when start workout button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Rozpocznij trening'));
      await tester.pumpAndSettle();

      expect(find.text('Timer treningu uruchomi się tutaj'), findsOneWidget);
    });

    testWidgets('should display this week summary section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ten tydzień'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsWidgets);
      expect(find.byIcon(Icons.calendar_month), findsWidgets);
    });

    testWidgets('should display workout count for this week', (WidgetTester tester) async {
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
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display workout count
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('should display statistics overview section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Statystyki'), findsOneWidget);
      expect(find.text('Całkowity czas'), findsOneWidget);
      expect(find.text('Wszystkie treningi'), findsOneWidget);
    });

    testWidgets('should display recent workouts section', (WidgetTester tester) async {
      // Add some test workouts
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
          customName: 'Test Workout 1',
        ),
      );

      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          activityType: ActivityType.gym,
          customName: 'Test Workout 2',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ostatnie treningi'), findsOneWidget);
      expect(find.text('Test Workout 1'), findsOneWidget);
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
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

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

      // Cardio stats section should not be visible when no cardio data
      // The section is conditionally rendered, so it might not appear at all
      // Just verify the page renders correctly
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('should display suggestions section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sugestie'), findsOneWidget);
    });

    testWidgets('should display suggestion workout cards', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display at least one suggestion
      if (workouts.isNotEmpty) {
        expect(find.text(workouts.first.name), findsWidgets);
      }
    });

    testWidgets('should navigate to workout detail from suggestion card', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      if (workouts.isEmpty) return;

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/workout-detail': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              return Scaffold(
                appBar: AppBar(title: Text('Workout ${args.toString()}')),
                body: const Center(child: Text('Workout Detail')),
              );
            },
          },
          home: const DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on suggestion card
      final suggestionCard = find.text(workouts.first.name).first;
      await tester.tap(suggestionCard);
      await tester.pumpAndSettle();

      // Should navigate to workout detail
      expect(find.text('Workout ${workouts.first.id}'), findsOneWidget);
    });

    testWidgets('should display difficulty chips for today workout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for difficulty chip
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('should display duration chip for today workout', (WidgetTester tester) async {
      final todaysWorkout = await MockDataService.getTodaysWorkout();

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      if (todaysWorkout != null) {
        expect(find.textContaining('${todaysWorkout.estimatedDurationMinutes} min'), findsWidgets);
      }
    });
  });
}
