import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_plan.dart';
import 'custom_workout_service.dart';

/// Mock data service providing sample workouts and plans.
/// Combines predefined mock workouts with user-created custom workouts.
class MockDataService {
  /// Get all available workouts (mock + custom).
  /// Original workout plans designed for GymVibe app combined with user-created workouts.
  static Future<List<Workout>> getWorkouts() async {
    final customWorkouts = await CustomWorkoutService.getWorkouts();
    final mockWorkouts = _getMockWorkouts();
    return [...mockWorkouts, ...customWorkouts];
  }

  /// Get only mock workouts (for backward compatibility).
  static List<Workout> _getMockWorkouts() {
    return [
      Workout(
        id: '1',
        name: 'Full Body Beginner',
        difficulty: 'Beginner',
        estimatedDurationMinutes: 30,
        description: 'Kompleksowy trening całego ciała idealny na początek Twojej przygody z fitness',
        exercises: [
          const Exercise(name: 'Bodyweight Squats', sets: 3, reps: 12, restSeconds: 60),
          const Exercise(name: 'Push-ups', sets: 3, reps: 8, restSeconds: 60),
          const Exercise(name: 'Walking Lunges', sets: 2, reps: 10, restSeconds: 60),
          const Exercise(name: 'Plank Hold', sets: 3, reps: 20, restSeconds: 45),
          const Exercise(name: 'Glute Bridges', sets: 3, reps: 12, restSeconds: 45),
        ],
      ),
      Workout(
        id: '2',
        name: 'Upper Body Strength',
        difficulty: 'Intermediate',
        estimatedDurationMinutes: 45,
        description: 'Skupia się na klatce piersiowej, barkach, plecach i ramionach dla zrównoważonego rozwoju górnej części ciała',
        exercises: [
          const Exercise(name: 'Wide Push-ups', sets: 4, reps: 12, restSeconds: 90),
          const Exercise(name: 'Diamond Push-ups', sets: 3, reps: 10, restSeconds: 90),
          const Exercise(name: 'Pike Push-ups', sets: 3, reps: 8, restSeconds: 90),
          const Exercise(name: 'Pull-ups or Rows', sets: 3, reps: 8, restSeconds: 90),
          const Exercise(name: 'Tricep Dips', sets: 3, reps: 10, restSeconds: 60),
        ],
      ),
      Workout(
        id: '3',
        name: 'Leg Day Focus',
        difficulty: 'Intermediate',
        estimatedDurationMinutes: 40,
        description: 'Kompleksowy trening dolnej części ciała skupiający się na wszystkich głównych mięśniach nóg',
        exercises: [
          const Exercise(name: 'Squats', sets: 4, reps: 15, restSeconds: 90),
          const Exercise(name: 'Reverse Lunges', sets: 3, reps: 12, restSeconds: 90),
          const Exercise(name: 'Bulgarian Split Squats', sets: 3, reps: 10, restSeconds: 90),
          const Exercise(name: 'Romanian Deadlifts', sets: 3, reps: 12, restSeconds: 90),
          const Exercise(name: 'Calf Raises', sets: 3, reps: 15, restSeconds: 60),
        ],
      ),
      Workout(
        id: '4',
        name: 'HIIT Cardio Blast',
        difficulty: 'Advanced',
        estimatedDurationMinutes: 25,
        description: 'Wysokointensywne interwały zwiększające wydolność sercowo-naczyniową i spalające kalorie',
        exercises: [
          const Exercise(name: 'Burpees', sets: 4, reps: 8, restSeconds: 30),
          const Exercise(name: 'Mountain Climbers', sets: 4, reps: 20, restSeconds: 30),
          const Exercise(name: 'Jump Squats', sets: 4, reps: 12, restSeconds: 30),
          const Exercise(name: 'High Knees', sets: 4, reps: 30, restSeconds: 30),
          const Exercise(name: 'Plank Jacks', sets: 3, reps: 15, restSeconds: 30),
        ],
      ),
      Workout(
        id: '5',
        name: 'Core Strength Builder',
        difficulty: 'Beginner',
        estimatedDurationMinutes: 20,
        description: 'Rozwijaj stabilność i siłę core dzięki skupionym ćwiczeniom na mięśnie brzucha',
        exercises: [
          const Exercise(name: 'Plank Hold', sets: 3, reps: 30, restSeconds: 60),
          const Exercise(name: 'Dead Bug', sets: 3, reps: 12, restSeconds: 45),
          const Exercise(name: 'Bird Dog', sets: 3, reps: 10, restSeconds: 45),
          const Exercise(name: 'Side Plank', sets: 2, reps: 20, restSeconds: 45),
          const Exercise(name: 'Reverse Crunches', sets: 3, reps: 12, restSeconds: 45),
        ],
      ),
      // Push Workout (Chest, Shoulders, Triceps)
      Workout(
        id: '6',
        name: 'Push Day',
        difficulty: 'Intermediate',
        estimatedDurationMinutes: 50,
        description: 'Trening skupiający się na klatce piersiowej, barkach i tricepsach. Idealny dla split push/pull/legs',
        exercises: [
          const Exercise(name: 'Bench Press', sets: 4, reps: 8, restSeconds: 120),
          const Exercise(name: 'Overhead Press', sets: 3, reps: 8, restSeconds: 90),
          const Exercise(name: 'Incline Dumbbell Press', sets: 3, reps: 10, restSeconds: 90),
          const Exercise(name: 'Lateral Raises', sets: 3, reps: 12, restSeconds: 60),
          const Exercise(name: 'Tricep Dips', sets: 3, reps: 10, restSeconds: 60),
          const Exercise(name: 'Tricep Pushdowns', sets: 3, reps: 12, restSeconds: 60),
        ],
      ),
      // Pull Workout (Back, Biceps)
      Workout(
        id: '7',
        name: 'Pull Day',
        difficulty: 'Intermediate',
        estimatedDurationMinutes: 50,
        description: 'Trening skupiający się na plecach i bicepsach. Idealny dla split push/pull/legs',
        exercises: [
          const Exercise(name: 'Deadlifts', sets: 4, reps: 6, restSeconds: 120),
          const Exercise(name: 'Pull-ups', sets: 4, reps: 8, restSeconds: 90),
          const Exercise(name: 'Barbell Rows', sets: 4, reps: 8, restSeconds: 90),
          const Exercise(name: 'Lat Pulldowns', sets: 3, reps: 10, restSeconds: 60),
          const Exercise(name: 'Barbell Curls', sets: 3, reps: 10, restSeconds: 60),
          const Exercise(name: 'Hammer Curls', sets: 3, reps: 12, restSeconds: 60),
        ],
      ),
      // Push Pull Legs - Legs Day
      Workout(
        id: '8',
        name: 'Legs Day (PPL)',
        difficulty: 'Intermediate',
        estimatedDurationMinutes: 55,
        description: 'Kompleksowy trening nóg dla split push/pull/legs. Skupia się na wszystkich mięśniach dolnej części ciała',
        exercises: [
          const Exercise(name: 'Barbell Squats', sets: 4, reps: 8, restSeconds: 120),
          const Exercise(name: 'Romanian Deadlifts', sets: 4, reps: 8, restSeconds: 120),
          const Exercise(name: 'Leg Press', sets: 3, reps: 12, restSeconds: 90),
          const Exercise(name: 'Leg Curls', sets: 3, reps: 12, restSeconds: 60),
          const Exercise(name: 'Leg Extensions', sets: 3, reps: 12, restSeconds: 60),
          const Exercise(name: 'Calf Raises', sets: 4, reps: 15, restSeconds: 60),
        ],
      ),
      // Upper Body Push Focus
      Workout(
        id: '9',
        name: 'Upper Push',
        difficulty: 'Advanced',
        estimatedDurationMinutes: 60,
        description: 'Zaawansowany trening push z większym naciskiem na objętość i intensywność',
        exercises: [
          const Exercise(name: 'Flat Bench Press', sets: 5, reps: 5, restSeconds: 180),
          const Exercise(name: 'Incline Barbell Press', sets: 4, reps: 8, restSeconds: 120),
          const Exercise(name: 'Dumbbell Flyes', sets: 3, reps: 12, restSeconds: 90),
          const Exercise(name: 'Military Press', sets: 4, reps: 6, restSeconds: 120),
          const Exercise(name: 'Lateral Raises', sets: 4, reps: 12, restSeconds: 60),
          const Exercise(name: 'Close Grip Bench Press', sets: 3, reps: 8, restSeconds: 90),
          const Exercise(name: 'Overhead Tricep Extension', sets: 3, reps: 10, restSeconds: 60),
        ],
      ),
      // Upper Body Pull Focus
      Workout(
        id: '10',
        name: 'Upper Pull',
        difficulty: 'Advanced',
        estimatedDurationMinutes: 60,
        description: 'Zaawansowany trening pull z większym naciskiem na szerokość i grubość pleców',
        exercises: [
          const Exercise(name: 'Weighted Pull-ups', sets: 4, reps: 6, restSeconds: 120),
          const Exercise(name: 'Barbell Rows', sets: 5, reps: 8, restSeconds: 120),
          const Exercise(name: 'T-Bar Rows', sets: 4, reps: 8, restSeconds: 90),
          const Exercise(name: 'Cable Rows', sets: 3, reps: 12, restSeconds: 60),
          const Exercise(name: 'Face Pulls', sets: 3, reps: 15, restSeconds: 60),
          const Exercise(name: 'Barbell Curls', sets: 4, reps: 8, restSeconds: 90),
          const Exercise(name: 'Preacher Curls', sets: 3, reps: 10, restSeconds: 60),
        ],
      ),
      // Push Pull Legs - Push Day (Alternative)
      Workout(
        id: '11',
        name: 'PPL Push',
        difficulty: 'Intermediate',
        estimatedDurationMinutes: 45,
        description: 'Trening push w stylu PPL - klatka, barki, triceps',
        exercises: [
          const Exercise(name: 'Bench Press', sets: 4, reps: 8, restSeconds: 120),
          const Exercise(name: 'Overhead Press', sets: 3, reps: 8, restSeconds: 90),
          const Exercise(name: 'Dumbbell Press', sets: 3, reps: 10, restSeconds: 90),
          const Exercise(name: 'Lateral Raises', sets: 3, reps: 12, restSeconds: 60),
          const Exercise(name: 'Tricep Dips', sets: 3, reps: 10, restSeconds: 60),
          const Exercise(name: 'Cable Tricep Extensions', sets: 3, reps: 12, restSeconds: 60),
        ],
      ),
      // Push Pull Legs - Pull Day (Alternative)
      Workout(
        id: '12',
        name: 'PPL Pull',
        difficulty: 'Intermediate',
        estimatedDurationMinutes: 45,
        description: 'Trening pull w stylu PPL - plecy, biceps',
        exercises: [
          const Exercise(name: 'Deadlifts', sets: 3, reps: 5, restSeconds: 180),
          const Exercise(name: 'Pull-ups', sets: 4, reps: 8, restSeconds: 90),
          const Exercise(name: 'Cable Rows', sets: 3, reps: 10, restSeconds: 90),
          const Exercise(name: 'Lat Pulldowns', sets: 3, reps: 10, restSeconds: 60),
          const Exercise(name: 'Barbell Curls', sets: 3, reps: 10, restSeconds: 60),
          const Exercise(name: 'Cable Curls', sets: 3, reps: 12, restSeconds: 60),
        ],
      ),
    ];
  }

  /// Get workout by ID.
  static Future<Workout?> getWorkoutById(String id) async {
    final workouts = await getWorkouts();
    try {
      return workouts.firstWhere((workout) => workout.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get today's recommended workout (returns first available workout).
  static Future<Workout?> getTodaysWorkout() async {
    final workouts = await getWorkouts();
    if (workouts.isEmpty) {
      return null;
    }
    return workouts.first;
  }

  /// Get weekly workout plan (mock data).
  static WorkoutPlan getWeeklyPlan() {
    return WorkoutPlan(
      weeklySchedule: {
        1: ['1'], // Monday - Full Body Beginner
        2: ['2'], // Tuesday - Upper Body
        3: [], // Wednesday - Rest
        4: ['3'], // Thursday - Leg Day
        5: ['4'], // Friday - HIIT Cardio
        6: ['5'], // Saturday - Core Strength
        7: [], // Sunday - Rest
      },
    );
  }

  /// Get mock statistics.
  static Map<String, int> getStatistics() {
    return {
      'workoutsThisWeek': 4,
      'workoutsThisMonth': 15,
      'totalWorkouts': 42,
    };
  }
}

