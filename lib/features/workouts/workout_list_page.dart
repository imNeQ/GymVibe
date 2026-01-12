import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../core/services/mock_data.dart';
import '../../core/services/custom_workout_service.dart';
import '../../core/models/workout.dart';
import '../../core/localization/app_localizations.dart';
import 'add_workout_page.dart';

class WorkoutListPage extends StatefulWidget {
  const WorkoutListPage({super.key});

  @override
  State<WorkoutListPage> createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListPage> {
  String? _selectedDifficulty;
  Future<List<Workout>>? _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() {
    setState(() {
      _workoutsFuture = MockDataService.getWorkouts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Don't refresh here - it causes infinite loops
    // Refresh is handled by MainNavigation when switching tabs
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'workout_list_fab',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddWorkoutPage(),
            ),
          );
          // Refresh list if workout was saved
          if (result == true) {
            _loadWorkouts();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(l10n?.addWorkout ?? 'Add Workout'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterSection(context),
            Expanded(
            child: FutureBuilder<List<Workout>>(
              future: _workoutsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  final l10n = AppLocalizations.of(context);
                  return Center(
                    child: Text('${l10n?.error ?? 'Error'}: ${snapshot.error}'),
                  );
                }

                final allWorkouts = snapshot.data ?? [];
                final filteredWorkouts = _selectedDifficulty == null
                    ? allWorkouts
                    : allWorkouts.where((w) => w.difficulty == _selectedDifficulty).toList();

                if (filteredWorkouts.isEmpty) {
                  final theme = Theme.of(context);
                  final l10n = AppLocalizations.of(context);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n?.noWorkoutsInHistory ?? 'No workouts',
                          style: theme.textTheme.titleMedium,
                        ),
                        if (_selectedDifficulty != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${l10n?.filterByLevel ?? 'For level'}: $_selectedDifficulty',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '${l10n?.allWorkoutsCount ?? 'Total workouts'}: ${allWorkouts.length}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredWorkouts.length,
                  itemBuilder: (context, index) {
                    return _buildWorkoutCard(context, filteredWorkouts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Build filter section with difficulty chips.
  Widget _buildFilterSection(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.filterByLevel ?? 'Filter by Level',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(l10n?.all ?? 'All', null),
              _buildFilterChip(l10n?.beginner ?? 'Beginner', 'Beginner'),
              _buildFilterChip(l10n?.intermediate ?? 'Intermediate', 'Intermediate'),
              _buildFilterChip(l10n?.advanced ?? 'Advanced', 'Advanced'),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a filter chip.
  Widget _buildFilterChip(String label, String? difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDifficulty = selected ? difficulty : null;
        });
      },
    );
  }

  /// Build a card widget for a single workout.
  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    final theme = Theme.of(context);
    final difficultyColor = _getDifficultyColor(workout.difficulty);
    final isCustomWorkout = _isCustomWorkout(workout.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.workoutDetail,
            arguments: workout.id,
          );
          // Refresh list if workout was deleted
          if (result == true) {
            _loadWorkouts();
          }
        },
        onLongPress: isCustomWorkout ? () => _showDeleteDialog(context, workout) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
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
    final messenger = ScaffoldMessenger.of(context);
    final workoutId = workout.id;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.deleteWorkout ?? 'Delete Workout'),
        content: Text(l10n?.deleteConfirmation ?? 'Are you sure you want to delete this workout? This action cannot be undone.'),
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
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteWorkout(messenger, l10n, workoutId);
    }
  }

  /// Delete the workout.
  Future<void> _deleteWorkout(ScaffoldMessengerState messenger, AppLocalizations? l10n, String workoutId) async {
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
        // Refresh the list
        _loadWorkouts();
      } else {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n?.deleteFailed ?? 'Failed to delete workout'),
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
