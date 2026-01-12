import 'package:flutter/material.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/workouts/workout_list_page.dart';
import '../../features/plans/plan_page.dart';
import '../../features/statistics/statistics_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/workouts/add_workout_history_page.dart';
import '../../core/localization/app_localizations.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  final GlobalKey<State<DashboardPage>> _dashboardKey = GlobalKey<State<DashboardPage>>();
  final GlobalKey<State<WorkoutListPage>> _workoutListKey = GlobalKey<State<WorkoutListPage>>();
  final GlobalKey<State<StatisticsPage>> _statisticsKey = GlobalKey<State<StatisticsPage>>();

  late final List<Widget> _pages = [
    DashboardPage(key: _dashboardKey),
    WorkoutListPage(key: _workoutListKey),
    const PlanPage(),
    StatisticsPage(key: _statisticsKey),
    const ProfilePage(),
  ];

  String _getTitle(int index, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (index) {
      case 0:
        return 'GymVibe';
      case 1:
        return l10n?.workouts ?? 'Workouts';
      case 2:
        return l10n?.plan ?? 'Plan';
      case 3:
        return l10n?.statistics ?? 'Statistics';
      case 4:
        return l10n?.profile ?? 'Profile';
      default:
        return 'GymVibe';
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex, context)),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddWorkoutHistoryPage(),
                  ),
                );
                // Refresh dashboard and statistics after returning from add workout page
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final dashboardState = _dashboardKey.currentState;
                  if (dashboardState != null) {
                    try {
                      (dashboardState as dynamic).refresh();
                    } catch (e) {
                      // Method doesn't exist, ignore
                    }
                  }
                  final statisticsState = _statisticsKey.currentState;
                  if (statisticsState != null) {
                    try {
                      (statisticsState as dynamic).refresh();
                    } catch (e) {
                      // Method doesn't exist, ignore
                    }
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)?.addWorkout ?? 'Add Workout'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Refresh dashboard when returning to it
              if (index == 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final state = _dashboardKey.currentState;
                  // Use dynamic to call refresh method
                  if (state != null) {
                    try {
                      (state as dynamic).refresh();
                    } catch (e) {
                      // Method doesn't exist, ignore
                    }
                  }
                });
              }
              // Refresh workout list when returning to it
              if (index == 1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final state = _workoutListKey.currentState;
                  if (state != null) {
                    try {
                      (state as dynamic)._loadWorkouts();
                    } catch (e) {
                      // Method doesn't exist, ignore
                    }
                  }
                });
              }
              // Refresh statistics when returning to it
              if (index == 3) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final state = _statisticsKey.currentState;
                  if (state != null) {
                    try {
                      (state as dynamic).refresh();
                    } catch (e) {
                      // Method doesn't exist, ignore
                    }
                  }
                });
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n?.home ?? 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.fitness_center_outlined),
                selectedIcon: const Icon(Icons.fitness_center),
                label: l10n?.workouts ?? 'Workouts',
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_today_outlined),
                selectedIcon: const Icon(Icons.calendar_today),
                label: l10n?.plan ?? 'Plan',
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: l10n?.statistics ?? 'Statistics',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: l10n?.profile ?? 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }
}

