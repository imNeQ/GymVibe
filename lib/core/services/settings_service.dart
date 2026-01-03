import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum for distance units.
enum DistanceUnit {
  kilometers,
  miles,
}

/// Enum for app language.
enum AppLanguage {
  polish,
  english,
}

/// Enum for theme mode.
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Service for managing app settings.
/// Stores settings in local storage using SharedPreferences.
class SettingsService {
  static const String _keyDistanceUnit = 'distance_unit';
  static const String _keyLanguage = 'app_language';
  static const String _keyThemeMode = 'theme_mode';

  /// Get distance unit preference.
  /// Defaults to kilometers if not set.
  static Future<DistanceUnit> getDistanceUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final unitString = prefs.getString(_keyDistanceUnit);
    
    if (unitString == null) {
      return DistanceUnit.kilometers; // Default
    }
    
    // Parse enum from string (e.g., "DistanceUnit.kilometers" -> DistanceUnit.kilometers)
    try {
      return DistanceUnit.values.firstWhere(
        (unit) => unit.name == unitString,
        orElse: () => DistanceUnit.kilometers,
      );
    } catch (e) {
      return DistanceUnit.kilometers;
    }
  }

  /// Set distance unit preference.
  static Future<void> setDistanceUnit(DistanceUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDistanceUnit, unit.name);
  }

  /// Get distance unit as display string.
  static String getDistanceUnitDisplayName(DistanceUnit unit) {
    switch (unit) {
      case DistanceUnit.kilometers:
        return 'Kilometry (km)';
      case DistanceUnit.miles:
        return 'Mile (mi)';
    }
  }

  /// Convert distance from kilometers to selected unit.
  static Future<double> convertDistance(double distanceInKm) async {
    final unit = await getDistanceUnit();
    switch (unit) {
      case DistanceUnit.kilometers:
        return distanceInKm;
      case DistanceUnit.miles:
        return distanceInKm * 0.621371; // km to miles
    }
  }

  /// Get distance unit symbol.
  static Future<String> getDistanceUnitSymbol() async {
    final unit = await getDistanceUnit();
    switch (unit) {
      case DistanceUnit.kilometers:
        return 'km';
      case DistanceUnit.miles:
        return 'mi';
    }
  }

  /// Get app language preference.
  /// If not set, detects system language and sets it automatically.
  static Future<AppLanguage> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageString = prefs.getString(_keyLanguage);
    
    if (languageString == null) {
      // Auto-detect system language on first run
      final systemLocale = PlatformDispatcher.instance.locale;
      final systemLanguage = systemLocale.languageCode.toLowerCase();
      
      AppLanguage detectedLanguage;
      if (systemLanguage == 'pl') {
        detectedLanguage = AppLanguage.polish;
      } else if (systemLanguage == 'en') {
        detectedLanguage = AppLanguage.english;
      } else {
        // Default to Polish for other languages
        detectedLanguage = AppLanguage.polish;
      }
      
      // Save detected language
      await setLanguage(detectedLanguage);
      return detectedLanguage;
    }
    
    try {
      return AppLanguage.values.firstWhere(
        (lang) => lang.name == languageString,
        orElse: () => AppLanguage.polish,
      );
    } catch (e) {
      return AppLanguage.polish;
    }
  }

  /// Set app language preference.
  static Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, language.name);
  }

  /// Get language display name.
  static String getLanguageDisplayName(AppLanguage language) {
    switch (language) {
      case AppLanguage.polish:
        return 'Polski';
      case AppLanguage.english:
        return 'English';
    }
  }

  /// Get language code (for future i18n implementation).
  static String getLanguageCode(AppLanguage language) {
    switch (language) {
      case AppLanguage.polish:
        return 'pl';
      case AppLanguage.english:
        return 'en';
    }
  }

  /// Get theme mode preference.
  /// Defaults to dark if not set.
  static Future<AppThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_keyThemeMode);
    
    if (modeString == null) {
      return AppThemeMode.dark; // Default to dark
    }
    
    try {
      return AppThemeMode.values.firstWhere(
        (mode) => mode.name == modeString,
        orElse: () => AppThemeMode.dark,
      );
    } catch (e) {
      return AppThemeMode.dark;
    }
  }

  /// Set theme mode preference.
  static Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  /// Convert AppThemeMode to Flutter ThemeMode.
  static ThemeMode toThemeMode(AppThemeMode appMode) {
    switch (appMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Get theme mode display name.
  static String getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Jasny';
      case AppThemeMode.dark:
        return 'Ciemny';
      case AppThemeMode.system:
        return 'Systemowy';
    }
  }

  /// Reset all settings to default values.
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDistanceUnit);
    await prefs.remove(_keyLanguage);
    await prefs.remove(_keyThemeMode);
    
    // Set language based on system locale
    final systemLocale = PlatformDispatcher.instance.locale;
    final systemLanguage = systemLocale.languageCode.toLowerCase();
    
    if (systemLanguage == 'pl') {
      await setLanguage(AppLanguage.polish);
    } else if (systemLanguage == 'en') {
      await setLanguage(AppLanguage.english);
    } else {
      await setLanguage(AppLanguage.polish);
    }
    
    // Default to dark mode
    await setThemeMode(AppThemeMode.dark);
  }
}
