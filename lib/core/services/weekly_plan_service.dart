import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_plan.dart';
import 'mock_data.dart';

/// Service for managing weekly workout plan.
/// Stores plan in local storage using SharedPreferences.
class WeeklyPlanService {
  static const String _key = 'weekly_plan';

  /// Get weekly plan from local storage or return default mock plan.
  static Future<WorkoutPlan> getPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      // Return default mock plan if no saved plan exists
      return MockDataService.getWeeklyPlan();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return WorkoutPlan.fromJson(json);
    } catch (e) {
      // Return default plan on error
      return MockDataService.getWeeklyPlan();
    }
  }

  /// Save weekly plan to local storage.
  static Future<void> savePlan(WorkoutPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(plan.toJson());
    await prefs.setString(_key, jsonString);
  }

  /// Clear weekly plan (reset to default).
  static Future<void> clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
