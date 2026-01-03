import 'package:flutter/material.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/localization/app_localizations.dart';

/// Page for editing user profile.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  /// Load existing profile data.
  Future<void> _loadProfile() async {
    final profile = await UserProfileService.getProfile();
    setState(() {
      _nameController.text = profile.name ?? '';
      _goalController.text = profile.goal ?? '';
    });
  }

  /// Save profile changes.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = UserProfile(
        name: _nameController.text.trim(),
        goal: _goalController.text.trim(),
      );

      await UserProfileService.saveProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.profileSaved ?? 'Profil został zapisany'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.error ?? 'Błąd podczas zapisywania profilu'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.editProfile ?? 'Edytuj profil'),
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar section
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n?.name ?? 'Imię / Nick',
                    hintText: l10n?.nameHint ?? 'np. Jan, Trener123',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n?.provideName ?? 'Podaj imię lub nick';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Goal field
                TextFormField(
                  controller: _goalController,
                  decoration: InputDecoration(
                    labelText: l10n?.trainingGoal ?? 'Cel treningowy',
                    hintText: l10n?.trainingGoalHint ?? 'np. Budowanie masy, Utrata wagi, Wytrzymałość',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n?.provideGoal ?? 'Podaj cel treningowy';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveProfile,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(l10n?.save ?? 'Zapisz'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
