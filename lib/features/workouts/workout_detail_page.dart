import 'package:flutter/material.dart';
import '../../core/services/mock_data.dart';
import '../../core/services/workout_history_service.dart';
import '../../core/services/custom_workout_service.dart';
import '../../core/models/exercise.dart';
import '../../core/models/workout.dart';
import '../../core/localization/app_localizations.dart';
import 'workout_timer_page.dart';

class WorkoutDetailPage extends StatefulWidget {
  final String workoutId;

  const WorkoutDetailPage({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  bool _isCompleted = false;
  Future<Workout?>? _workoutFuture;

  @override
  void initState() {
    super.initState();
    _workoutFuture = MockDataService.getWorkoutById(widget.workoutId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Workout?>(
      future: _workoutFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)?.workoutDetail ?? 'Workout Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final workout = snapshot.data;
        if (workout == null) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)?.workoutNotFound ?? 'Workout Not Found')),
            body: Center(child: Text(AppLocalizations.of(context)?.workoutNotFound ?? 'Workout not found')),
          );
        }

        final theme = Theme.of(context);
        final difficultyColor = _getDifficultyColor(workout.difficulty);

        final isCustomWorkout = _isCustomWorkout(workout.id);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(workout.name),
            actions: [
              if (isCustomWorkout)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteDialog(context, workout),
                  tooltip: AppLocalizations.of(context)?.deleteWorkout ?? 'Delete Workout',
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWorkoutInfoCard(workout, difficultyColor, theme),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)?.exercises ?? 'Exercises',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...workout.exercises.map((exercise) => _buildExerciseCard(context, exercise, theme)),
                  const SizedBox(height: 24),
                  if (!_isCompleted) _buildStartWorkoutButton(theme, workout),
                  if (!_isCompleted) const SizedBox(height: 8),
                  _buildMarkAsDoneButton(theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build workout information card.
  Widget _buildWorkoutInfoCard(Workout workout, Color difficultyColor, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDifficultyChip(context, workout.difficulty, difficultyColor),
                _buildDurationChip(workout.estimatedDurationMinutes, theme),
              ],
            ),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                final description = l10n?.getWorkoutDescription(workout.id) ?? workout.description;
                if (description == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
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

  /// Build exercise card.
  Widget _buildExerciseCard(BuildContext context, Exercise exercise, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.fitness_center,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${exercise.sets} ${l10n?.sets ?? 'sets'} × ${exercise.reps} ${l10n?.reps ?? 'reps'}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (exercise.restSeconds != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${l10n?.rest ?? 'Rest'}: ${exercise.restSeconds}s',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build start workout button.
  Widget _buildStartWorkoutButton(ThemeData theme, Workout workout) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutTimerPage(
                workoutId: widget.workoutId,
                workoutName: workout.name,
              ),
            ),
          ).then((durationSeconds) {
            // Refresh completion status after timer finishes
            if (mounted && durationSeconds != null) {
              setState(() {
                _isCompleted = true;
              });
            }
          });
        },
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n?.startWorkout ?? 'Start Workout'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  /// Build mark as done button.
  Widget _buildMarkAsDoneButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isCompleted
            ? null
            : () async {
                await WorkoutHistoryService.saveCompletedWorkout(widget.workoutId);
                if (mounted) {
                  setState(() {
                    _isCompleted = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)?.workoutMarkedAsCompleted ?? 'Workout marked as completed!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
        icon: Icon(_isCompleted ? Icons.check_circle : Icons.check),
        label: Text(_isCompleted ? (AppLocalizations.of(context)?.completed ?? 'Completed') : (AppLocalizations.of(context)?.markAsDone ?? 'Mark as Done')),
        style: FilledButton.styleFrom(
          backgroundColor: _isCompleted
              ? Colors.green
              : theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// Get color for difficulty level.
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Build difficulty chip.
  Widget _buildDifficultyChip(BuildContext context, String difficulty, Color color) {
    final l10n = AppLocalizations.of(context);
    String difficultyText;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        difficultyText = l10n?.beginner ?? 'Beginner';
        break;
      case 'intermediate':
        difficultyText = l10n?.intermediate ?? 'Intermediate';
        break;
      case 'advanced':
        difficultyText = l10n?.advanced ?? 'Advanced';
        break;
      default:
        difficultyText = difficulty;
    }
    
    return Chip(
      label: Text(difficultyText),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  /// Build duration chip.
  Widget _buildDurationChip(int minutes, ThemeData theme) {
    return Chip(
      avatar: Icon(
        Icons.timer,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      label: Text('$minutes min'),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  /// Check if workout is a custom user-created workout.
  bool _isCustomWorkout(String workoutId) {
    return workoutId.startsWith('custom_');
  }

  /// Show delete confirmation dialog.
  Future<void> _showDeleteDialog(BuildContext context, Workout workout) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final workoutId = workout.id;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.deleteWorkout ?? 'Delete Workout'),
        content: Text(l10n?.deleteConfirmation ?? 'Czy na pewno chcesz usunąć ten trening? Tej operacji nie można cofnąć.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n?.delete ?? 'Usuń'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteWorkout(navigator, messenger, l10n, workoutId);
    }
  }

  /// Delete the workout.
  Future<void> _deleteWorkout(NavigatorState navigator, ScaffoldMessengerState messenger, AppLocalizations? l10n, String workoutId) async {
    if (!mounted) return;
    
    try {
      final success = await CustomWorkoutService.deleteWorkout(workoutId);
      if (!mounted) return;
      
      if (success) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n?.workoutDeleted ?? 'Workout has been deleted'),
            duration: const Duration(seconds: 2),
          ),
        );
        if (!mounted) return;
        // Navigate back to workout list
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
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n?.deleteFailed ?? 'Nie udało się usunąć treningu'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
