import 'package:flutter/material.dart';
import '../../core/models/exercise.dart';
import '../../core/models/workout.dart';
import '../../core/services/custom_workout_service.dart';
import '../../core/localization/app_localizations.dart';

/// Page for adding a new custom workout.
/// Part of the GymVibe app's workout management feature.
class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedDifficulty = 'Beginner';
  int _estimatedDuration = 30;
  final List<Exercise> _exercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.addWorkout ?? 'Dodaj trening'),
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameField(theme),
                const SizedBox(height: 16),
                _buildDescriptionField(theme),
                const SizedBox(height: 16),
                _buildDifficultySelector(theme),
                const SizedBox(height: 16),
                _buildDurationSelector(theme),
                const SizedBox(height: 24),
                _buildExercisesSection(theme),
                const SizedBox(height: 24),
                _buildSaveButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build name input field.
  Widget _buildNameField(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: l10n?.workoutName ?? 'Nazwa treningu',
        hintText: l10n?.workoutNameHint ?? 'np. Trening siłowy',
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n?.provideWorkoutName ?? 'Podaj nazwę treningu';
        }
        return null;
      },
    );
  }

  /// Build description input field.
  Widget _buildDescriptionField(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: l10n?.workoutDescription ?? 'Opis (opcjonalnie)',
        hintText: l10n?.workoutDescription ?? 'Krótki opis treningu',
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  /// Build difficulty selector.
  Widget _buildDifficultySelector(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.filterByLevel ?? 'Poziom trudności',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'Beginner',
              label: Text(l10n?.beginner ?? 'Początkujący'),
            ),
            ButtonSegment(
              value: 'Intermediate',
              label: Text(l10n?.intermediate ?? 'Średnio zaawansowany'),
            ),
            ButtonSegment(
              value: 'Advanced',
              label: Text(l10n?.advanced ?? 'Zaawansowany'),
            ),
          ],
          selected: {_selectedDifficulty},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _selectedDifficulty = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  /// Build duration selector.
  Widget _buildDurationSelector(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.estimatedDuration ?? 'Szacowany czas (minuty)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _estimatedDuration.toDouble(),
          min: 10,
          max: 120,
          divisions: 22,
          label: '$_estimatedDuration min',
          onChanged: (value) {
            setState(() {
              _estimatedDuration = value.round();
            });
          },
        ),
        Text(
          '$_estimatedDuration ${l10n?.estimatedDurationMinutes ?? 'minut'}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Build exercises section.
  Widget _buildExercisesSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.exercises ?? 'Ćwiczenia',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: Text(l10n?.addExercise ?? 'Dodaj ćwiczenie'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_exercises.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  l10n?.noExercisesMessage ?? 'Brak ćwiczeń. Kliknij "Dodaj ćwiczenie" aby dodać pierwsze ćwiczenie.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          ..._exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            final l10n = AppLocalizations.of(context);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(exercise.name),
                subtitle: Text(
                  '${exercise.sets} ${l10n?.series ?? 'seria'} × ${exercise.reps} ${l10n?.repetitions ?? 'powtórzeń'}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _exercises.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }),
      ],
    );
  }

  /// Add a new exercise.
  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) => _AddExerciseDialog(
        onExerciseAdded: (exercise) {
          setState(() {
            _exercises.add(exercise);
          });
        },
      ),
    );
  }

  /// Build save button.
  Widget _buildSaveButton(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _saveWorkout,
        icon: const Icon(Icons.save),
        label: Text(l10n?.saveWorkout ?? 'Zapisz trening'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  /// Save the workout.
  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.addAtLeastOneExercise ?? 'Dodaj przynajmniej jedno ćwiczenie'),
        ),
      );
      return;
    }

    try {
      final workout = Workout(
        id: CustomWorkoutService.generateId(),
        name: _nameController.text.trim(),
        difficulty: _selectedDifficulty,
        estimatedDurationMinutes: _estimatedDuration,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        exercises: _exercises,
      );

      await CustomWorkoutService.saveWorkout(workout);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.workoutSaved ?? 'Trening został zapisany!'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.error ?? 'Błąd podczas zapisywania treningu'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

/// Dialog for adding a new exercise.
class _AddExerciseDialog extends StatefulWidget {
  final Function(Exercise) onExerciseAdded;

  const _AddExerciseDialog({required this.onExerciseAdded});

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _nameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '12');
  final _restController = TextEditingController(text: '60');

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n?.addExercise ?? 'Dodaj ćwiczenie'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n?.exerciseName ?? 'Nazwa ćwiczenia',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    decoration: InputDecoration(
                      labelText: l10n?.series ?? 'Serie',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    decoration: InputDecoration(
                      labelText: l10n?.repetitions ?? 'Powtórzenia',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _restController,
              decoration: InputDecoration(
                labelText: l10n?.restSeconds ?? 'Odpoczynek (sekundy)',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? 'Anuluj'),
        ),
        FilledButton(
          onPressed: _addExercise,
          child: Text(l10n?.addExercise ?? 'Dodaj'),
        ),
      ],
    );
  }

  void _addExercise() {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.provideExerciseName ?? 'Podaj nazwę ćwiczenia')),
      );
      return;
    }

    final sets = int.tryParse(_setsController.text) ?? 3;
    final reps = int.tryParse(_repsController.text) ?? 12;
    final rest = int.tryParse(_restController.text);

    final exercise = Exercise(
      name: name,
      sets: sets,
      reps: reps,
      restSeconds: rest,
    );

    widget.onExerciseAdded(exercise);
    Navigator.pop(context);
  }
}
