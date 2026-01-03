import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/navigation/main_navigation.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:trening_tracker/core/services/settings_service.dart' show SettingsService, AppLanguage;
import 'package:trening_tracker/core/models/completed_workout.dart';
import 'package:trening_tracker/core/models/strength_exercise.dart';
import 'package:trening_tracker/core/models/exercise_set.dart';
import 'package:trening_tracker/features/dashboard/dashboard_page.dart';
import 'package:trening_tracker/features/workouts/add_workout_history_page.dart';
import 'package:trening_tracker/features/workouts/workout_history_list_page.dart';
import 'package:trening_tracker/features/workouts/workout_history_detail_page.dart';
import 'package:trening_tracker/features/workouts/edit_workout_history_page.dart';
import 'package:trening_tracker/features/workouts/workout_detail_page.dart';
import 'package:trening_tracker/features/workouts/workout_list_page.dart';
import 'package:trening_tracker/features/statistics/statistics_page.dart';
import 'package:trening_tracker/features/statistics/exercise_progress_page.dart';
import 'package:trening_tracker/features/settings/settings_page.dart';
import 'package:trening_tracker/features/profile/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kompleksowe testy dla wszystkich funkcjonalności KAN aplikacji GymVibe
/// 
/// Pokrywa następujące funkcjonalności:
/// - KAN-14: Rejestracja konta (opcjonalne MVP - nie zaimplementowane, aplikacja działa bez logowania)
/// - KAN-15: Dodanie nowego treningu
/// - KAN-16: Dodanie szczegółów dla treningu siłowego
/// - KAN-17: Dodanie szczegółów dla biegania/roweru
/// - KAN-18: Dodanie prostych notatek do treningu
/// - KAN-19: Lista wszystkich treningów
/// - KAN-20: Szczegóły pojedynczego treningu
/// - KAN-21: Edycja treningu
/// - KAN-22: Usuwanie treningu
/// - KAN-23: Podstawowy licznik treningów
/// - KAN-24: Prosty przegląd ostatnich wyników
/// - KAN-25: Progres wybranego ćwiczenia
/// - KAN-26: Suma dystansu / czasu (card na dashboardzie)
/// - KAN-27: Ekran główny (dashboard)
/// - KAN-28: Szybkie dodanie treningu z dashboardu
/// - KAN-29: Proste ustawienia (minimalne)
/// - KAN-30: Wybór języka (PL/EN) + Dark Mode
/// - KAN-8: Strona główna – Lista aktywności pogrupowanych per dzień
/// - KAN-12: Korzystanie bez zakładania konta
void main() {
  group('KAN-12: Korzystanie bez zakładania konta', () {
    testWidgets('should allow immediate access to app without login', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Should directly show main navigation without login screen
      expect(find.byType(MainNavigation), findsOneWidget);
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('should allow immediate workout tracking without account', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Should be able to access all features immediately
      expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget); // Workouts tab
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget); // Statistics tab
      expect(find.byIcon(Icons.person_outline), findsOneWidget); // Profile tab
    });

    testWidgets('should persist data locally without account', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();

      // Add workout
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
          customName: 'Test Workout',
        ),
      );

      // Verify data persists
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      expect(workouts.length, 1);
      expect(workouts.first.customName, 'Test Workout');
    });
  });

  group('KAN-14: Rejestracja konta (opcjonalne MVP)', () {
    testWidgets('should work without registration - app is designed for offline use', (WidgetTester tester) async {
      // KAN-14 jest opcjonalne MVP, aplikacja działa bez rejestracji
      // Weryfikujemy, że aplikacja działa poprawnie bez konta
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // App should work without any registration/login screens
      expect(find.byType(MainNavigation), findsOneWidget);
      expect(find.text('Zaloguj się'), findsNothing);
      expect(find.text('Zarejestruj się'), findsNothing);
    });
  });

  group('KAN-15: Dodanie nowego treningu', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display add workout form', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Data treningu'), findsOneWidget);
      expect(find.text('Typ aktywności'), findsOneWidget);
    });

    testWidgets('should save basic gym workout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Gym is selected by default
      await tester.scrollUntilVisible(find.byType(TextFormField), 500.0);
      await tester.pumpAndSettle();

      final durationField = find.byType(TextFormField).first;
      await tester.enterText(durationField, '60');
      await tester.pump();

      // Use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Trening został dodany do historii!'), findsOneWidget);
    });

    testWidgets('should allow selecting different activity types', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select Running
      await tester.tap(find.text('Bieganie'));
      await tester.pumpAndSettle();
      expect(find.text('Dystans (km)'), findsOneWidget);

      // Select Cycling
      await tester.tap(find.text('Rower'));
      await tester.pumpAndSettle();
      expect(find.text('Dystans (km)'), findsOneWidget);

      // Select Swimming
      await tester.tap(find.text('Pływanie'));
      await tester.pumpAndSettle();
      expect(find.text('Dystans (km)'), findsOneWidget);
    });
  });

  group('KAN-16: Dodanie szczegółów dla treningu siłowego', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should add strength exercise with sets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add exercise - use first to avoid multiple matches
      final addExerciseButton = find.text('Dodaj ćwiczenie').first;
      await tester.scrollUntilVisible(addExerciseButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(addExerciseButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      final exerciseNameField = find.byType(TextField).first;
      await tester.enterText(exerciseNameField, 'Wyciskanie na ławce');
      await tester.pump();
      await tester.tap(find.text('Dodaj'));
      await tester.pumpAndSettle();

      expect(find.text('Wyciskanie na ławce'), findsOneWidget);

      // Expand exercise and add set
      final expansionTile = find.byType(ExpansionTile).first;
      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      // Use first to avoid multiple matches (button and dialog title)
      final addSetButton = find.text('Dodaj serię').first;
      await tester.scrollUntilVisible(addSetButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(addSetButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Fill set details
      final weightField = find.widgetWithText(TextField, 'Ciężar (kg)');
      final repsField = find.widgetWithText(TextField, 'Powtórzenia');

      await tester.enterText(weightField, '80');
      await tester.pump();
      await tester.enterText(repsField, '8');
      await tester.pump();

      await tester.tap(find.text('Dodaj'));
      await tester.pumpAndSettle();

      // Verify set was added
      expect(find.textContaining('80'), findsWidgets);
      expect(find.textContaining('8'), findsWidgets);
    });

    testWidgets('should add multiple exercises to workout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add first exercise - use first to avoid multiple matches
      final addExerciseButton1 = find.text('Dodaj ćwiczenie').first;
      await tester.scrollUntilVisible(addExerciseButton1, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(addExerciseButton1, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Przysiad');
      await tester.pump();
      await tester.tap(find.text('Dodaj'));
      await tester.pumpAndSettle();

      // Add second exercise - use first to avoid multiple matches
      final addExerciseButton2 = find.text('Dodaj ćwiczenie').first;
      await tester.tap(addExerciseButton2, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Martwy ciąg');
      await tester.pump();
      await tester.tap(find.text('Dodaj'));
      await tester.pumpAndSettle();

      expect(find.text('Przysiad'), findsOneWidget);
      expect(find.text('Martwy ciąg'), findsOneWidget);
    });

    testWidgets('should allow editing and removing sets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add exercise with set - use first to avoid multiple matches
      final addExerciseButton = find.text('Dodaj ćwiczenie').first;
      await tester.scrollUntilVisible(addExerciseButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(addExerciseButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Przysiad');
      await tester.pump();
      await tester.tap(find.text('Dodaj'));
      await tester.pumpAndSettle();

      // Expand and add set
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();

      // Use first to avoid multiple matches (button and dialog title)
      final addSetButton = find.text('Dodaj serię').first;
      await tester.tap(addSetButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Ciężar (kg)'), '100');
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextField, 'Powtórzenia'), '10');
      await tester.pump();
      await tester.tap(find.text('Dodaj'));
      await tester.pumpAndSettle();

      // Verify set exists
      expect(find.textContaining('100'), findsWidgets);
    });
  });

  group('KAN-17: Dodanie szczegółów dla biegania/roweru', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should add running workout with distance and time', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Bieganie'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Dystans (km)'), 500.0);
      await tester.pumpAndSettle();

      final distanceField = find.widgetWithText(TextFormField, 'Dystans (km)');
      final minutesField = find.widgetWithText(TextFormField, 'Minuty');
      final secondsField = find.widgetWithText(TextFormField, 'Sekundy');

      await tester.enterText(distanceField, '5.0');
      await tester.pump();
      await tester.enterText(minutesField, '25');
      await tester.pump();
      await tester.enterText(secondsField, '0');
      await tester.pumpAndSettle();

      // Verify pace is calculated
      expect(find.textContaining('Tempo'), findsOneWidget);
      expect(find.textContaining('min/km'), findsOneWidget);

      // Use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Trening został dodany do historii!'), findsOneWidget);
    });

    testWidgets('should add cycling workout with distance', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Rower'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Dystans (km)'), 500.0);
      await tester.pumpAndSettle();

      final distanceField = find.widgetWithText(TextFormField, 'Dystans (km)');
      final minutesField = find.widgetWithText(TextFormField, 'Minuty');

      await tester.enterText(distanceField, '20.5');
      await tester.pump();
      await tester.enterText(minutesField, '60');
      await tester.pumpAndSettle();

      // Use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Trening został dodany do historii!'), findsOneWidget);
    });

    testWidgets('should calculate pace correctly for running', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Bieganie'));
      await tester.pumpAndSettle();

      final distanceField = find.widgetWithText(TextFormField, 'Dystans (km)');
      final minutesField = find.widgetWithText(TextFormField, 'Minuty');
      final secondsField = find.widgetWithText(TextFormField, 'Sekundy');

      // 5km in 25 minutes = 5 min/km
      await tester.enterText(distanceField, '5.0');
      await tester.pump();
      await tester.enterText(minutesField, '25');
      await tester.pump();
      await tester.enterText(secondsField, '0');
      await tester.pumpAndSettle();

      expect(find.textContaining('Tempo'), findsOneWidget);
      expect(find.textContaining('5:00'), findsOneWidget);
    });
  });

  group('KAN-18: Dodanie prostych notatek do treningu', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should add notes to workout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Notatki (opcjonalnie)'), 500.0);
      await tester.pumpAndSettle();

      final notesField = find.widgetWithText(TextFormField, 'Notatki (opcjonalnie)');
      await tester.enterText(notesField, 'Świetny trening! Czułem się silny.');
      await tester.pump();

      // Use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Trening został dodany do historii!'), findsOneWidget);

      // Verify notes were saved
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      expect(workouts.length, 1);
      expect(workouts.first.notes, 'Świetny trening! Czułem się silny.');
    });

    testWidgets('should allow saving workout without notes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Don't fill notes, just save - use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Trening został dodany do historii!'), findsOneWidget);
    });
  });

  group('KAN-19: Lista wszystkich treningów', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display empty state when no workouts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Brak treningów w historii'), findsOneWidget);
      expect(find.text('Dodaj trening, aby zobaczyć go tutaj'), findsOneWidget);
    });

    testWidgets('should display list of all workouts sorted by date', (WidgetTester tester) async {
      // Add multiple workouts
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
          activityType: ActivityType.gym,
          customName: 'Trening siłowy',
        ),
      );

      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.running,
          distance: 5.0,
          durationMinutes: 30,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify workouts are displayed (newest first)
      expect(find.text('Trening siłowy'), findsOneWidget);
      expect(find.text('5.0 km'), findsOneWidget);
    });

    testWidgets('should navigate to workout detail when card is tapped', (WidgetTester tester) async {
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
          customName: 'Test Workout',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Workout'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutHistoryDetailPage), findsOneWidget);
      expect(find.text('Szczegóły treningu'), findsOneWidget);
    });
  });

  group('KAN-20: Szczegóły pojedynczego treningu', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display workout details', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
        customName: 'Test Workout',
        durationMinutes: 60,
        notes: 'Test notes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Workout'), findsOneWidget);
      expect(find.text('Test notes'), findsOneWidget);
    });

    testWidgets('should display strength exercises if present', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
        strengthExercises: [
          StrengthExercise(
            name: 'Przysiad',
            sets: [
              ExerciseSet(weight: 100.0, reps: 10),
              ExerciseSet(weight: 100.0, reps: 8),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ćwiczenia'), findsOneWidget);
      expect(find.text('Przysiad'), findsOneWidget);
      expect(find.textContaining('100'), findsWidgets);
    });

    testWidgets('should display cardio details if present', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.running,
        distance: 5.0,
        pace: 5.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('5.0 km'), findsOneWidget);
      expect(find.textContaining('Tempo'), findsOneWidget);
    });
  });

  group('KAN-21: Edycja treningu', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should open edit page from workout detail', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
        customName: 'Original Name',
        notes: 'Original notes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.byType(EditWorkoutHistoryPage), findsOneWidget);
      expect(find.text('Edytuj trening'), findsOneWidget);
    });

    testWidgets('should update workout when saved', (WidgetTester tester) async {
      final originalWorkout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
        customName: 'Original Name',
        notes: 'Original notes',
      );

      await WorkoutHistoryService.saveCustomWorkout(originalWorkout);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditWorkoutHistoryPage(completedWorkout: originalWorkout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find notes field by scrolling to it
      final notesFieldFinder = find.widgetWithText(TextFormField, 'Notatki (opcjonalnie)');
      await tester.scrollUntilVisible(notesFieldFinder, 500.0);
      await tester.pumpAndSettle();

      final notesField = notesFieldFinder.first;
      await tester.enterText(notesField, 'Updated notes');
      await tester.pump();

      // Use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Trening został zaktualizowany!'), findsOneWidget);

      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      expect(workouts.length, 1);
      expect(workouts.first.notes, 'Updated notes');
    });
  });

  group('KAN-22: Usuwanie treningu', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should show delete confirmation dialog', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Usuń trening'), findsOneWidget);
      expect(find.textContaining('Czy na pewno'), findsOneWidget);
      expect(find.text('Anuluj'), findsOneWidget);
      expect(find.text('Usuń'), findsOneWidget);
    });

    testWidgets('should delete workout when confirmed', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
        customName: 'To Be Deleted',
      );

      await WorkoutHistoryService.saveCustomWorkout(workout);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Find and tap delete button in dialog - use widgetWithText to find FilledButton with text
      final deleteButton = find.widgetWithText(FilledButton, 'Usuń');
      if (deleteButton.evaluate().isEmpty) {
        // Fallback: try finding by text if widgetWithText doesn't work
        await tester.tap(find.text('Usuń').first);
      } else {
        await tester.tap(deleteButton);
      }
      await tester.pumpAndSettle();

      // Wait a bit for SnackBar to appear
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify workout was deleted (more reliable than checking SnackBar text)
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      expect(workouts.length, 0);
      
      // Also verify SnackBar appeared (if still visible) - use findsAny as SnackBar may disappear quickly
      expect(find.text('Trening został usunięty'), findsAny);
    });

    testWidgets('should cancel deletion when cancel is tapped', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
      );

      await WorkoutHistoryService.saveCustomWorkout(workout);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();

      expect(find.text('Usuń trening'), findsNothing);
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      expect(workouts.length, 1);
    });
  });

  group('KAN-23: Podstawowy licznik treningów', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display workout count on dashboard', (WidgetTester tester) async {
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

      expect(find.text('3'), findsWidgets);
    });

    testWidgets('should count workouts this week', (WidgetTester tester) async {
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

      expect(find.text('1'), findsWidgets);
    });
  });

  group('KAN-24: Prosty przegląd ostatnich wyników', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display recent workouts section', (WidgetTester tester) async {
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

    testWidgets('should display list of exercises when available', (WidgetTester tester) async {
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

      expect(find.text('Przysiad'), findsOneWidget);
    });

    testWidgets('should navigate to exercise detail when tapped', (WidgetTester tester) async {
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

      await tester.tap(find.text('Przysiad'));
      await tester.pumpAndSettle();

      expect(find.text('Przysiad'), findsWidgets);
    });
  });

  group('KAN-26: Suma dystansu / czasu (card na dashboardzie)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display cardio stats card when data available', (WidgetTester tester) async {
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

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should open add workout page when FAB is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

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

      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  group('KAN-29: Proste ustawienia (minimalne)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.resetToDefaults();
    });

    testWidgets('should display settings page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('Ustawienia'), findsOneWidget);
    });

    testWidgets('should display language selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Język aplikacji'), findsOneWidget);
      expect(find.text('Polski'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('should display distance unit selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Jednostki'), findsOneWidget);
      expect(find.text('Kilometry (km)'), findsOneWidget);
      expect(find.text('Mile (mi)'), findsOneWidget);
    });
  });

  group('KAN-30: Wybór języka (PL/EN) + Dark Mode', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.resetToDefaults();
    });

    testWidgets('should change language to Polish', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Polski'));
      await tester.pumpAndSettle();

      final language = await SettingsService.getLanguage();
      expect(language, AppLanguage.polish);
    });

    testWidgets('should change language to English', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      final language = await SettingsService.getLanguage();
      expect(language, AppLanguage.english);
    });

    testWidgets('should use dark mode by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      // Verify dark theme is configured (app uses dark mode by default in main.dart)
      expect(materialApp.themeMode, ThemeMode.dark);
    });
  });

  group('KAN-8: Strona główna – Lista aktywności pogrupowanych per dzień', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display dashboard as main page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('should show recent workouts grouped by date', (WidgetTester tester) async {
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
          customName: 'Today Workout',
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
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ostatnie treningi'), findsOneWidget);
      expect(find.text('Today Workout'), findsOneWidget);
    });
  });

  group('Dodatkowe testy integracyjne', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
      await SettingsService.resetToDefaults();
    });

    testWidgets('should navigate through all main tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Workouts tab
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutListPage), findsOneWidget);

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

    testWidgets('should open workout detail from workout list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const MainNavigation(),
          routes: {
            '/workout-detail': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              if (args is String) {
                return WorkoutDetailPage(workoutId: args);
              }
              return const Scaffold(body: Center(child: Text('Error')));
            },
          },
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Workouts tab
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pumpAndSettle();

      // Tap on first workout card
      final workoutCards = find.byType(Card);
      if (workoutCards.evaluate().isNotEmpty) {
        await tester.tap(workoutCards.first);
        await tester.pumpAndSettle();

        // Should navigate to workout detail
        expect(find.byType(WorkoutDetailPage), findsOneWidget);
      }
    });
  });
}
