import '../models/achievement.dart';
import '../services/workout_history_service.dart';

/// Service for managing user achievements.
/// Calculates achievements based on workout history.
class AchievementService {
  /// Get all available achievements with their unlock status.
  static Future<List<Achievement>> getAchievements() async {
    final workouts = await WorkoutHistoryService.getCompletedWorkouts();
    final totalWorkouts = workouts.length;
    
    // Calculate total distance for running/cycling
    double totalDistance = 0;
    for (final workout in workouts) {
      if (workout.distance != null) {
        totalDistance += workout.distance!;
      }
    }

    // Calculate total workout time in hours
    double totalHours = 0;
    for (final workout in workouts) {
      final seconds = workout.totalDurationSeconds;
      if (seconds != null) {
        totalHours += seconds / 3600.0;
      }
    }

    // Calculate consecutive days (simplified - check last 7 days)
    int consecutiveDays = _calculateConsecutiveDays(workouts);

    return [
      // First workout
      Achievement(
        id: 'first_workout',
        nameKey: 'achievementFirstStep',
        descriptionKey: 'achievementFirstStepDesc',
        icon: '🎯',
        unlocked: totalWorkouts >= 1,
        unlockedAt: totalWorkouts >= 1 ? workouts.first.completedAt : null,
      ),
      // 5 workouts
      Achievement(
        id: 'five_workouts',
        nameKey: 'achievementFiredUp',
        descriptionKey: 'achievementFiredUpDesc',
        icon: '🔥',
        unlocked: totalWorkouts >= 5,
        unlockedAt: totalWorkouts >= 5 ? workouts.length >= 5 ? workouts[4].completedAt : null : null,
      ),
      // 10 workouts
      Achievement(
        id: 'ten_workouts',
        nameKey: 'achievementTen',
        descriptionKey: 'achievementTenDesc',
        icon: '💪',
        unlocked: totalWorkouts >= 10,
        unlockedAt: totalWorkouts >= 10 ? workouts.length >= 10 ? workouts[9].completedAt : null : null,
      ),
      // 25 workouts
      Achievement(
        id: 'twenty_five_workouts',
        nameKey: 'achievementExerciser',
        descriptionKey: 'achievementExerciserDesc',
        icon: '🏆',
        unlocked: totalWorkouts >= 25,
        unlockedAt: totalWorkouts >= 25 ? workouts.length >= 25 ? workouts[24].completedAt : null : null,
      ),
      // 50 workouts
      Achievement(
        id: 'fifty_workouts',
        nameKey: 'achievementMaster',
        descriptionKey: 'achievementMasterDesc',
        icon: '👑',
        unlocked: totalWorkouts >= 50,
        unlockedAt: totalWorkouts >= 50 ? workouts.length >= 50 ? workouts[49].completedAt : null : null,
      ),
      // 5km distance
      Achievement(
        id: 'five_km',
        nameKey: 'achievementRunner',
        descriptionKey: 'achievementRunnerDesc',
        icon: '🏃',
        unlocked: totalDistance >= 5.0,
      ),
      // 10km distance
      Achievement(
        id: 'ten_km',
        nameKey: 'achievementMarathoner',
        descriptionKey: 'achievementMarathonerDesc',
        icon: '🏅',
        unlocked: totalDistance >= 10.0,
      ),
      // 10 hours
      Achievement(
        id: 'ten_hours',
        nameKey: 'achievementTimeForTraining',
        descriptionKey: 'achievementTimeForTrainingDesc',
        icon: '⏰',
        unlocked: totalHours >= 10.0,
      ),
      // 3 consecutive days
      Achievement(
        id: 'three_days',
        nameKey: 'achievementHabit',
        descriptionKey: 'achievementHabitDesc',
        icon: '📅',
        unlocked: consecutiveDays >= 3,
      ),
      // 7 consecutive days
      Achievement(
        id: 'seven_days',
        nameKey: 'achievementDiscipline',
        descriptionKey: 'achievementDisciplineDesc',
        icon: '⭐',
        unlocked: consecutiveDays >= 7,
      ),
    ];
  }

  /// Calculate consecutive workout days (simplified version).
  static int _calculateConsecutiveDays(List workouts) {
    if (workouts.isEmpty) return 0;

    // Sort by date (newest first)
    final sorted = List.from(workouts);
    sorted.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    // Check consecutive days from today backwards
    int consecutive = 0;
    DateTime? lastDate;
    
    for (final workout in sorted) {
      final workoutDate = DateTime(
        workout.completedAt.year,
        workout.completedAt.month,
        workout.completedAt.day,
      );

      if (lastDate == null) {
        // First workout - check if it's today or yesterday
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final yesterdayDate = todayDate.subtract(const Duration(days: 1));

        if (workoutDate == todayDate || workoutDate == yesterdayDate) {
          consecutive = 1;
          lastDate = workoutDate;
        } else {
          break;
        }
      } else {
        // Check if this workout is the day before lastDate
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (workoutDate == expectedDate) {
          consecutive++;
          lastDate = workoutDate;
        } else if (workoutDate != lastDate) {
          // Gap in days - stop counting
          break;
        }
      }
    }

    return consecutive;
  }

  /// Get unlocked achievements count.
  static Future<int> getUnlockedCount() async {
    final achievements = await getAchievements();
    return achievements.where((a) => a.unlocked).length;
  }
}
