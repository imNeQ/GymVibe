import 'package:flutter/material.dart';
import '../../core/services/workout_history_service.dart';
import '../../core/localization/app_localizations.dart';

/// Page for selecting an exercise to view progress.
class ExerciseProgressPage extends StatefulWidget {
  const ExerciseProgressPage({super.key});

  @override
  State<ExerciseProgressPage> createState() => _ExerciseProgressPageState();
}

class _ExerciseProgressPageState extends State<ExerciseProgressPage> {
  Future<List<String>>? _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = WorkoutHistoryService.getAllExerciseNames();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.exerciseProgress ?? 'Progres ćwiczenia'),
      ),
      body: FutureBuilder<List<String>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('${AppLocalizations.of(context)?.error ?? 'Błąd'}: ${snapshot.error}'),
            );
          }

          final exercises = snapshot.data ?? [];

          if (exercises.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.noStrengthExercises ?? 'Brak ćwiczeń siłowych w historii',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)?.addStrengthWorkout ?? 'Dodaj trening siłowy z ćwiczeniami, aby zobaczyć progres',
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
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exerciseName = exercises[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.fitness_center,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(exerciseName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseProgressDetailPage(
                          exerciseName: exerciseName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Page showing progress history for a specific exercise.
class ExerciseProgressDetailPage extends StatefulWidget {
  final String exerciseName;

  const ExerciseProgressDetailPage({
    super.key,
    required this.exerciseName,
  });

  @override
  State<ExerciseProgressDetailPage> createState() => _ExerciseProgressDetailPageState();
}

class _ExerciseProgressDetailPageState extends State<ExerciseProgressDetailPage> {
  Future<List<Map<String, dynamic>>>? _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = WorkoutHistoryService.getExerciseProgress(widget.exerciseName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('${AppLocalizations.of(context)?.error ?? 'Błąd'}: ${snapshot.error}'),
            );
          }

          final progress = snapshot.data ?? [];

          if (progress.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.noWeightData ?? 'Brak danych o ciężarze',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)?.addWorkoutsWithWeight ?? 'Dodaj treningi z tym ćwiczeniem i podaj ciężar, aby zobaczyć progres',
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
            itemCount: progress.length,
            itemBuilder: (context, index) {
              final entry = progress[index];
              final date = entry['date'] as DateTime;
              final maxWeight = entry['maxWeight'] as double;
              final dateText = '${date.day}.${date.month}.${date.year}';

              // Check if this is a new max (compared to previous entry)
              bool isNewMax = false;
              if (index > 0) {
                final previousMax = progress[index - 1]['maxWeight'] as double;
                isNewMax = maxWeight > previousMax;
              } else {
                isNewMax = true; // First entry is always a "max"
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isNewMax
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isNewMax ? Icons.trending_up : Icons.fitness_center,
                      color: isNewMax
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  title: Text(
                    dateText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)?.maxWeight ?? 'Maksymalny ciężar',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: Text(
                    '${maxWeight.toStringAsFixed(1)} kg',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isNewMax
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
