import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/routes.dart';
import 'core/navigation/main_navigation.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/settings_service.dart';
import 'features/workouts/workout_detail_page.dart';

/// Main entry point of the GymVibe application.
/// Initializes the Flutter app with MaterialApp and routing configuration.
/// 
/// Note: App works without login/registration - users can start tracking workouts immediately.
/// All data is stored locally using SharedPreferences and persists across app restarts.
void main() => runApp(const MyApp());

/// Root widget of the GymVibe application.
/// Configures MaterialApp with theme, navigation, and routes.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  /// Static method to find MyAppState from context.
  static MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>();
  }
}

class MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await Future.wait([
      _loadLanguage(),
      _loadThemeMode(),
    ]);
  }

  Future<void> _loadLanguage() async {
    final language = await SettingsService.getLanguage();
    if (mounted) {
      final languageCode = SettingsService.getLanguageCode(language);
      final newLocale = languageCode == 'pl' 
          ? const Locale('pl', 'PL')
          : const Locale('en', 'US');
      setState(() {
        _locale = newLocale;
      });
    }
  }

  Future<void> _loadThemeMode() async {
    final appThemeMode = await SettingsService.getThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = SettingsService.toThemeMode(appThemeMode);
      });
    }
  }

  /// Callback to refresh language when changed in settings.
  Future<void> refreshLanguage() async {
    await _loadLanguage();
  }

  /// Callback to refresh theme mode when changed in settings.
  Future<void> refreshThemeMode() async {
    await _loadThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymVibe',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pl', 'PL'),
        Locale('en', 'US'),
      ],
      // Initial route is main navigation - no login required
      // Users can immediately access all features and track workouts
      home: const MainNavigation(),
      // Named routes for detail pages (that need to be full screen)
      routes: {
        AppRoutes.workoutDetail: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is String) {
            return WorkoutDetailPage(workoutId: args);
          }
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: Center(child: Text(l10n?.workoutIdRequired ?? 'Workout ID required')),
          );
        },
      },
    );
  }
}
