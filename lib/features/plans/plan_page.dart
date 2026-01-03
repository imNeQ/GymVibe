import 'package:flutter/material.dart';
import '../../core/services/mock_data.dart';
import '../../core/services/weekly_plan_service.dart';
import '../../core/models/workout.dart';
import '../../core/models/workout_plan.dart';
import '../../core/routes.dart';
import '../../core/utils/translations.dart';
import '../../core/localization/app_localizations.dart';
import 'edit_plan_page.dart';

/// Weekly plan page - displays Monday-Sunday workout schedule.
/// Part of the GymVibe app's planning feature.
class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  Future<List<Workout>>? _workoutsFuture;
  Future<WorkoutPlan>? _planFuture;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = MockDataService.getWorkouts();
    _planFuture = WeeklyPlanService.getPlan();
    // Don't access Localizations.localeOf(context) here - it's not available yet
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when locale changes (language switch)
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

  void _refreshPlan() {
    setState(() {
      _planFuture = WeeklyPlanService.getPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditPlanPage(),
                      ),
                    );
                    // Refresh plan if changes were saved
                    if (result == true) {
                      _refreshPlan();
                    }
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(AppLocalizations.of(context)?.edit ?? 'Edytuj'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<WorkoutPlan>(
              future: _planFuture,
              builder: (context, planSnapshot) {
                if (planSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final plan = planSnapshot.data ?? MockDataService.getWeeklyPlan();

                return FutureBuilder<List<Workout>>(
                  future: _workoutsFuture,
                  builder: (context, workoutsSnapshot) {
                    if (workoutsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final workouts = workoutsSnapshot.data ?? [];

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final day = index + 1; // 1-7
                        final workoutIds = plan.getWorkoutsForDay(day);
                        final dayWorkouts = workoutIds
                            .map((id) {
                              try {
                                return workouts.firstWhere((w) => w.id == id);
                              } catch (e) {
                                return null;
                              }
                            })
                            .where((w) => w != null)
                            .cast<Workout>()
                            .toList();

                        return _buildDayCard(
                          context,
                          dayNames[index],
                          dayWorkouts,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build a card widget for a single day in the weekly plan.
  Widget _buildDayCard(
    BuildContext context,
    String dayName,
    List<Workout> workouts,
  ) {
    final theme = Theme.of(context);
    final isRestDay = workouts.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isRestDay
            ? null
            : () {
                // Navigate to first workout if multiple
                if (workouts.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.workoutDetail,
                    arguments: workouts.first.id,
                  );
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
                  color: isRestDay
                      ? Colors.grey.withValues(alpha: 0.1)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isRestDay ? Icons.hotel : Icons.fitness_center,
                  color: isRestDay
                      ? Colors.grey
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isRestDay)
                      Text(
                        AppLocalizations.of(context)?.restDay ?? 'Dzień odpoczynku',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      )
                    else ...[
                      ...workouts.asMap().entries.map((entry) {
                        final workout = entry.value;
                        final isLast = entry.key == workouts.length - 1;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!isLast) const SizedBox(height: 4),
                            if (isLast) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _buildDifficultyChip(workout.difficulty),
                                  _buildDurationChip(workout.estimatedDurationMinutes, theme),
                                ],
                              ),
                            ],
                          ],
                        );
                      }),
                      if (workouts.length > 1) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+ ${workouts.length - 1} ${workouts.length == 2 ? (AppLocalizations.of(context)?.workout ?? 'trening') : (AppLocalizations.of(context)?.workoutsPlural ?? 'treningów')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (!isRestDay)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
  Widget _buildDifficultyChip(String difficulty) {
    final color = _getDifficultyColor(difficulty);
    return Chip(
      label: Text(Translations.translateDifficulty(difficulty)),
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
        size: 14,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      label: Text('$minutes min'),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
