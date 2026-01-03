import 'package:flutter/material.dart';
import '../settings/settings_page.dart';
import '../workouts/workout_history_list_page.dart';
import '../workouts/workout_history_detail_page.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/user_profile.dart';
import '../../core/models/completed_workout.dart';
import '../../core/models/workout.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/services/achievement_service.dart';
import '../../core/services/workout_history_service.dart';
import '../../core/services/mock_data.dart';
import 'edit_profile_page.dart';
import 'exercise_search_page.dart';

/// Profile page - displays user information and profile actions.
/// Part of the GymVibe app's user management feature.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<UserProfile>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = UserProfileService.getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<UserProfile>(
              future: _profileFuture,
              builder: (context, snapshot) {
                final profile = snapshot.data ?? const UserProfile();
                final l10n = AppLocalizations.of(context);
                
                final userName = profile.getDisplayName(
                  l10n?.completeProfile ?? 'Uzupełnij profil',
                );
                final userGoal = profile.getDisplayGoal(
                  l10n?.trainingGoal ?? 'Cel treningowy',
                );
                final isEmpty = profile.isEmpty;

                return _buildProfileHeader(
                  context,
                  userName,
                  userGoal,
                  isEmpty,
                  theme,
                );
              },
            ),
            const SizedBox(height: 24),
            _buildActionList(context, theme),
            const SizedBox(height: 24),
            _buildAchievementsSection(context, theme),
            const SizedBox(height: 24),
            _buildRecentWorkoutsSection(context, theme),
          ],
        ),
      ),
    );
  }

  /// Build profile header card with user info.
  Widget _buildProfileHeader(
    BuildContext context,
    String userName,
    String userGoal,
    bool isEmpty,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isEmpty
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    : null,
                fontStyle: isEmpty ? FontStyle.italic : null,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userGoal,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontStyle: isEmpty ? FontStyle.italic : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build action list with profile options.
  Widget _buildActionList(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.edit, color: theme.colorScheme.primary),
            title: Text(l10n?.editProfile ?? 'Edytuj profil'),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
              // Refresh profile if changes were saved
              if (result == true) {
                _loadProfile();
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.settings, color: theme.colorScheme.primary),
            title: Text(l10n?.settings ?? 'Ustawienia'),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
              // Language might have changed, refresh if needed
              // The SettingsPage will handle the refresh internally
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.history, color: theme.colorScheme.primary),
            title: Text(l10n?.workoutHistory ?? 'Historia treningów'),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutHistoryListPage(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.search, color: theme.colorScheme.primary),
            title: Text(l10n?.exerciseSearch ?? 'Wyszukiwarka ćwiczeń'),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExerciseSearchPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build achievements section.
  Widget _buildAchievementsSection(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.achievements ?? 'Osiągnięcia',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: AchievementService.getAchievements(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        l10n?.error ?? 'Błąd podczas ładowania osiągnięć',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  );
                }

                final achievements = snapshot.data!;
                final unlockedCount = achievements.where((a) => a.unlocked).length;

                if (achievements.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.noAchievements ?? 'Brak osiągnięć',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlockedCount / ${achievements.length} ${l10n?.unlocked ?? 'odblokowanych'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: achievements.map((achievement) {
                        return _buildAchievementBadge(achievement, theme, l10n);
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build single achievement badge.
  Widget _buildAchievementBadge(dynamic achievement, ThemeData theme, AppLocalizations? l10n) {
    final achievementName = _getAchievementName(achievement.nameKey, l10n);
    final achievementDesc = _getAchievementDescription(achievement.descriptionKey, l10n);
    
    return Tooltip(
      message: achievementDesc,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: achievement.unlocked
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achievement.unlocked
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: achievement.unlocked ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.icon,
              style: TextStyle(
                fontSize: 20,
                color: achievement.unlocked
                    ? null
                    : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                achievementName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  color: achievement.unlocked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: achievement.unlocked ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get localized achievement name.
  String _getAchievementName(String key, AppLocalizations? l10n) {
    switch (key) {
      case 'achievementFirstStep':
        return l10n?.achievementFirstStep ?? 'Pierwszy krok';
      case 'achievementFiredUp':
        return l10n?.achievementFiredUp ?? 'Zapalony';
      case 'achievementTen':
        return l10n?.achievementTen ?? 'Dziesiątka';
      case 'achievementExerciser':
        return l10n?.achievementExerciser ?? 'Ćwiczący';
      case 'achievementMaster':
        return l10n?.achievementMaster ?? 'Mistrz';
      case 'achievementRunner':
        return l10n?.achievementRunner ?? 'Biegacz';
      case 'achievementMarathoner':
        return l10n?.achievementMarathoner ?? 'Maratończyk';
      case 'achievementTimeForTraining':
        return l10n?.achievementTimeForTraining ?? 'Czas na trening';
      case 'achievementHabit':
        return l10n?.achievementHabit ?? 'Nawyk';
      case 'achievementDiscipline':
        return l10n?.achievementDiscipline ?? 'Dyscyplina';
      default:
        return key;
    }
  }

  /// Get localized achievement description.
  String _getAchievementDescription(String key, AppLocalizations? l10n) {
    switch (key) {
      case 'achievementFirstStepDesc':
        return l10n?.achievementFirstStepDesc ?? 'Ukończ swój pierwszy trening';
      case 'achievementFiredUpDesc':
        return l10n?.achievementFiredUpDesc ?? 'Ukończ 5 treningów';
      case 'achievementTenDesc':
        return l10n?.achievementTenDesc ?? 'Ukończ 10 treningów';
      case 'achievementExerciserDesc':
        return l10n?.achievementExerciserDesc ?? 'Ukończ 25 treningów';
      case 'achievementMasterDesc':
        return l10n?.achievementMasterDesc ?? 'Ukończ 50 treningów';
      case 'achievementRunnerDesc':
        return l10n?.achievementRunnerDesc ?? 'Przebiegnij/przejedź 5 km';
      case 'achievementMarathonerDesc':
        return l10n?.achievementMarathonerDesc ?? 'Przebiegnij/przejedź 10 km';
      case 'achievementTimeForTrainingDesc':
        return l10n?.achievementTimeForTrainingDesc ?? 'Spędź 10 godzin na treningach';
      case 'achievementHabitDesc':
        return l10n?.achievementHabitDesc ?? 'Ćwicz przez 3 dni z rzędu';
      case 'achievementDisciplineDesc':
        return l10n?.achievementDisciplineDesc ?? 'Ćwicz przez 7 dni z rzędu';
      default:
        return key;
    }
  }

  /// Build recent workouts section.
  Widget _buildRecentWorkoutsSection(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.recentWorkouts ?? 'Ostatnie treningi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<CompletedWorkout>>(
              future: WorkoutHistoryService.getRecentWorkouts(limit: 5),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        l10n?.error ?? 'Błąd podczas ładowania historii',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  );
                }

                final workouts = snapshot.data!;

                if (workouts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.noWorkoutsInHistory ?? 'Brak treningów w historii',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: workouts.map((workout) {
                    return _buildWorkoutHistoryItem(context, workout, theme);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build single workout history item.
  Widget _buildWorkoutHistoryItem(
    BuildContext context,
    CompletedWorkout workout,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    final workoutFuture = workout.workoutId != null
        ? MockDataService.getWorkoutById(workout.workoutId!)
        : Future<Workout?>.value(null);
    final dateFormat = '${workout.completedAt.day}.${workout.completedAt.month}.${workout.completedAt.year}';

    return FutureBuilder<Workout?>(
      future: workoutFuture,
      builder: (context, snapshot) {
        final workoutData = snapshot.data;
        final displayName = workout.customName ??
            (workoutData?.name ??
                CompletedWorkout.getActivityTypeDisplayName(
                  workout.activityType,
                  l10n: l10n,
                ));

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutHistoryDetailPage(completedWorkout: workout),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getActivityColor(workout.activityType, theme).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActivityIcon(workout.activityType),
                    color: _getActivityColor(workout.activityType, theme),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get icon for activity type.
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.gym:
        return Icons.fitness_center;
      case ActivityType.running:
        return Icons.directions_run;
      case ActivityType.cycling:
        return Icons.directions_bike;
      case ActivityType.swimming:
        return Icons.pool;
      case ActivityType.other:
        return Icons.sports;
    }
  }

  /// Get color for activity type.
  Color _getActivityColor(ActivityType type, ThemeData theme) {
    switch (type) {
      case ActivityType.gym:
        return Colors.orange;
      case ActivityType.running:
        return Colors.green;
      case ActivityType.cycling:
        return Colors.blue;
      case ActivityType.swimming:
        return Colors.cyan;
      case ActivityType.other:
        return theme.colorScheme.primary;
    }
  }
}
