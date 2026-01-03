import 'package:flutter/material.dart';
import '../../core/services/mock_data.dart';
import '../../core/services/workout_history_service.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/models/workout.dart';
import '../../core/models/completed_workout.dart';
import '../../core/utils/translations.dart';
import '../../core/localization/app_localizations.dart';
import '../workouts/workout_history_detail_page.dart';
import '../workouts/workout_timer_page.dart';

/// Dashboard page - main home screen with clear sections.
/// Part of the GymVibe app's core navigation flow.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
  
  /// Create a key that can be used to access the state.
  static GlobalKey<State<DashboardPage>> createKey() {
    return GlobalKey<State<DashboardPage>>();
  }
}

class _DashboardPageState extends State<DashboardPage> {
  Future<int>? _workoutsThisWeekFuture;
  Future<List<CompletedWorkout>>? _recentWorkoutsFuture;
  Future<Map<String, int>>? _statsFuture;
  Future<Map<String, dynamic>>? _cardioStatsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _workoutsThisWeekFuture = WorkoutHistoryService.getWorkoutsThisWeek();
      _recentWorkoutsFuture = WorkoutHistoryService.getRecentWorkouts(limit: 5);
      _statsFuture = _loadStats();
      _cardioStatsFuture = _loadCardioStats();
    });
  }

  Future<Map<String, int>> _loadStats() async {
    final totalTime = await WorkoutHistoryService.getTotalWorkoutTime();
    final totalWorkouts = await WorkoutHistoryService.getTotalWorkouts();
    return {
      'totalTime': totalTime,
      'totalWorkouts': totalWorkouts,
    };
  }

  Future<Map<String, dynamic>> _loadCardioStats() async {
    final distance = await WorkoutHistoryService.getDistanceLast7Days();
    final time = await WorkoutHistoryService.getTimeLast7Days();
    return {
      'distance': distance,
      'time': time,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  
  /// Public method to refresh dashboard data.
  /// Can be called from parent widgets.
  void refresh() {
    if (mounted) {
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingSection(),
              const SizedBox(height: 16),
              const _TodayWorkoutCard(),
              const SizedBox(height: 24),
              _ThisWeekSummarySection(future: _workoutsThisWeekFuture),
              const SizedBox(height: 24),
              _CardioStatsSection(future: _cardioStatsFuture),
              const SizedBox(height: 24),
              _StatsOverviewSection(future: _statsFuture),
              const SizedBox(height: 24),
              _RecentWorkoutsSection(future: _recentWorkoutsFuture),
              const SizedBox(height: 24),
              const _SuggestionsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Greeting section with personalized message.
class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final profileFuture = UserProfileService.getProfile();

    return FutureBuilder(
      future: profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final userName = profile != null
            ? profile.getDisplayName(
                l10n?.completeProfile ?? 'Uzupełnij profil',
              )
            : (l10n?.completeProfile ?? 'Uzupełnij profil');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n?.hello ?? 'Cześć'}, $userName',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n?.readyForWorkout ?? 'Gotowy na dzisiejszy trening?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Today's workout card with start button.
class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todaysWorkoutFuture = MockDataService.getTodaysWorkout();

    return FutureBuilder<Workout?>(
      future: todaysWorkoutFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final todaysWorkout = snapshot.data;
        if (todaysWorkout == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.todayWorkout ?? 'Dzisiejszy trening',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.noWorkoutsInHistory ?? 'Brak dostępnych treningów',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.todayWorkout ?? 'Dzisiejszy trening',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  todaysWorkout.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDifficultyChip(todaysWorkout.difficulty),
                    _buildDurationChip(todaysWorkout.estimatedDurationMinutes),
                  ],
                ),
                if (todaysWorkout.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    todaysWorkout.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutTimerPage(
                            workoutId: todaysWorkout.id,
                            workoutName: todaysWorkout.name,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(AppLocalizations.of(context)?.startWorkout ?? 'Rozpocznij trening'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build difficulty chip with color coding.
  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

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
  Widget _buildDurationChip(int minutes) {
    return Chip(
      avatar: const Icon(Icons.timer, size: 16),
      label: Text('$minutes min'),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

/// This week summary section showing workout progress.
class _ThisWeekSummarySection extends StatelessWidget {
  final Future<int>? future;

  const _ThisWeekSummarySection({this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.thisWeek ?? 'Ten tydzień',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<int>(
          future: future ?? WorkoutHistoryService.getWorkoutsThisWeek(),
          builder: (context, snapshot) {
            final workoutsThisWeek = snapshot.data ?? 0;
            final stats = MockDataService.getStatistics();

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      '$workoutsThisWeek',
                      AppLocalizations.of(context)?.workoutsCount ?? 'Treningi',
                      Icons.fitness_center,
                      theme.colorScheme.primary,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    _buildStatItem(
                      context,
                      '${stats['workoutsThisMonth']}',
                      AppLocalizations.of(context)?.thisMonth ?? 'Ten miesiąc',
                      Icons.calendar_month,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build a stat item widget.
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// Suggestions section with workout recommendations.
class _SuggestionsSection extends StatelessWidget {
  const _SuggestionsSection();

  /// Get smart workout suggestions based on user history.
  /// Returns up to 3 workouts that:
  /// - Haven't been completed recently (last 7 days)
  /// - Include a mix of difficulty levels when possible
  /// - Are randomly shuffled for variety
  Future<List<Workout>> _getSuggestions() async {
    final allWorkouts = await MockDataService.getWorkouts();
    if (allWorkouts.isEmpty) return [];

    // Get recently completed workouts (last 7 days)
    final recentWorkouts = await WorkoutHistoryService.getRecentWorkouts(limit: 20);
    final recentWorkoutIds = recentWorkouts
        .where((w) => w.workoutId != null)
        .map((w) => w.workoutId!)
        .toSet();

    // Filter out recently completed workouts to suggest new ones
    final availableWorkouts = allWorkouts
        .where((w) => !recentWorkoutIds.contains(w.id))
        .toList();

    // If we filtered out too many, use all workouts (user can repeat)
    final workoutsToChooseFrom = availableWorkouts.isNotEmpty
        ? availableWorkouts
        : allWorkouts;

    // Shuffle for variety - different suggestions each time
    final shuffled = List<Workout>.from(workoutsToChooseFrom)..shuffle();

    // Try to get a mix of difficulty levels for variety
    final suggestions = <Workout>[];
    final usedIds = <String>{};
    final difficulties = ['beginner', 'intermediate', 'advanced'];
    
    // First pass: try to get one workout from each difficulty level
    for (final difficulty in difficulties) {
      if (suggestions.length >= 3) break;
      
      final workout = shuffled.firstWhere(
        (w) => w.difficulty.toLowerCase() == difficulty && !usedIds.contains(w.id),
        orElse: () => shuffled.firstWhere(
          (w) => !usedIds.contains(w.id),
          orElse: () => shuffled.isNotEmpty ? shuffled.first : allWorkouts.first,
        ),
      );
      
      if (!usedIds.contains(workout.id)) {
        suggestions.add(workout);
        usedIds.add(workout.id);
      }
    }

    // Second pass: fill remaining slots with random workouts
    while (suggestions.length < 3 && shuffled.isNotEmpty) {
      final available = shuffled.where((w) => !usedIds.contains(w.id)).toList();
      if (available.isEmpty) break;
      
      final workout = available.first;
      suggestions.add(workout);
      usedIds.add(workout.id);
    }

    // Return up to 3 unique suggestions
    return suggestions.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.suggestions ?? 'Sugestie',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: FutureBuilder<List<Workout>>(
            future: _getSuggestions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final suggestions = snapshot.data ?? [];
              
              if (suggestions.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)?.noWorkoutsInHistory ?? 'Brak dostępnych sugestii',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final workout = suggestions[index];
                  return _buildSuggestionCard(context, workout, theme);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build a suggestion card widget.
  Widget _buildSuggestionCard(
    BuildContext context,
    Workout workout,
    ThemeData theme,
  ) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () {
            // Navigate to workout detail
            Navigator.pushNamed(
              context,
              '/workout-detail',
              arguments: workout.id,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  workout.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildDifficultyChip(workout.difficulty),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${workout.estimatedDurationMinutes} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build difficulty chip.
  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(Translations.translateDifficulty(difficulty)),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

/// Cardio stats section showing distance and time from last 7 days.
class _CardioStatsSection extends StatelessWidget {
  final Future<Map<String, dynamic>>? future;

  const _CardioStatsSection({this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'distance': 0.0, 'time': 0};
        final distance = (stats['distance'] as num?)?.toDouble() ?? 0.0;
        final time = stats['time'] as int? ?? 0;

        // Only show if there's at least some data
        if (distance == 0 && time == 0) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_run,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.last7Days ?? 'Ostatnie 7 dni',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      distance > 0 ? distance.toStringAsFixed(1) : '0',
                      AppLocalizations.of(context)?.distanceKm ?? 'Dystans [km]',
                      Icons.straighten,
                      Colors.green,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    _buildStatItem(
                      context,
                      '$time',
                      AppLocalizations.of(context)?.timeMin ?? 'Czas [min]',
                      Icons.timer,
                      Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build a stat item widget.
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Stats overview section showing total time and workouts.
class _StatsOverviewSection extends StatelessWidget {
  final Future<Map<String, int>>? future;

  const _StatsOverviewSection({this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statystyki',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, int>>(
          future: future,
          builder: (context, snapshot) {
            final stats = snapshot.data ?? {'totalTime': 0, 'totalWorkouts': 0};
            final totalTime = stats['totalTime'] ?? 0;
            final totalWorkouts = stats['totalWorkouts'] ?? 0;
            final hours = totalTime ~/ 60;
            final minutes = totalTime % 60;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      hours > 0 ? '${hours}h ${minutes}min' : '${minutes}min',
                      AppLocalizations.of(context)?.totalTime ?? 'Całkowity czas',
                      Icons.timer,
                      Colors.blue,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    _buildStatItem(
                      context,
                      '$totalWorkouts',
                      AppLocalizations.of(context)?.allWorkouts ?? 'Wszystkie treningi',
                      Icons.fitness_center,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build a stat item widget.
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Recent workouts section showing last completed workouts.
class _RecentWorkoutsSection extends StatelessWidget {
  final Future<List<CompletedWorkout>>? future;

  const _RecentWorkoutsSection({this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.recentWorkouts ?? 'Ostatnie treningi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<CompletedWorkout>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final recentWorkouts = snapshot.data ?? [];

            if (recentWorkouts.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)?.noWorkoutsInHistory ?? 'Brak ukończonych treningów. Zacznij trenować!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: recentWorkouts.map((completed) {
                return _buildRecentWorkoutCard(context, completed, theme);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// Build a card for a recent workout.
  Widget _buildRecentWorkoutCard(
    BuildContext context,
    CompletedWorkout completed,
    ThemeData theme,
  ) {
    final workoutFuture = completed.workoutId != null
        ? MockDataService.getWorkoutById(completed.workoutId!)
        : Future<Workout?>.value(null);
    
    return FutureBuilder<Workout?>(
      future: workoutFuture,
      builder: (context, snapshot) {
        final workout = snapshot.data;
        final l10n = AppLocalizations.of(context);
        final workoutName = completed.customName ?? 
            (workout?.name ?? CompletedWorkout.getActivityTypeDisplayName(completed.activityType, l10n: l10n));
        
        final duration = completed.durationMinutes ?? workout?.estimatedDurationMinutes ?? 0;

        final date = completed.completedAt;
        final now = DateTime.now();
        final difference = now.difference(date);
        String dateText;
        
        if (difference.inDays == 0) {
          dateText = l10n?.today ?? 'Dzisiaj';
        } else if (difference.inDays == 1) {
          dateText = l10n?.yesterday ?? 'Wczoraj';
        } else if (difference.inDays < 7) {
          dateText = '${difference.inDays} ${l10n?.daysAgo ?? 'dni temu'}';
        } else {
          dateText = '${date.day}.${date.month}.${date.year}';
        }

        return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutHistoryDetailPage(
                completedWorkout: completed,
              ),
            ),
          );
          // Data will be refreshed automatically via didChangeDependencies
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle,
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
                      workoutName,
                      style: theme.textTheme.titleSmall?.copyWith(
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
                        if (duration > 0) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$duration min',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                        if (completed.distance != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.straighten,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${completed.distance!.toStringAsFixed(1)} km',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (completed.workoutId != null)
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
}
