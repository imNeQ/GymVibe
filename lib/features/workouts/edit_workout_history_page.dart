import 'package:flutter/material.dart';
import '../../core/models/completed_workout.dart';
import '../../core/models/strength_exercise.dart';
import '../../core/models/exercise_set.dart';
import '../../core/services/workout_history_service.dart';
import '../../core/localization/app_localizations.dart';

/// Page for editing an existing workout in history.
class EditWorkoutHistoryPage extends StatefulWidget {
  final CompletedWorkout completedWorkout;

  const EditWorkoutHistoryPage({
    super.key,
    required this.completedWorkout,
  });

  @override
  State<EditWorkoutHistoryPage> createState() => _EditWorkoutHistoryPageState();
}

class _EditWorkoutHistoryPageState extends State<EditWorkoutHistoryPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late ActivityType _selectedActivityType;
  final _customNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _durationMinutesController = TextEditingController();
  final _durationSecondsController = TextEditingController();
  final _distanceController = TextEditingController();
  final _notesController = TextEditingController();
  late List<StrengthExercise> _strengthExercises;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  /// Initialize form fields with existing workout data.
  void _initializeFields() {
    final workout = widget.completedWorkout;
    _selectedDate = workout.completedAt;
    _selectedActivityType = workout.activityType;
    _customNameController.text = workout.customName ?? '';
    
    if (workout.durationSeconds != null) {
      final totalSeconds = workout.durationSeconds!;
      _durationMinutesController.text = (totalSeconds ~/ 60).toString();
      _durationSecondsController.text = (totalSeconds % 60).toString();
    } else if (workout.durationMinutes != null) {
      _durationController.text = workout.durationMinutes.toString();
      _durationMinutesController.text = workout.durationMinutes.toString();
      _durationSecondsController.text = '0';
    }
    
    _distanceController.text = workout.distance?.toStringAsFixed(1) ?? '';
    _notesController.text = workout.notes ?? '';
    _strengthExercises = workout.strengthExercises != null
        ? List.from(workout.strengthExercises!)
        : [];
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _durationController.dispose();
    _durationMinutesController.dispose();
    _durationSecondsController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.editWorkout ?? 'Edytuj trening'),
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSelector(theme),
                const SizedBox(height: 24),
                _buildActivityTypeSelector(theme),
                const SizedBox(height: 24),
                _buildBasicFields(theme),
                if (_selectedActivityType == ActivityType.gym) ...[
                  const SizedBox(height: 24),
                  _buildStrengthExercisesSection(theme),
                ],
                const SizedBox(height: 24),
                _buildAdvancedFields(theme),
                const SizedBox(height: 24),
                _buildSaveButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build date selector.
  Widget _buildDateSelector(ThemeData theme) {
    final dateText = '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.workoutDate ?? 'Data treningu',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                  locale: const Locale('pl', 'PL'),
                );
                if (picked != null && mounted) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          dateText,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build activity type selector.
  Widget _buildActivityTypeSelector(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppLocalizations.of(context)?.activityType ?? 'Typ aktywności',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          RadioGroup<ActivityType>(
            groupValue: _selectedActivityType,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedActivityType = value;
                });
              }
            },
            child: Column(
              children: [
                const Divider(height: 1),
                RadioListTile<ActivityType>(
                  title: Text(l10n?.gym ?? 'Siłownia'),
                  value: ActivityType.gym,
                ),
                const Divider(height: 1),
                RadioListTile<ActivityType>(
                  title: const Text('Bieganie'),
                  value: ActivityType.running,
                ),
                const Divider(height: 1),
                RadioListTile<ActivityType>(
                  title: Text(l10n?.cycling ?? 'Rower'),
                  value: ActivityType.cycling,
                ),
                const Divider(height: 1),
                RadioListTile<ActivityType>(
                  title: Text(l10n?.swimming ?? 'Pływanie'),
                  value: ActivityType.swimming,
                ),
                const Divider(height: 1),
                RadioListTile<ActivityType>(
                  title: Text(l10n?.other ?? 'Inne'),
                  value: ActivityType.other,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build strength exercises section (for gym workouts).
  Widget _buildStrengthExercisesSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)?.exercises ?? 'Ćwiczenia',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addStrengthExercise,
                  icon: const Icon(Icons.add),
                  label: Text(l10n?.addExercise ?? 'Dodaj ćwiczenie'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_strengthExercises.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Brak ćwiczeń. Kliknij "Dodaj ćwiczenie" aby dodać pierwsze ćwiczenie.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ..._strengthExercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return _buildExerciseCard(context, exercise, index, theme);
              }),
          ],
        ),
      ),
    );
  }

  /// Build card for a strength exercise.
  Widget _buildExerciseCard(
    BuildContext context,
    StrengthExercise exercise,
    int index,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          exercise.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${exercise.sets.length} ${exercise.sets.length == 1 ? (l10n?.set ?? 'seria') : (l10n?.sets ?? 'serii')}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _strengthExercises.removeAt(index);
            });
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...exercise.sets.asMap().entries.map((setEntry) {
                  final setIndex = setEntry.key;
                  final set = setEntry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          'Seria ${setIndex + 1}:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (set.weight != null)
                          Text(
                            '${set.weight!.toStringAsFixed(1)} kg',
                            style: theme.textTheme.bodyMedium,
                          )
                        else
                          Text(
                            'bez ciężaru',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          '× ${set.reps} powtórzeń',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => _editSet(exercise, setIndex),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () => _removeSet(exercise, setIndex),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _addSetToExercise(exercise),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n?.addSet ?? 'Dodaj serię'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Add a new strength exercise.
  void _addStrengthExercise() {
    showDialog(
      context: context,
      builder: (context) => _AddExerciseDialog(
        onExerciseAdded: (exerciseName) {
          setState(() {
            _strengthExercises.add(StrengthExercise(
              name: exerciseName,
              sets: [],
            ));
          });
        },
      ),
    );
  }

  /// Add a set to an exercise.
  void _addSetToExercise(StrengthExercise exercise) {
    final index = _strengthExercises.indexOf(exercise);
    showDialog(
      context: context,
      builder: (context) => _AddSetDialog(
        onSetAdded: (set) {
          setState(() {
            final updatedSets = List<ExerciseSet>.from(exercise.sets)..add(set);
            _strengthExercises[index] = StrengthExercise(
              name: exercise.name,
              sets: updatedSets,
            );
          });
        },
      ),
    );
  }

  /// Edit a set in an exercise.
  void _editSet(StrengthExercise exercise, int setIndex) {
    final index = _strengthExercises.indexOf(exercise);
    final set = exercise.sets[setIndex];
    showDialog(
      context: context,
      builder: (context) => _AddSetDialog(
        initialWeight: set.weight,
        initialReps: set.reps,
        onSetAdded: (updatedSet) {
          setState(() {
            final updatedSets = List<ExerciseSet>.from(exercise.sets);
            updatedSets[setIndex] = updatedSet;
            _strengthExercises[index] = StrengthExercise(
              name: exercise.name,
              sets: updatedSets,
            );
          });
        },
      ),
    );
  }

  /// Remove a set from an exercise.
  void _removeSet(StrengthExercise exercise, int setIndex) {
    final index = _strengthExercises.indexOf(exercise);
    setState(() {
      final updatedSets = List<ExerciseSet>.from(exercise.sets)..removeAt(setIndex);
      _strengthExercises[index] = StrengthExercise(
        name: exercise.name,
        sets: updatedSets,
      );
    });
  }

  /// Build basic fields (name for custom activities).
  Widget _buildBasicFields(ThemeData theme) {
    if (_selectedActivityType == ActivityType.other) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nazwa aktywności',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customNameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwa',
                  hintText: 'np. Joga, Pilates',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Build advanced fields (optional).
  Widget _buildAdvancedFields(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Dodatkowe informacje (opcjonalnie)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedActivityType == ActivityType.running ||
                _selectedActivityType == ActivityType.cycling ||
                _selectedActivityType == ActivityType.swimming) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationMinutesController,
                      decoration: const InputDecoration(
                        labelText: 'Minuty',
                        hintText: 'np. 30',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _durationSecondsController,
                      decoration: const InputDecoration(
                        labelText: 'Sekundy',
                        hintText: 'np. 45',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distanceController,
                decoration: InputDecoration(
                  labelText: l10n?.distanceKmLabel ?? 'Dystans (km)',
                  hintText: 'np. 5.5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
              ),
              if (_calculatePace() != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tempo: ${_formatPace(_calculatePace()!)} min/km',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: l10n?.durationMinutesLabel ?? 'Czas trwania (minuty)',
                  hintText: 'np. 45',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n?.notes ?? 'Notatki (opcjonalnie)',
                hintText: l10n?.notesHint ?? 'np. samopoczucie, kontuzja, uwagi do treningu',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              minLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate pace from distance and time.
  double? _calculatePace() {
    final distance = _distanceController.text.trim().isEmpty
        ? null
        : double.tryParse(_distanceController.text.replaceAll(',', '.'));
    
    final minutes = _durationMinutesController.text.trim().isEmpty
        ? 0
        : (int.tryParse(_durationMinutesController.text) ?? 0);
    final seconds = _durationSecondsController.text.trim().isEmpty
        ? 0
        : (int.tryParse(_durationSecondsController.text) ?? 0);
    
    final totalSeconds = minutes * 60 + seconds;
    
    if (distance == null || distance <= 0 || totalSeconds <= 0) {
      return null;
    }
    
    return CompletedWorkout.calculatePace(distance, totalSeconds);
  }

  /// Format pace for display.
  String _formatPace(double pace) {
    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Build save button.
  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _saveWorkout,
        icon: const Icon(Icons.save),
        label: const Text('Zapisz zmiany'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  /// Save the updated workout.
  void _saveWorkout() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    
    if (_selectedActivityType == ActivityType.other &&
        (_customNameController.text.trim().isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Podaj nazwę aktywności'),
        ),
      );
      return;
    }

    int? durationMinutes;
    int? durationSeconds;
    double? distance;
    double? pace;

    if (_selectedActivityType == ActivityType.running ||
        _selectedActivityType == ActivityType.cycling ||
        _selectedActivityType == ActivityType.swimming) {
      final minutes = _durationMinutesController.text.trim().isEmpty
          ? 0
          : (int.tryParse(_durationMinutesController.text) ?? 0);
      final seconds = _durationSecondsController.text.trim().isEmpty
          ? 0
          : (int.tryParse(_durationSecondsController.text) ?? 0);
      
      if (minutes > 0 || seconds > 0) {
        durationMinutes = minutes;
        durationSeconds = seconds;
      }
      
      distance = _distanceController.text.trim().isEmpty
          ? null
          : double.tryParse(_distanceController.text.replaceAll(',', '.'));
      
      if (distance != null && (durationMinutes != null || durationSeconds != null)) {
        final totalSeconds = (durationMinutes ?? 0) * 60 + (durationSeconds ?? 0);
        pace = CompletedWorkout.calculatePace(distance, totalSeconds);
      }
    } else {
      durationMinutes = _durationController.text.trim().isEmpty
          ? null
          : int.tryParse(_durationController.text);
    }

    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    final customName = _customNameController.text.trim().isEmpty
        ? null
        : _customNameController.text.trim();

    final updatedWorkout = CompletedWorkout(
      workoutId: widget.completedWorkout.workoutId,
      completedAt: _selectedDate,
      activityType: _selectedActivityType,
      customName: customName,
      durationMinutes: durationMinutes,
      durationSeconds: durationSeconds,
      distance: distance,
      pace: pace,
      notes: notes,
      strengthExercises: _selectedActivityType == ActivityType.gym && _strengthExercises.isNotEmpty
          ? _strengthExercises
          : null,
    );

    await WorkoutHistoryService.updateWorkout(
      widget.completedWorkout,
      updatedWorkout,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.workoutUpdated ?? 'Trening został zaktualizowany!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true); // Return true to indicate update
    }
  }
}

/// Dialog for adding a new exercise.
class _AddExerciseDialog extends StatefulWidget {
  final Function(String) onExerciseAdded;

  const _AddExerciseDialog({required this.onExerciseAdded});

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n?.addExercise ?? 'Dodaj ćwiczenie'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: l10n?.exerciseName ?? 'Nazwa ćwiczenia',
          hintText: l10n?.exerciseNameHint ?? 'np. Przysiad, Wyciskanie na ławce',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              widget.onExerciseAdded(name);
              Navigator.pop(context);
            }
          },
          child: const Text('Dodaj'),
        ),
      ],
    );
  }
}

