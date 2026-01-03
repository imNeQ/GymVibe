import 'package:flutter/material.dart';
import '../../core/models/completed_workout.dart';
import '../../core/models/strength_exercise.dart';
import '../../core/services/mock_data.dart';
import '../../core/services/workout_history_service.dart';
import '../../core/localization/app_localizations.dart';
import 'edit_workout_history_page.dart';

/// Page showing details of a completed workout from history.
class WorkoutHistoryDetailPage extends StatefulWidget {
  final CompletedWorkout completedWorkout;

  const WorkoutHistoryDetailPage({
    super.key,
    required this.completedWorkout,
  });

  @override
  State<WorkoutHistoryDetailPage> createState() => _WorkoutHistoryDetailPageState();
}

class _WorkoutHistoryDetailPageState extends State<WorkoutHistoryDetailPage> {
  late CompletedWorkout _completedWorkout;

  @override
  void initState() {
    super.initState();
    _completedWorkout = widget.completedWorkout;
  }

  void _refreshWorkout() async {
    final allWorkouts = await WorkoutHistoryService.getCompletedWorkouts();
    // Find updated workout by matching original date and activity type
    final updated = allWorkouts.firstWhere(
      (w) => w.completedAt == _completedWorkout.completedAt &&
          w.activityType == _completedWorkout.activityType &&
          (w.workoutId == _completedWorkout.workoutId ||
              (w.workoutId == null && _completedWorkout.workoutId == null)),
      orElse: () => _completedWorkout,
    );
    setState(() {
      _completedWorkout = updated;
    });
  }

  /// Show delete confirmation dialog.
  void _showDeleteConfirmation() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.deleteWorkout ?? 'Usuń trening'),
        content: Text(l10n?.deleteConfirmation ?? 'Czy na pewno chcesz usunąć ten trening? Tej operacji nie można cofnąć.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Anuluj'),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final l10n = AppLocalizations.of(context);
              navigator.pop(); // Close dialog
              final deleted = await WorkoutHistoryService.deleteWorkout(_completedWorkout);
              
              if (!mounted) return;
              
              if (deleted) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n?.workoutDeleted ?? 'Trening został usunięty'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                if (!mounted) return;
                // Navigate back to previous screen
                navigator.pop(true); // Return true to indicate deletion
              } else {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n?.deleteFailed ?? 'Nie udało się usunąć treningu'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n?.delete ?? 'Usuń'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workout = _completedWorkout.workoutId != null
        ? MockDataService.getWorkoutById(_completedWorkout.workoutId!)
        : null;

    final date = _completedWorkout.completedAt;
    final dateText = '${date.day}.${date.month}.${date.year}';

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.workoutDetails ?? 'Szczegóły treningu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditWorkoutHistoryPage(
                    completedWorkout: _completedWorkout,
                  ),
                ),
              );
              if (result == true) {
                // Refresh the workout data after editing
                _refreshWorkout();
              }
            },
            tooltip: l10n?.editWorkout ?? 'Edytuj trening',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
            tooltip: l10n?.deleteWorkout ?? 'Usuń trening',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context, theme, workout, dateText),
              if (_completedWorkout.strengthExercises != null &&
                  _completedWorkout.strengthExercises!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildStrengthExercisesSection(context, theme),
              ],
              const SizedBox(height: 24),
              _buildAdditionalInfoCard(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header card with workout name and date.
  Widget _buildHeaderCard(
    BuildContext context,
    ThemeData theme,
    dynamic workout,
    String dateText,
  ) {
    final l10n = AppLocalizations.of(context);
    final workoutName = _completedWorkout.customName ??
        (workout?.name ?? CompletedWorkout.getActivityTypeDisplayName(_completedWorkout.activityType, l10n: l10n));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workoutName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  dateText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getActivityColor(_completedWorkout.activityType, theme).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getActivityIcon(_completedWorkout.activityType),
                        size: 14,
                        color: _getActivityColor(_completedWorkout.activityType, theme),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        CompletedWorkout.getActivityTypeDisplayName(_completedWorkout.activityType, l10n: l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getActivityColor(_completedWorkout.activityType, theme),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_completedWorkout.totalDurationSeconds != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${AppLocalizations.of(context)?.timeLabel ?? 'Czas'}: ${_formatDuration(_completedWorkout.totalDurationSeconds!)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build strength exercises section.
  Widget _buildStrengthExercisesSection(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.exercises ?? 'Ćwiczenia',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._completedWorkout.strengthExercises!.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return _buildExerciseCard(context, exercise, index, theme);
        }),
      ],
    );
  }

  /// Build card for a strength exercise.
  Widget _buildExerciseCard(
    BuildContext context,
    StrengthExercise exercise,
    int index,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...exercise.sets.asMap().entries.map((setEntry) {
              final setIndex = setEntry.key;
              final set = setEntry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${AppLocalizations.of(context)?.series ?? 'Seria'} ${setIndex + 1}:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (set.weight != null)
                      Expanded(
                        child: Text(
                          '${set.weight!.toStringAsFixed(1)} kg × ${set.reps} ${AppLocalizations.of(context)?.repetitions ?? 'powtórzeń'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      Expanded(
                        child: Text(
                          '${set.reps} ${AppLocalizations.of(context)?.repetitions ?? 'powtórzeń'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Format duration for display.
  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}min ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format pace for display.
  String _formatPace(double pace) {
    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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

  /// Build additional info card.
  Widget _buildAdditionalInfoCard(BuildContext context, ThemeData theme) {
    // Show this card if there's distance, pace, or notes
    // For cardio workouts, always show distance/time info
    final hasCardioInfo = _completedWorkout.distance != null || 
        _completedWorkout.pace != null ||
        (_completedWorkout.activityType == ActivityType.running ||
         _completedWorkout.activityType == ActivityType.cycling ||
         _completedWorkout.activityType == ActivityType.swimming);
    
    if (!hasCardioInfo && _completedWorkout.notes == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_completedWorkout.distance != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${AppLocalizations.of(context)?.distanceColon ?? 'Dystans'}: ${_completedWorkout.distance!.toStringAsFixed(1)} km',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              if (_completedWorkout.pace != null || _completedWorkout.notes != null)
                const SizedBox(height: 12),
            ],
            if (_completedWorkout.pace != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${AppLocalizations.of(context)?.paceColon ?? 'Tempo'}: ${_formatPace(_completedWorkout.pace!)} min/km',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_completedWorkout.notes != null) const SizedBox(height: 12),
            ],
            if (_completedWorkout.notes != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${AppLocalizations.of(context)?.notesColon ?? 'Notatki'}:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _completedWorkout.notes!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
