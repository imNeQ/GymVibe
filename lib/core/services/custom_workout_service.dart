import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

/// Service for managing custom user-created workouts.
/// Stores custom workouts in local storage using SharedPreferences.
class CustomWorkoutService {
  static const String _key = 'custom_workouts';

  /// Save a custom workout to local storage.
  /// Throws exception if save fails.
  static Future<void> saveWorkout(Workout workout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getWorkouts();
      existing.add(workout);

      final jsonList = existing.map((w) => _workoutToJson(w)).toList();
      final success = await prefs.setString(_key, jsonEncode(jsonList));
      if (!success) {
        throw Exception('Failed to save workout to storage');
      }
    } catch (e) {
      throw Exception('Error saving workout: $e');
    }
  }

  /// Get all custom workouts from local storage.
  static Future<List<Workout>> getWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => _workoutFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get workout by ID.
  static Future<Workout?> getWorkoutById(String id) async {
    final workouts = await getWorkouts();
    try {
      return workouts.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete a custom workout.
  static Future<bool> deleteWorkout(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getWorkouts();
    existing.removeWhere((w) => w.id == id);

    final jsonList = existing.map((w) => _workoutToJson(w)).toList();
    return await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Clear all custom workouts.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Generate a unique ID for a new workout.
  static String generateId() {
    return 'custom_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Convert Workout to JSON.
  static Map<String, dynamic> _workoutToJson(Workout workout) {
    return {
      'id': workout.id,
      'name': workout.name,
      'difficulty': workout.difficulty,
      'estimatedDurationMinutes': workout.estimatedDurationMinutes,
      'description': workout.description,
      'exercises': workout.exercises.map((e) => {
        'name': e.name,
        'sets': e.sets,
        'reps': e.reps,
        'restSeconds': e.restSeconds,
      }).toList(),
    };
  }

  /// Convert JSON to Workout.
  static Workout _workoutFromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int,
      description: json['description'] as String?,
      exercises: (json['exercises'] as List<dynamic>).map((e) {
        return Exercise(
          name: e['name'] as String,
          sets: e['sets'] as int,
          reps: e['reps'] as int,
          restSeconds: e['restSeconds'] as int?,
        );
      }).toList(),
    );
  }
}
