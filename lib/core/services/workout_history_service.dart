import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/completed_workout.dart';
import '../models/strength_exercise.dart';
import '../models/exercise_set.dart';
import 'mock_data.dart';

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

  static Future<List<CompletedWorkout>> getCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      // LOCAL TEST DATA - tylko dla lokalnego testowania screenów
      return _getTestData();
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

  // LOCAL TEST DATA - tylko dla lokalnego testowania screenów, nie commitować
  static List<CompletedWorkout> _getTestData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return [
      // Treningi z ostatnich 7 dni (dla wykresu) - rozłożone równomiernie
      CompletedWorkout(
        workoutId: '1',
        completedAt: today.subtract(const Duration(days: 6)).add(const Duration(hours: 18)), // 6 dni temu
        activityType: ActivityType.gym,
        durationMinutes: 35,
        strengthExercises: [
          StrengthExercise(
            name: 'Bodyweight Squats',
            sets: [
              ExerciseSet(weight: null, reps: 12),
              ExerciseSet(weight: null, reps: 12),
              ExerciseSet(weight: null, reps: 12),
            ],
          ),
          StrengthExercise(
            name: 'Push-ups',
            sets: [
              ExerciseSet(weight: null, reps: 8),
              ExerciseSet(weight: null, reps: 8),
              ExerciseSet(weight: null, reps: 8),
            ],
          ),
        ],
      ),
      CompletedWorkout(
        customName: 'Bieg poranny',
        completedAt: today.subtract(const Duration(days: 5)).add(const Duration(hours: 7)), // 5 dni temu
        activityType: ActivityType.running,
        durationSeconds: 1500, // 25 minut
        distance: 4.8,
        pace: CompletedWorkout.calculatePace(4.8, 1500),
      ),
      CompletedWorkout(
        workoutId: '2',
        completedAt: today.subtract(const Duration(days: 4)).add(const Duration(hours: 14)), // 4 dni temu
        activityType: ActivityType.gym,
        durationMinutes: 45,
        strengthExercises: [
          StrengthExercise(
            name: 'Bench Press',
            sets: [
              ExerciseSet(weight: 60.0, reps: 8),
              ExerciseSet(weight: 65.0, reps: 6),
              ExerciseSet(weight: 70.0, reps: 5),
            ],
          ),
          StrengthExercise(
            name: 'Overhead Press',
            sets: [
              ExerciseSet(weight: 40.0, reps: 8),
              ExerciseSet(weight: 42.5, reps: 6),
              ExerciseSet(weight: 45.0, reps: 5),
            ],
          ),
        ],
      ),
      CompletedWorkout(
        workoutId: '4',
        completedAt: today.subtract(const Duration(days: 3)).add(const Duration(hours: 10)), // 3 dni temu
        activityType: ActivityType.gym,
        durationMinutes: 30,
      ),
      CompletedWorkout(
        workoutId: '5',
        completedAt: today.subtract(const Duration(days: 2)).add(const Duration(hours: 16)), // 2 dni temu
        activityType: ActivityType.gym,
        durationMinutes: 25,
      ),
      CompletedWorkout(
        customName: 'Bieg w parku',
        completedAt: today.subtract(const Duration(days: 1)).add(const Duration(hours: 8)), // Wczoraj
        activityType: ActivityType.running,
        durationSeconds: 1800, // 30 minut
        distance: 5.2,
        pace: CompletedWorkout.calculatePace(5.2, 1800),
      ),
      CompletedWorkout(
        workoutId: '1',
        completedAt: today.add(const Duration(hours: 10)), // Dzisiaj
        activityType: ActivityType.gym,
        durationMinutes: 20,
      ),
      // Treningi z tego miesiąca (ale poza tym tygodniem)
      CompletedWorkout(
        workoutId: '6',
        completedAt: now.subtract(const Duration(days: 8)),
        activityType: ActivityType.gym,
        durationMinutes: 50,
        strengthExercises: [
          StrengthExercise(
            name: 'Bench Press',
            sets: [
              ExerciseSet(weight: 65.0, reps: 8),
              ExerciseSet(weight: 70.0, reps: 6),
              ExerciseSet(weight: 75.0, reps: 4),
            ],
          ),
        ],
      ),
      CompletedWorkout(
        workoutId: '3',
        completedAt: now.subtract(const Duration(days: 10)),
        activityType: ActivityType.gym,
        durationMinutes: 40,
        strengthExercises: [
          StrengthExercise(
            name: 'Barbell Squats',
            sets: [
              ExerciseSet(weight: 80.0, reps: 8),
              ExerciseSet(weight: 85.0, reps: 6),
              ExerciseSet(weight: 90.0, reps: 5),
            ],
          ),
        ],
      ),
      CompletedWorkout(
        workoutId: '1',
        completedAt: now.subtract(const Duration(days: 12)),
        activityType: ActivityType.gym,
        durationMinutes: 30,
      ),
      CompletedWorkout(
        customName: 'Jazda rowerem',
        completedAt: now.subtract(const Duration(days: 14)),
        activityType: ActivityType.cycling,
        durationSeconds: 2400, // 40 minut
        distance: 15.5,
        pace: CompletedWorkout.calculatePace(15.5, 2400),
      ),
      CompletedWorkout(
        workoutId: '4',
        completedAt: now.subtract(const Duration(days: 16)),
        activityType: ActivityType.gym,
        durationMinutes: 25,
      ),
      CompletedWorkout(
        workoutId: '5',
        completedAt: now.subtract(const Duration(days: 18)),
        activityType: ActivityType.gym,
        durationMinutes: 20,
      ),
      CompletedWorkout(
        workoutId: '7',
        completedAt: now.subtract(const Duration(days: 20)),
        activityType: ActivityType.gym,
        durationMinutes: 50,
        strengthExercises: [
          StrengthExercise(
            name: 'Deadlifts',
            sets: [
              ExerciseSet(weight: 100.0, reps: 5),
              ExerciseSet(weight: 110.0, reps: 5),
              ExerciseSet(weight: 120.0, reps: 3),
            ],
          ),
          StrengthExercise(
            name: 'Pull-ups',
            sets: [
              ExerciseSet(weight: null, reps: 8),
              ExerciseSet(weight: null, reps: 8),
              ExerciseSet(weight: null, reps: 6),
            ],
          ),
        ],
      ),
      CompletedWorkout(
        workoutId: '2',
        completedAt: now.subtract(const Duration(days: 22)),
        activityType: ActivityType.gym,
        durationMinutes: 45,
      ),
      CompletedWorkout(
        workoutId: '8',
        completedAt: now.subtract(const Duration(days: 24)),
        activityType: ActivityType.gym,
        durationMinutes: 55,
        strengthExercises: [
          StrengthExercise(
            name: 'Barbell Squats',
            sets: [
              ExerciseSet(weight: 90.0, reps: 8),
              ExerciseSet(weight: 95.0, reps: 6),
              ExerciseSet(weight: 100.0, reps: 5),
            ],
          ),
        ],
      ),
      CompletedWorkout(
        customName: 'Pływanie',
        completedAt: now.subtract(const Duration(days: 26)),
        activityType: ActivityType.swimming,
        durationSeconds: 2700, // 45 minut
        distance: 1.5,
      ),
      CompletedWorkout(
        workoutId: '1',
        completedAt: now.subtract(const Duration(days: 28)),
        activityType: ActivityType.gym,
        durationMinutes: 30,
      ),
    ];
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
      // Check if workout was completed within the current week (inclusive of both boundaries)
      return completedDate.compareTo(startOfWeek) >= 0 && completedDate.compareTo(endOfWeek) <= 0;
    }).length;
  }

  /// Get number of workouts completed this month.
  static Future<int> getWorkoutsThisMonth() async {
    final completedWorkouts = await getCompletedWorkouts();
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);

    return completedWorkouts.where((workout) {
      final workoutDate = workout.completedAt;
     
      return workoutDate.compareTo(firstDayOfMonth) >= 0 && workoutDate.compareTo(firstDayOfNextMonth) < 0;
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
