import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/features/workouts/workout_history_list_page.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:trening_tracker/core/models/completed_workout.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WorkoutHistoryListPage Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display empty state when no workouts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutHistoryListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Check if empty state message is displayed
      final emptyFinder = find.textContaining('Brak treningów', findRichText: true);
      final emptyFinderEn = find.textContaining('No workouts', findRichText: true);
      expect(emptyFinder.evaluate().isNotEmpty || emptyFinderEn.evaluate().isNotEmpty, true);
    });

    testWidgets('should display list of workouts', (WidgetTester tester) async {
      // Add test workouts
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
        ),
      );
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          activityType: ActivityType.running,
          distance: 5.0,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutHistoryListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display workout cards
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should display page title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutHistoryListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Check if page title is displayed
      final historyFinder = find.textContaining('Historia', findRichText: true);
      final historyFinderEn = find.textContaining('History', findRichText: true);
      expect(historyFinder.evaluate().isNotEmpty || historyFinderEn.evaluate().isNotEmpty, true);
    });
  });
}
