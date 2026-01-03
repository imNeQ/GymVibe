import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsService', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should default to kilometers for distance unit', () async {
      final unit = await SettingsService.getDistanceUnit();
      expect(unit, DistanceUnit.kilometers);
    });

    test('should save and retrieve distance unit', () async {
      await SettingsService.setDistanceUnit(DistanceUnit.miles);
      final unit = await SettingsService.getDistanceUnit();
      
      expect(unit, DistanceUnit.miles);
    });

    test('should get distance unit display name', () {
      expect(
        SettingsService.getDistanceUnitDisplayName(DistanceUnit.kilometers),
        'Kilometry (km)',
      );
      expect(
        SettingsService.getDistanceUnitDisplayName(DistanceUnit.miles),
        'Mile (mi)',
      );
    });

    test('should convert distance from km to miles', () async {
      await SettingsService.setDistanceUnit(DistanceUnit.miles);
      final converted = await SettingsService.convertDistance(10.0);
      
      expect(converted, closeTo(6.21371, 0.001)); // 10 km ≈ 6.21 miles
    });

    test('should not convert distance when unit is kilometers', () async {
      await SettingsService.setDistanceUnit(DistanceUnit.kilometers);
      final converted = await SettingsService.convertDistance(10.0);
      
      expect(converted, 10.0);
    });

    test('should get distance unit symbol', () async {
      await SettingsService.setDistanceUnit(DistanceUnit.kilometers);
      expect(await SettingsService.getDistanceUnitSymbol(), 'km');
      
      await SettingsService.setDistanceUnit(DistanceUnit.miles);
      expect(await SettingsService.getDistanceUnitSymbol(), 'mi');
    });

    test('should save and retrieve language', () async {
      await SettingsService.setLanguage(AppLanguage.english);
      final language = await SettingsService.getLanguage();
      
      expect(language, AppLanguage.english);
    });

    test('should get language display name', () {
      expect(
        SettingsService.getLanguageDisplayName(AppLanguage.polish),
        'Polski',
      );
      expect(
        SettingsService.getLanguageDisplayName(AppLanguage.english),
        'English',
      );
    });

    test('should get language code', () {
      expect(
        SettingsService.getLanguageCode(AppLanguage.polish),
        'pl',
      );
      expect(
        SettingsService.getLanguageCode(AppLanguage.english),
        'en',
      );
    });

    test('should reset to defaults', () async {
      await SettingsService.setDistanceUnit(DistanceUnit.miles);
      await SettingsService.setLanguage(AppLanguage.english);
      
      await SettingsService.resetToDefaults();
      
      // After reset, language should be set based on system (defaults to polish if not pl/en)
      final language = await SettingsService.getLanguage();
      expect(language, isA<AppLanguage>());
      
      // Distance unit should default to kilometers
      final unit = await SettingsService.getDistanceUnit();
      expect(unit, DistanceUnit.kilometers);
    });
  });
}
