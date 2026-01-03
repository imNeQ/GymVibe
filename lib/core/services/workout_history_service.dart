import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/completed_workout.dart';
import 'mock_data.dart';

/// Service for managing workout history and completed workouts.
/// Stores completed workouts in local storage using SharedPreferences.
class WorkoutHistoryService {
  static const String _key = 'completed_workouts';

  /// Save a completed workout (from predefined workout).
  static Future<void> saveCompletedWorkout(String workoutId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedWorkout = CompletedWorkout(
      workoutId: workoutId,
      completedAt: DateTime.now(),
      activityType: ActivityType.gym, // Default for predefined workouts
    );

    final existing = await getCompletedWorkouts();
    existing.add(completedWorkout);

    final jsonList = existing.map((w) => w.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Save a custom workout to history.
  /// Throws exception if save fails.
  static Future<void> saveCustomWorkout(CompletedWorkout workout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getCompletedWorkouts();
      existing.add(workout);

      final jsonList = existing.map((w) => w.toJson()).toList();
      final success = await prefs.setString(_key, jsonEncode(jsonList));
      if (!success) {
        throw Exception('Failed to save workout to storage');
      }
    } catch (e) {
      throw Exception('Error saving workout: $e');
    }
  }

  /// Update an existing workout in history.
  /// Uses original date/time as identifier to find and replace the workout.
  static Future<void> updateWorkout(
    CompletedWorkout originalWorkout,
    CompletedWorkout updatedWorkout,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getCompletedWorkouts();

    // Find and replace the workout using original date/time as identifier
    final originalDate = originalWorkout.completedAt;
    final index = existing.indexWhere(
      (w) => w.completedAt == originalDate &&
          w.activityType == originalWorkout.activityType &&
          (w.workoutId == originalWorkout.workoutId ||
              (w.workoutId == null && originalWorkout.workoutId == null)),
    );

    if (index != -1) {
      existing[index] = updatedWorkout;
    } else {
      // If not found, just add it (shouldn't happen, but handle gracefully)
      existing.add(updatedWorkout);
    }

    final jsonList = existing.map((w) => w.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Get all completed workouts.
  static Future<List<CompletedWorkout>> getCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => CompletedWorkout.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get number of workouts completed this week (Monday to Sunday).
  static Future<int> getWorkoutsThisWeek() async {
    final completedWorkouts = await getCompletedWorkouts();
    final now = DateTime.now();

    // Get start of current week (Monday at 00:00:00)
    final daysFromMonday = now.weekday - 1;
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysFromMonday));

    // Get end of current week (Sunday at 23:59:59.999)
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));

    return completedWorkouts.where((workout) {
      final completedDate = workout.completedAt;
      // Check if workout was completed within the current week
      return completedDate.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
          completedDate.isBefore(endOfWeek.add(const Duration(milliseconds: 1)));
    }).length;
  }

  /// Get recent completed workouts (last N workouts).
  static Future<List<CompletedWorkout>> getRecentWorkouts({int limit = 5}) async {
    final completedWorkouts = await getCompletedWorkouts();
    // Sort by date descending (most recent first)
    completedWorkouts.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return completedWorkouts.take(limit).toList();
  }

  /// Get total workout time in minutes (sum of durations).
  static Future<int> getTotalWorkoutTime() async {
    final completedWorkouts = await getCompletedWorkouts();
    final workouts = await MockDataService.getWorkouts();
    
    int totalMinutes = 0;
    for (final completed in completedWorkouts) {
      if (completed.durationMinutes != null) {
        // Use actual duration if available
        totalMinutes += completed.durationMinutes!;
      } else if (completed.workoutId != null) {
        // Fall back to estimated duration from workout
        try {
          final workout = workouts.firstWhere(
            (w) => w.id == completed.workoutId,
          );
          totalMinutes += workout.estimatedDurationMinutes;
        } catch (e) {
          // Workout not found, skip
        }
      }
    }
    
    return totalMinutes;
  }

  /// Get total number of completed workouts.
  static Future<int> getTotalWorkouts() async {
    final completedWorkouts = await getCompletedWorkouts();
    return completedWorkouts.length;
  }

  /// Get all unique exercise names from strength workouts.
  static Future<List<String>> getAllExerciseNames() async {
    final completedWorkouts = await getCompletedWorkouts();
    final Set<String> exerciseNames = {};

    for (final workout in completedWorkouts) {
      if (workout.activityType == ActivityType.gym &&
          workout.strengthExercises != null) {
        for (final exercise in workout.strengthExercises!) {
          exerciseNames.add(exercise.name);
        }
      }
    }

    return exerciseNames.toList()..sort();
  }

  /// Get progress history for a specific exercise.
  /// Returns list of (date, maxWeight) pairs sorted by date.
  static Future<List<Map<String, dynamic>>> getExerciseProgress(String exerciseName) async {
    final completedWorkouts = await getCompletedWorkouts();
    final List<Map<String, dynamic>> progress = [];

    for (final workout in completedWorkouts) {
      if (workout.activityType == ActivityType.gym &&
          workout.strengthExercises != null) {
        for (final exercise in workout.strengthExercises!) {
          if (exercise.name == exerciseName) {
            // Find max weight for this exercise on this date
            double? maxWeight;
            for (final set in exercise.sets) {
              if (set.weight != null) {
                if (maxWeight == null || set.weight! > maxWeight) {
                  maxWeight = set.weight;
                }
              }
            }

            if (maxWeight != null) {
              progress.add({
                'date': workout.completedAt,
                'maxWeight': maxWeight,
              });
            }
            break; // Found the exercise, move to next workout
          }
        }
      }
    }

    // Sort by date (oldest first)
    progress.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return progress;
  }

  /// Get total distance (km) from running/cycling workouts in the last 7 days.
  static Future<double> getDistanceLast7Days() async {
    final completedWorkouts = await getCompletedWorkouts();
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    double totalDistance = 0.0;

    for (final workout in completedWorkouts) {
      if ((workout.activityType == ActivityType.running ||
           workout.activityType == ActivityType.cycling) &&
          workout.completedAt.isAfter(sevenDaysAgo) &&
          workout.distance != null) {
        totalDistance += workout.distance!;
      }
    }

    return totalDistance;
  }

  /// Get total time (minutes) from all workouts in the last 7 days.
  static Future<int> getTimeLast7Days() async {
    final completedWorkouts = await getCompletedWorkouts();
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    int totalMinutes = 0;

    for (final workout in completedWorkouts) {
      if (workout.completedAt.isAfter(sevenDaysAgo)) {
        // Use durationSeconds if available, otherwise durationMinutes
        if (workout.durationSeconds != null) {
          totalMinutes += (workout.durationSeconds! / 60).round();
        } else if (workout.durationMinutes != null) {
          totalMinutes += workout.durationMinutes!;
        }
      }
    }

    return totalMinutes;
  }

  /// Delete a specific workout from history.
  /// Uses date, activity type, and workoutId as identifier.
  static Future<bool> deleteWorkout(CompletedWorkout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getCompletedWorkouts();

    // Find and remove the workout
    final originalDate = workout.completedAt;
    final initialLength = existing.length;
    existing.removeWhere(
      (w) => w.completedAt == originalDate &&
          w.activityType == workout.activityType &&
          (w.workoutId == workout.workoutId ||
              (w.workoutId == null && workout.workoutId == null)),
    );
    
    final removed = existing.length < initialLength;

    if (removed) {
      final jsonList = existing.map((w) => w.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
      return true;
    }

    return false;
  }

  /// Clear all completed workouts (for testing/reset).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
