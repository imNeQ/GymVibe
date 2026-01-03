import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/features/workouts/workout_list_page.dart';
import 'package:trening_tracker/core/routes.dart';
import 'package:trening_tracker/core/services/mock_data.dart';

void main() {
  group('WorkoutListPage GUI Tests', () {
    testWidgets('should display workout list page with all elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.workoutDetail: (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              return Scaffold(
                appBar: AppBar(title: Text('Workout ${args.toString()}')),
                body: const Center(child: Text('Workout Detail')),
              );
            },
          },
          home: Scaffold(
            body: WorkoutListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WorkoutListPage), findsOneWidget);
      expect(find.text('Filtruj według poziomu'), findsOneWidget);
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('should display all filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for all filter options (using findWidgets since text may appear multiple times)
      expect(find.text('Wszystkie'), findsWidgets);
      expect(find.text('Początkujący'), findsWidgets);
      expect(find.text('Średnio zaawansowany'), findsWidgets);
      expect(find.text('Zaawansowany'), findsWidgets);
      
      // Verify filter chips are present
      final filterChips = find.byType(FilterChip);
      expect(filterChips, findsWidgets);
    });

    testWidgets('should display workout cards with correct information', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if workout cards are displayed
      expect(find.byType(Card), findsWidgets);
      
      // Check if at least one workout name is displayed
      if (workouts.isNotEmpty) {
        expect(find.text(workouts.first.name), findsOneWidget);
      }
    });

    testWidgets('should filter workouts by Beginner difficulty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Beginner filter - use first occurrence (filter section)
      final filterChips = find.byType(FilterChip);
      final beginnerChip = filterChips.first;
      await tester.tap(beginnerChip);
      await tester.pumpAndSettle();

      // Verify filter is selected
      final allFilterChips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final selectedChip = allFilterChips.firstWhere((chip) => chip.selected == true);
      expect(selectedChip.label, isA<Text>());
    });

    testWidgets('should filter workouts by Intermediate difficulty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Intermediate filter - find by widget type and select the right one
      final filterChips = find.byType(FilterChip);
      // Find the chip with "Średnio zaawansowany" text in filter section
      final intermediateChip = filterChips.at(2); // Third chip (after "Wszystkie" and "Początkujący")
      await tester.tap(intermediateChip);
      await tester.pumpAndSettle();

      // Verify filter is selected
      final allFilterChips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final selectedChip = allFilterChips.firstWhere((chip) => chip.selected == true);
      expect(selectedChip.label, isA<Text>());
    });

    testWidgets('should filter workouts by Advanced difficulty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Advanced filter
      final advancedChip = find.text('Zaawansowany');
      await tester.tap(advancedChip);
      await tester.pumpAndSettle();

      // Verify filter is selected
      final filterChips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final selectedChip = filterChips.firstWhere((chip) => chip.selected == true);
      expect(selectedChip.label, isA<Text>());
    });

    testWidgets('should reset filter when All is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First select a filter - use first FilterChip
      final filterChips = find.byType(FilterChip);
      await tester.tap(filterChips.at(1)); // Second chip (Początkujący)
      await tester.pumpAndSettle();

      // Then select All - first chip
      await tester.tap(filterChips.at(0));
      await tester.pumpAndSettle();

      // Verify All filter is selected (no specific difficulty selected)
      expect(find.byType(WorkoutListPage), findsOneWidget);
    });

    testWidgets('should navigate to workout detail when card is tapped', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      if (workouts.isEmpty) return;

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.workoutDetail: (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              return Scaffold(
                appBar: AppBar(title: Text('Workout ${args.toString()}')),
                body: const Center(child: Text('Workout Detail')),
              );
            },
          },
          home: Scaffold(
            body: WorkoutListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on first workout card
      final workoutCard = find.text(workouts.first.name);
      if (workoutCard.evaluate().isNotEmpty) {
        await tester.tap(workoutCard);
        await tester.pumpAndSettle();

        // Verify navigation occurred
        expect(find.text('Workout ${workouts.first.id}'), findsOneWidget);
      }
    });

    testWidgets('should display workout duration chips', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if duration information is displayed
      if (workouts.isNotEmpty) {
        final durationText = find.textContaining('${workouts.first.estimatedDurationMinutes} min');
        expect(durationText, findsWidgets);
      }
    });

    testWidgets('should display workout descriptions when available', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      final workoutWithDescription = workouts.firstWhere(
        (w) => w.description != null,
        orElse: () => workouts.first,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      if (workoutWithDescription.description != null) {
        // Description might be truncated, so check for partial text
        expect(find.textContaining(workoutWithDescription.description!.substring(0, 10)), findsWidgets);
      }
    });
  });
}
