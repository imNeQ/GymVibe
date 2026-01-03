import 'package:flutter/material.dart';
import '../../core/services/settings_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../main.dart';

/// Settings page - allows users to configure app preferences.
/// Part of the GymVibe app's settings feature.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DistanceUnit? _selectedDistanceUnit;
  AppLanguage? _selectedLanguage;
  AppThemeMode? _selectedThemeMode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load current settings.
  Future<void> _loadSettings() async {
    final distanceUnit = await SettingsService.getDistanceUnit();
    final language = await SettingsService.getLanguage();
    final themeMode = await SettingsService.getThemeMode();
    setState(() {
      _selectedDistanceUnit = distanceUnit;
      _selectedLanguage = language;
      _selectedThemeMode = themeMode;
      _isLoading = false;
    });
  }

  /// Save distance unit preference.
  Future<void> _saveDistanceUnit(DistanceUnit unit) async {
    await SettingsService.setDistanceUnit(unit);
    setState(() {
      _selectedDistanceUnit = unit;
    });
    _showSaveConfirmation();
  }

  /// Save language preference.
  Future<void> _saveLanguage(AppLanguage language) async {
    await SettingsService.setLanguage(language);
    if (!mounted) return;
    setState(() {
      _selectedLanguage = language;
    });
    
    // Trigger app rebuild to apply new language immediately
    if (!mounted) return;
    final appState = MyApp.of(context);
    if (appState != null) {
      await appState.refreshLanguage();
    }
    
    // Also refresh this page to show updated translations
    if (mounted) {
      setState(() {});
    }
    
    // Wait for the context to update with new language before showing message
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showSaveConfirmation();
        }
      });
    }
  }

  /// Save theme mode preference.
  Future<void> _saveThemeMode(AppThemeMode mode) async {
    await SettingsService.setThemeMode(mode);
    if (!mounted) return;
    setState(() {
      _selectedThemeMode = mode;
    });
    
    // Trigger app rebuild to apply new theme mode immediately
    if (!mounted) return;
    final appState = MyApp.of(context);
    if (appState != null) {
      await appState.refreshThemeMode();
    }
    
    _showSaveConfirmation();
  }

  /// Reset all settings to defaults.
  Future<void> _resetToDefaults() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.resetSettings ?? 'Resetuj ustawienia'),
        content: Text(l10n?.resetConfirmation ?? 'Czy na pewno chcesz zresetować wszystkie ustawienia do wartości domyślnych?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n?.resetToDefaults ?? 'Reset do domyślnych'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await SettingsService.resetToDefaults();
      await _loadSettings();
      
      // Trigger app rebuild to apply new settings immediately
      if (!mounted) return;
      final appState = MyApp.of(context);
      if (appState != null) {
        await appState.refreshLanguage();
        await appState.refreshThemeMode();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.settingsSaved ?? 'Ustawienia zapisane'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Show save confirmation message.
  void _showSaveConfirmation() {
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.settingsSaved ?? 'Ustawienia zapisane'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? 'Ustawienia'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThemeModeSection(theme, l10n),
                    const SizedBox(height: 16),
                    _buildLanguageSection(theme, l10n),
                    const SizedBox(height: 16),
                    _buildDistanceUnitSection(theme, l10n),
                    const SizedBox(height: 16),
                    _buildResetSection(theme, l10n),
                  ],
                ),
              ),
            ),
    );
  }

  /// Build theme mode selection section.
  Widget _buildThemeModeSection(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n?.themeMode ?? 'Tryb motywu',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          RadioGroup<AppThemeMode>(
            groupValue: _selectedThemeMode,
            onChanged: (value) {
              if (value != null) {
                _saveThemeMode(value);
              }
            },
            child: Column(
              children: [
                const Divider(height: 1),
                RadioListTile<AppThemeMode>(
                  title: Text(l10n?.lightMode ?? 'Jasny'),
                  subtitle: Text(l10n?.lightModeDescription ?? 'Użyj jasnego motywu'),
                  value: AppThemeMode.light,
                ),
                const Divider(height: 1),
                RadioListTile<AppThemeMode>(
                  title: Text(l10n?.darkMode ?? 'Ciemny'),
                  subtitle: Text(l10n?.darkModeDescription ?? 'Użyj ciemnego motywu'),
                  value: AppThemeMode.dark,
                ),
                const Divider(height: 1),
                RadioListTile<AppThemeMode>(
                  title: Text(l10n?.systemMode ?? 'Systemowy'),
                  subtitle: Text(l10n?.systemModeDescription ?? 'Użyj motywu systemowego'),
                  value: AppThemeMode.system,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build language selection section.
  Widget _buildLanguageSection(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n?.appLanguage ?? 'Język aplikacji',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          RadioGroup<AppLanguage>(
            groupValue: _selectedLanguage,
            onChanged: (value) {
              if (value != null) {
                _saveLanguage(value);
              }
            },
            child: Column(
              children: [
                const Divider(height: 1),
                RadioListTile<AppLanguage>(
                  title: Text(l10n?.polish ?? 'Polski'),
                  subtitle: Text(l10n?.polishLanguage ?? 'Język polski'),
                  value: AppLanguage.polish,
                ),
                const Divider(height: 1),
                RadioListTile<AppLanguage>(
                  title: Text(l10n?.english ?? 'English'),
                  subtitle: Text(l10n?.englishLanguage ?? 'English language'),
                  value: AppLanguage.english,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build distance unit selection section.
  Widget _buildDistanceUnitSection(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n?.units ?? 'Jednostki',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          RadioGroup<DistanceUnit>(
            groupValue: _selectedDistanceUnit,
            onChanged: (value) {
              if (value != null) {
                _saveDistanceUnit(value);
              }
            },
            child: Column(
              children: [
                const Divider(height: 1),
                RadioListTile<DistanceUnit>(
                  title: Text(l10n?.kilometers ?? 'Kilometry (km)'),
                  subtitle: Text(l10n?.metricUnit ?? 'Jednostka metryczna'),
                  value: DistanceUnit.kilometers,
                ),
                const Divider(height: 1),
                RadioListTile<DistanceUnit>(
                  title: Text(l10n?.miles ?? 'Mile (mi)'),
                  subtitle: Text(l10n?.imperialUnit ?? 'Jednostka imperialna'),
                  value: DistanceUnit.miles,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build reset to defaults section.
  Widget _buildResetSection(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.resetToDefaults ?? 'Reset do domyślnych',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.resetConfirmation ?? 'Zresetuj wszystkie ustawienia do wartości domyślnych.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetToDefaults,
                icon: const Icon(Icons.restore),
                label: Text(l10n?.resetToDefaults ?? 'Reset do domyślnych'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
