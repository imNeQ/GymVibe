import 'package:flutter/material.dart';
import '../../core/models/workout_plan.dart';
import '../../core/models/workout.dart';
import '../../core/services/weekly_plan_service.dart';
import '../../core/services/mock_data.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/routes.dart';

/// Page for editing weekly workout plan.
class EditPlanPage extends StatefulWidget {
  const EditPlanPage({super.key});

  @override
  State<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  Future<WorkoutPlan>? _planFuture;
  Future<List<Workout>>? _workoutsFuture;
  WorkoutPlan? _currentPlan;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _planFuture = WeeklyPlanService.getPlan();
    _workoutsFuture = MockDataService.getWorkouts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize locale on first call, then refresh when locale changes (language switch)
    final newLocale = Localizations.localeOf(context);
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      // Trigger rebuild to update day names
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> _savePlan() async {
    if (_currentPlan == null) return;

    await WeeklyPlanService.savePlan(_currentPlan!);
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)?.planSaved ?? 'Plan został zapisany'),
        duration: const Duration(seconds: 2),
      ),
    );
    if (!mounted) return;
    Navigator.pop(context, true); // Return true to indicate success
  }

  void _addWorkoutToDay(int day) async {
    final workouts = await _workoutsFuture;
    if (workouts == null || workouts.isEmpty || !mounted) return;

    if (!mounted) return;
    final selectedWorkout = await showDialog<Workout>(
      context: context,
      builder: (context) => _SelectWorkoutDialog(workouts: workouts),
    );

    if (!mounted) return;
    if (selectedWorkout != null && _currentPlan != null) {
      setState(() {
        _currentPlan = _currentPlan!.addWorkoutToDay(day, selectedWorkout.id);
      });
    }
  }

  void _removeWorkoutFromDay(int day, String workoutId) {
    if (_currentPlan == null) return;
    setState(() {
      _currentPlan = _currentPlan!.removeWorkoutFromDay(day, workoutId);
    });
  }

  void _moveWorkoutUp(int day, int index) {
    if (_currentPlan == null) return;
    setState(() {
      _currentPlan = _currentPlan!.moveWorkoutUp(day, index);
    });
  }

  void _moveWorkoutDown(int day, int index) {
    if (_currentPlan == null) return;
    setState(() {
      _currentPlan = _currentPlan!.moveWorkoutDown(day, index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dayNames = [
      l10n?.monday ?? 'Poniedziałek',
      l10n?.tuesday ?? 'Wtorek',
      l10n?.wednesday ?? 'Środa',
      l10n?.thursday ?? 'Czwartek',
      l10n?.friday ?? 'Piątek',
      l10n?.saturday ?? 'Sobota',
      l10n?.sunday ?? 'Niedziela',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.editPlan ?? 'Edytuj plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _currentPlan != null ? _savePlan : null,
            tooltip: l10n?.save ?? 'Zapisz',
          ),
        ],
      ),
      body: FutureBuilder<WorkoutPlan>(
        future: _planFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(l10n?.error ?? 'Błąd podczas ładowania planu'),
            );
          }

          // Initialize current plan if not set
          _currentPlan ??= snapshot.data;

          return FutureBuilder<List<Workout>>(
            future: _workoutsFuture,
            builder: (context, workoutsSnapshot) {
              final workouts = workoutsSnapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = index + 1; // 1-7
                  final dayWorkouts = _currentPlan!.getWorkoutsForDay(day);

                  return _buildDayCard(
                    context,
                    day,
                    dayNames[index],
                    dayWorkouts,
                    workouts,
                    theme,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    int day,
    String dayName,
    List<String> workoutIds,
    List<Workout> allWorkouts,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    final dayWorkouts = workoutIds
        .map((id) {
          try {
            return allWorkouts.firstWhere((w) => w.id == id);
          } catch (e) {
            return null;
          }
        })
        .where((w) => w != null)
        .cast<Workout>()
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          dayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          dayWorkouts.isEmpty
              ? (l10n?.restDay ?? 'Dzień odpoczynku')
              : '${dayWorkouts.length} ${dayWorkouts.length == 1 ? (l10n?.workout ?? 'trening') : (l10n?.workouts ?? 'treningów')}',
        ),
        children: [
          if (dayWorkouts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      l10n?.restDay ?? 'Dzień odpoczynku',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _addWorkoutToDay(day),
                      icon: const Icon(Icons.add),
                      label: Text(l10n?.addWorkout ?? 'Dodaj trening'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...dayWorkouts.asMap().entries.map((entry) {
              final index = entry.key;
              final workout = entry.value;
              return ListTile(
                leading: Icon(
                  Icons.fitness_center,
                  color: theme.colorScheme.primary,
                ),
                title: Text(workout.name),
                subtitle: Text(
                  '${workout.difficulty} • ${workout.estimatedDurationMinutes} min',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Move up button
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 20),
                      onPressed: index > 0
                          ? () => _moveWorkoutUp(day, index)
                          : null,
                      tooltip: l10n?.moveUp ?? 'Przenieś w górę',
                    ),
                    // Move down button
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 20),
                      onPressed: index < dayWorkouts.length - 1
                          ? () => _moveWorkoutDown(day, index)
                          : null,
                      tooltip: l10n?.moveDown ?? 'Przenieś w dół',
                    ),
                    // Remove button
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _removeWorkoutFromDay(day, workout.id),
                      tooltip: l10n?.remove ?? 'Usuń',
                      color: theme.colorScheme.error,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.workoutDetail,
                    arguments: workout.id,
                  );
                },
              );
            }),
          // Add workout button
          Padding(
            padding: const EdgeInsets.all(8),
            child: FilledButton.icon(
              onPressed: () => _addWorkoutToDay(day),
              icon: const Icon(Icons.add),
              label: Text(l10n?.addWorkout ?? 'Dodaj trening'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for selecting a workout to add to plan.
class _SelectWorkoutDialog extends StatelessWidget {
  final List<Workout> workouts;

  const _SelectWorkoutDialog({required this.workouts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.selectWorkout ?? 'Wybierz trening'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return ListTile(
              leading: Icon(
                Icons.fitness_center,
                color: theme.colorScheme.primary,
              ),
              title: Text(workout.name),
              subtitle: Text(
                '${workout.difficulty} • ${workout.estimatedDurationMinutes} min',
              ),
              onTap: () {
                Navigator.pop(context, workout);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? 'Anuluj'),
        ),
      ],
    );
  }
}
