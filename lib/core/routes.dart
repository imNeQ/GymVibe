import 'package:flutter/material.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/workouts/workout_list_page.dart';
import '../features/workouts/workout_detail_page.dart';
import '../features/plans/plan_page.dart';
import '../features/statistics/statistics_page.dart';
import '../features/profile/profile_page.dart';

/// App routing configuration using Navigator 1.0 with named routes.
/// Defines all route paths and route builders for the GymVibe app.
class AppRoutes {
  static const String dashboard = '/';
  static const String workouts = '/workouts';
  static const String workoutDetail = '/workout-detail';
  static const String plan = '/plan';
  static const String statistics = '/statistics';
  static const String profile = '/profile';

  /// Generate routes map for MaterialApp.
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      dashboard: (context) => const DashboardPage(),
      workouts: (context) => const WorkoutListPage(),
      plan: (context) => const PlanPage(),
      statistics: (context) => const StatisticsPage(),
      profile: (context) => const ProfilePage(),
    };
  }

  /// Generate route for workout detail page with arguments.
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == workoutDetail) {
      final args = settings.arguments;
      if (args is String) {
        // args is workoutId
        return MaterialPageRoute(
          builder: (context) => WorkoutDetailPage(workoutId: args),
        );
      }
    }
    return null;
  }
}