/// Dialog for adding/editing a set.
class _AddSetDialog extends StatefulWidget {
  final Function(ExerciseSet) onSetAdded;
  final double? initialWeight;
  final int? initialReps;

  const _AddSetDialog({
    required this.onSetAdded,
    this.initialWeight,
    this.initialReps,
  });

  @override
  State<_AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<_AddSetDialog> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialWeight != null) {
      _weightController.text = widget.initialWeight!.toStringAsFixed(1);
    }
    if (widget.initialReps != null) {
      _repsController.text = widget.initialReps!.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n?.addSet ?? 'Dodaj serię'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _weightController,
            decoration: InputDecoration(
              labelText: l10n?.weight ?? 'Ciężar (kg)',
              hintText: 'np. 60.5',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _repsController,
            decoration: InputDecoration(
              labelText: l10n?.reps ?? 'Powtórzenia',
              hintText: 'np. 10',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            autofocus: widget.initialReps == null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () {
            final weight = _weightController.text.trim().isEmpty
                ? null
                : double.tryParse(_weightController.text.replaceAll(',', '.'));
            final reps = int.tryParse(_repsController.text) ?? 0;

            if (reps > 0) {
              widget.onSetAdded(ExerciseSet(
                weight: weight,
                reps: reps,
              ));
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n?.provideReps ?? 'Podaj liczbę powtórzeń')),
              );
            }
          },
          child: const Text('Dodaj'),
        ),
      ],
    );
  }
}
