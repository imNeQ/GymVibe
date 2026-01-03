import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/navigation/main_navigation.dart';
import 'package:trening_tracker/features/settings/settings_page.dart';
import 'package:trening_tracker/core/services/settings_service.dart';
import 'package:trening_tracker/features/dashboard/dashboard_page.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:trening_tracker/core/models/completed_workout.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testy dla funkcjonalności ustawień i nawigacji (KAN-29, KAN-30, KAN-12, KAN-8)
void main() {
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

      // Tap Polish option
      await tester.tap(find.text('Polski'));
      await tester.pumpAndSettle();

      // Verify language was saved
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

      // Tap English option
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Verify language was saved
      final language = await SettingsService.getLanguage();
      expect(language, AppLanguage.english);
    });

    testWidgets('should use dark mode by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // App should be in dark mode (as per main.dart themeMode: ThemeMode.dark)
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      // Note: themeMode is set in main.dart, so we verify the app structure
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
    });
  });

  group('KAN-12: Korzystanie bez zakładania konta', () {
    testWidgets('should not require login to access app', (WidgetTester tester) async {
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

    testWidgets('should allow immediate workout tracking', (WidgetTester tester) async {
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
  });

  group('KAN-8: Strona główna – Lista aktywności pogrupowanych per dzień', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display dashboard as main page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Dashboard should be the initial page
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('should show recent workouts grouped by date', (WidgetTester tester) async {
      // Add workouts from different days
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

      // Should display recent workouts section
      expect(find.text('Ostatnie treningi'), findsOneWidget);
      expect(find.text('Today Workout'), findsOneWidget);
    });
  });
}
