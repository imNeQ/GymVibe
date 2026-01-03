import 'package:flutter/material.dart';
import '../../core/services/workout_history_service.dart';
import '../../core/localization/app_localizations.dart';
import 'exercise_progress_page.dart';

/// Statistics page - displays workout progress and analytics.
/// Part of the GymVibe app's analytics feature.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
  
  /// Create a key that can be used to access the state.
  static GlobalKey<State<StatisticsPage>> createKey() {
    return GlobalKey<State<StatisticsPage>>();
  }
}

class _StatisticsPageState extends State<StatisticsPage> {
  Future<Map<String, int>>? _statsFuture;
  Future<List<Map<String, dynamic>>>? _weeklyStatsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = _loadStatistics();
      _weeklyStatsFuture = _loadWeeklyStats();
    });
  }
  
  /// Public method to refresh statistics data.
  /// Can be called from parent widgets.
  void refresh() {
    if (mounted) {
      _loadStats();
    }
  }
  
  /// Format workout count with proper pluralization.
  String _formatWorkoutCount(int count, AppLocalizations? l10n) {
    if (l10n != null) {
      return '$count ${l10n.getWorkoutPlural(count)}';
    }
    // Fallback if localization is not available
    if (count == 1) {
      return '$count trening';
    } else if (count >= 2 && count <= 4) {
      return '$count treningi';
    } else {
      return '$count treningów';
    }
  }

  Future<Map<String, int>> _loadStatistics() async {
    final workoutsThisWeek = await WorkoutHistoryService.getWorkoutsThisWeek();
    final totalWorkouts = await WorkoutHistoryService.getTotalWorkouts();
    
    // Calculate workouts this month (compare dates only, ignore time)
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final allWorkouts = await WorkoutHistoryService.getCompletedWorkouts();
    final workoutsThisMonth = allWorkouts.where((w) {
      final workoutDay = DateTime(w.completedAt.year, w.completedAt.month, w.completedAt.day);
      return workoutDay.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
             workoutDay.isBefore(DateTime(now.year, now.month + 1, 1));
    }).length;
    
    return {
      'workoutsThisWeek': workoutsThisWeek,
      'workoutsThisMonth': workoutsThisMonth,
      'totalWorkouts': totalWorkouts,
    };
  }

  Future<List<Map<String, dynamic>>> _loadWeeklyStats() async {
    final allWorkouts = await WorkoutHistoryService.getCompletedWorkouts();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final Map<String, int> weeklyData = {};
    
    // Get last 7 days (including today)
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = '${date.day}.${date.month}';
      weeklyData[dateKey] = 0;
    }
    
    // Count workouts per day (compare dates only, ignore time)
    for (final workout in allWorkouts) {
      final workoutDate = workout.completedAt;
      final workoutDay = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);
      final daysDiff = today.difference(workoutDay).inDays;
      
      // Include workouts from last 7 days (0-6 days ago, including today)
      if (daysDiff >= 0 && daysDiff < 7) {
        final dateKey = '${workoutDate.day}.${workoutDate.month}';
        weeklyData[dateKey] = (weeklyData[dateKey] ?? 0) + 1;
      }
    }
    
    return weeklyData.entries.map((e) => {
      'date': e.key,
      'count': e.value,
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, int>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final stats = snapshot.data ?? {
                  'workoutsThisWeek': 0,
                  'workoutsThisMonth': 0,
                  'totalWorkouts': 0,
                };
                
                return Column(
                  children: [
                    _buildStatCard(
                      context,
                      l10n?.workoutsThisWeek ?? 'Treningi w tym tygodniu',
                      _formatWorkoutCount(stats['workoutsThisWeek'] ?? 0, l10n),
                      Icons.calendar_today,
                      theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      context,
                      l10n?.workoutsThisMonth ?? 'Treningi w tym miesiącu',
                      _formatWorkoutCount(stats['workoutsThisMonth'] ?? 0, l10n),
                      Icons.calendar_month,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      context,
                      l10n?.allWorkoutsCount ?? 'Wszystkie treningi',
                      _formatWorkoutCount(stats['totalWorkouts'] ?? 0, l10n),
                      Icons.fitness_center,
                      Colors.orange,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExerciseProgressPage(),
                    ),
                  );
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
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.exerciseProgress ?? 'Progres ćwiczenia',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.viewMaxWeightHistory ?? 'Zobacz historię maksymalnych ciężarów',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.chartsAndAnalytics ?? 'Wykresy i analityka',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _weeklyStatsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        final weeklyData = snapshot.data ?? [];
                        final maxCount = weeklyData.isEmpty 
                            ? 1 
                            : weeklyData.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b);
                        
                        if (maxCount == 0) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    size: 48,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n?.noDataForChart ?? 'Brak danych do wyświetlenia',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        return Container(
                          height: 200,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: weeklyData.map((data) {
                                    final count = data['count'] as int;
                                    final date = data['date'] as String;
                                    final height = maxCount > 0 ? (count / maxCount) : 0.0;
                                    
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Tooltip(
                                              message: _formatWorkoutCount(count, l10n),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary,
                                                  borderRadius: const BorderRadius.vertical(
                                                    top: Radius.circular(4),
                                                  ),
                                                ),
                                                height: height * 120,
                                                width: double.infinity,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              date,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontSize: 10,
                                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n?.last7Days ?? 'Ostatnie 7 dni',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  /// Build a statistics card widget.
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
