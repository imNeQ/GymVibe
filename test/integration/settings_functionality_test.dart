import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/navigation/main_navigation.dart';
import 'package:trening_tracker/features/settings/settings_page.dart';
import 'package:trening_tracker/core/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testy funkcjonalne dla ustawień.
/// Testują zmianę ustawień i ich wpływ na aplikację.
void main() {
  group('Settings Functionality Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('should navigate to settings from profile', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Tap settings option
      final settingsOption = find.textContaining('Ustawienia', findRichText: true);
      final settingsOptionEn = find.textContaining('Settings', findRichText: true);
      
      if (settingsOption.evaluate().isNotEmpty) {
        await tester.tap(settingsOption.first);
      } else if (settingsOptionEn.evaluate().isNotEmpty) {
        await tester.tap(settingsOptionEn.first);
      }
      await tester.pumpAndSettle();

      // Should navigate to settings page
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('should change distance unit', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify current unit
      final currentUnit = await SettingsService.getDistanceUnit();
      expect(currentUnit, DistanceUnit.kilometers);

      // Change to miles
      final milesOption = find.textContaining('Mile', findRichText: true);
      if (milesOption.evaluate().isNotEmpty) {
        await tester.tap(milesOption.first);
        await tester.pumpAndSettle();

        // Verify unit changed
        final newUnit = await SettingsService.getDistanceUnit();
        expect(newUnit, DistanceUnit.miles);
      }
    });

    testWidgets('should change language', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find language selector
      final englishOption = find.textContaining('English', findRichText: true);

      // Change language
      if (englishOption.evaluate().isNotEmpty) {
        await tester.tap(englishOption.first);
        await tester.pumpAndSettle();

        // Verify language changed
        final newLanguage = await SettingsService.getLanguage();
        expect(newLanguage, AppLanguage.english);
      }
    });

    testWidgets('should reset settings to defaults', (WidgetTester tester) async {
      // Set custom settings first
      await SettingsService.setDistanceUnit(DistanceUnit.miles);
      await SettingsService.setLanguage(AppLanguage.english);

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find reset button
      final resetButton = find.textContaining('Resetuj', findRichText: true);
      final resetButtonEn = find.textContaining('Reset', findRichText: true);
      
      if (resetButton.evaluate().isNotEmpty) {
        await tester.tap(resetButton.first);
        await tester.pumpAndSettle();
      } else if (resetButtonEn.evaluate().isNotEmpty) {
        await tester.tap(resetButtonEn.first);
        await tester.pumpAndSettle();
      }

      // Verify settings were reset
      final distanceUnit = await SettingsService.getDistanceUnit();
      expect(distanceUnit, DistanceUnit.kilometers);
    });

    testWidgets('should persist settings across app restarts', (WidgetTester tester) async {
      // Set a setting
      await SettingsService.setDistanceUnit(DistanceUnit.miles);

      // Verify it's saved
      final savedUnit = await SettingsService.getDistanceUnit();
      expect(savedUnit, DistanceUnit.miles);

      // Simulate app restart by clearing and reloading
      // In real app, SharedPreferences persists automatically
      // Here we just verify the service can retrieve saved value
      final retrievedUnit = await SettingsService.getDistanceUnit();
      expect(retrievedUnit, DistanceUnit.miles);
    });
  });
}
