import 'package:flutter/material.dart';
import '../../core/services/workout_history_service.dart';
import '../../core/services/mock_data.dart';
import '../../core/models/completed_workout.dart';
import '../../core/models/workout.dart';
import '../../core/localization/app_localizations.dart';
import 'workout_history_detail_page.dart';

/// Page displaying list of all completed workouts from history.
class WorkoutHistoryListPage extends StatefulWidget {
  const WorkoutHistoryListPage({super.key});

  @override
  State<WorkoutHistoryListPage> createState() => _WorkoutHistoryListPageState();
}

class _WorkoutHistoryListPageState extends State<WorkoutHistoryListPage> {
  Future<List<CompletedWorkout>>? _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() {
    setState(() {
      _workoutsFuture = WorkoutHistoryService.getCompletedWorkouts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadWorkouts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.workoutHistory ?? 'Historia treningów'),
      ),
      body: FutureBuilder<List<CompletedWorkout>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('${l10n?.error ?? 'Błąd'}: ${snapshot.error}'),
            );
          }

          final workouts = snapshot.data ?? [];

          // Sort by date descending (newest first)
          workouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));

          if (workouts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.noWorkoutsInHistory ?? 'Brak treningów w historii',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.addWorkoutToSeeHere ?? 'Dodaj trening, aby zobaczyć go tutaj',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              return _buildWorkoutCard(context, workouts[index], theme);
            },
          );
        },
      ),
    );
  }

  /// Build a card for a completed workout.
  Widget _buildWorkoutCard(
    BuildContext context,
    CompletedWorkout completed,
    ThemeData theme,
  ) {
    final workoutFuture = completed.workoutId != null
        ? MockDataService.getWorkoutById(completed.workoutId!)
        : Future<Workout?>.value(null);

    final l10n = AppLocalizations.of(context);
    
    return FutureBuilder<Workout?>(
      future: workoutFuture,
      builder: (context, snapshot) {
        final workout = snapshot.data;
        final workoutName = completed.customName ??
            (workout?.name ?? CompletedWorkout.getActivityTypeDisplayName(completed.activityType, l10n: l10n));

        final date = completed.completedAt;
        final dateText = '${date.day}.${date.month}.${date.year}';

        // Get basic result based on activity type
        String? basicResult = _getBasicResult(completed);

        // Get activity type icon
        IconData activityIcon = _getActivityIcon(completed.activityType);
        Color activityColor = _getActivityColor(completed.activityType, theme);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutHistoryDetailPage(
                completedWorkout: completed,
              ),
            ),
          );
          // Refresh list if workout was deleted or edited
          if (result == true) {
            _loadWorkouts();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: activityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  activityIcon,
                  color: activityColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workoutName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: activityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            CompletedWorkout.getActivityTypeDisplayName(completed.activityType, l10n: l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: activityColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (basicResult != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        basicResult,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
      ),
    );
      },
    );
  }

  /// Get basic result string for the workout.
  String? _getBasicResult(CompletedWorkout completed) {
    // For cardio activities: show distance
    if (completed.activityType == ActivityType.running ||
        completed.activityType == ActivityType.cycling ||
        completed.activityType == ActivityType.swimming) {
      if (completed.distance != null) {
        return '${completed.distance!.toStringAsFixed(1)} km';
      }
      if (completed.totalDurationSeconds != null) {
        final minutes = (completed.totalDurationSeconds! / 60).round();
        return '$minutes min';
      }
    }

    // For gym workouts: show first exercise or number of exercises
    if (completed.activityType == ActivityType.gym) {
      if (completed.strengthExercises != null && completed.strengthExercises!.isNotEmpty) {
        final firstExercise = completed.strengthExercises!.first;
        if (firstExercise.sets.isNotEmpty) {
          final firstSet = firstExercise.sets.first;
          if (firstSet.weight != null) {
            return '${firstExercise.name}: ${firstSet.weight!.toStringAsFixed(1)} kg';
          }
          final l10n = AppLocalizations.of(context);
          return '${firstExercise.name}: ${firstSet.reps} ${l10n?.repetitions ?? 'powtórzeń'}';
        }
        return firstExercise.name;
      }
      if (completed.totalDurationSeconds != null) {
        final minutes = (completed.totalDurationSeconds! / 60).round();
        return '$minutes min';
      }
    }

    // For other activities: show duration if available
    if (completed.totalDurationSeconds != null) {
      final minutes = (completed.totalDurationSeconds! / 60).round();
      return '$minutes min';
    }

    return null;
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
