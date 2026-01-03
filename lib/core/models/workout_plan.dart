/// Model representing a weekly workout plan.
/// Part of the GymVibe app's core data models.
class WorkoutPlan {
  // Day of week (1=Monday, 7=Sunday) -> List of workout IDs (empty list for rest day)
  final Map<int, List<String>> weeklySchedule;

  const WorkoutPlan({
    required this.weeklySchedule,
  });

  /// Create from old format (single workout per day) for backward compatibility.
  factory WorkoutPlan.fromLegacy(Map<int, String?> legacySchedule) {
    final Map<int, List<String>> newSchedule = {};
    for (int day = 1; day <= 7; day++) {
      final workoutId = legacySchedule[day];
      newSchedule[day] = workoutId != null ? [workoutId] : [];
    }
    return WorkoutPlan(weeklySchedule: newSchedule);
  }

  /// Get workout IDs for a specific day (1-7, where 1 is Monday)
  List<String> getWorkoutsForDay(int day) {
    return weeklySchedule[day] ?? [];
  }

  /// Get first workout ID for a specific day (for backward compatibility)
  String? getWorkoutForDay(int day) {
    final workouts = getWorkoutsForDay(day);
    return workouts.isNotEmpty ? workouts.first : null;
  }

  /// Check if day is a rest day (no workouts assigned)
  bool isRestDay(int day) {
    final workouts = getWorkoutsForDay(day);
    return workouts.isEmpty;
  }

  /// Add workout to a specific day.
  WorkoutPlan addWorkoutToDay(int day, String workoutId) {
    final newSchedule = Map<int, List<String>>.from(weeklySchedule);
    final currentWorkouts = List<String>.from(newSchedule[day] ?? []);
    if (!currentWorkouts.contains(workoutId)) {
      currentWorkouts.add(workoutId);
      newSchedule[day] = currentWorkouts;
    }
    return WorkoutPlan(weeklySchedule: newSchedule);
  }

  /// Remove workout from a specific day.
  WorkoutPlan removeWorkoutFromDay(int day, String workoutId) {
    final newSchedule = Map<int, List<String>>.from(weeklySchedule);
    final currentWorkouts = List<String>.from(newSchedule[day] ?? []);
    currentWorkouts.remove(workoutId);
    newSchedule[day] = currentWorkouts;
    return WorkoutPlan(weeklySchedule: newSchedule);
  }

  /// Move workout up in the list for a specific day.
  WorkoutPlan moveWorkoutUp(int day, int index) {
    if (index <= 0) return this;
    final newSchedule = Map<int, List<String>>.from(weeklySchedule);
    final currentWorkouts = List<String>.from(newSchedule[day] ?? []);
    if (index < currentWorkouts.length) {
      final temp = currentWorkouts[index];
      currentWorkouts[index] = currentWorkouts[index - 1];
      currentWorkouts[index - 1] = temp;
      newSchedule[day] = currentWorkouts;
    }
    return WorkoutPlan(weeklySchedule: newSchedule);
  }

  /// Move workout down in the list for a specific day.
  WorkoutPlan moveWorkoutDown(int day, int index) {
    final newSchedule = Map<int, List<String>>.from(weeklySchedule);
    final currentWorkouts = List<String>.from(newSchedule[day] ?? []);
    if (index >= 0 && index < currentWorkouts.length - 1) {
      final temp = currentWorkouts[index];
      currentWorkouts[index] = currentWorkouts[index + 1];
      currentWorkouts[index + 1] = temp;
      newSchedule[day] = currentWorkouts;
    }
    return WorkoutPlan(weeklySchedule: newSchedule);
  }

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    weeklySchedule.forEach((day, workouts) {
      json[day.toString()] = workouts;
    });
    return json;
  }

  /// Create from JSON.
  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    final Map<int, List<String>> schedule = {};
    json.forEach((key, value) {
      final day = int.tryParse(key);
      if (day != null && day >= 1 && day <= 7) {
        if (value is List) {
          schedule[day] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          // Backward compatibility: single workout ID
          schedule[day] = [value];
        }
      }
    });
    // Ensure all days 1-7 are present
    for (int day = 1; day <= 7; day++) {
      schedule.putIfAbsent(day, () => []);
    }
    return WorkoutPlan(weeklySchedule: schedule);
  }
}

