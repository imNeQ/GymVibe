import '../models/exercise_info.dart';

/// Service providing exercise database for search functionality.
class ExerciseSearchService {
  /// Get all available exercises.
  static List<ExerciseInfo> getAllExercises() {
    return [
      // Klatka piersiowa
      const ExerciseInfo(
        name: 'Wyciskanie na ławce płaskiej',
        category: 'Klatka piersiowa',
        muscleGroup: 'Środek klatki',
      ),
      const ExerciseInfo(
        name: 'Wyciskanie na ławce skośnej',
        category: 'Klatka piersiowa',
        muscleGroup: 'Góra klatki',
      ),
      const ExerciseInfo(
        name: 'Rozpiętki z hantlami',
        category: 'Klatka piersiowa',
        muscleGroup: 'Środek klatki',
      ),
      const ExerciseInfo(
        name: 'Pompki',
        category: 'Klatka piersiowa',
      ),
      const ExerciseInfo(
        name: 'Pompki na poręczach',
        category: 'Klatka piersiowa',
        muscleGroup: 'Dół klatki',
      ),

      // Plecy
      const ExerciseInfo(
        name: 'Martwy ciąg',
        category: 'Plecy',
        muscleGroup: 'Całe plecy',
      ),
      const ExerciseInfo(
        name: 'Wiosłowanie sztangą',
        category: 'Plecy',
        muscleGroup: 'Środek pleców',
      ),
      const ExerciseInfo(
        name: 'Podciąganie na drążku',
        category: 'Plecy',
        muscleGroup: 'Szerokość pleców',
      ),
      const ExerciseInfo(
        name: 'Wiosłowanie hantlem',
        category: 'Plecy',
        muscleGroup: 'Środek pleców',
      ),
      const ExerciseInfo(
        name: 'Shrugs',
        category: 'Plecy',
        muscleGroup: 'Trapezy',
      ),

      // Nogi
      const ExerciseInfo(
        name: 'Przysiad',
        category: 'Nogi',
        muscleGroup: 'Przednia część uda',
      ),
      const ExerciseInfo(
        name: 'Martwy ciąg na prostych nogach',
        category: 'Nogi',
        muscleGroup: 'Tył uda',
      ),
      const ExerciseInfo(
        name: 'Wykroki',
        category: 'Nogi',
        muscleGroup: 'Całe nogi',
      ),
      const ExerciseInfo(
        name: 'Prostowanie nóg',
        category: 'Nogi',
        muscleGroup: 'Przednia część uda',
      ),
      const ExerciseInfo(
        name: 'Uginanie nóg',
        category: 'Nogi',
        muscleGroup: 'Tył uda',
      ),
      const ExerciseInfo(
        name: 'Wspięcia na palce',
        category: 'Nogi',
        muscleGroup: 'Łydki',
      ),

      // Barki
      const ExerciseInfo(
        name: 'Wyciskanie żołnierskie',
        category: 'Barki',
        muscleGroup: 'Przednie aktony',
      ),
      const ExerciseInfo(
        name: 'Unoszenie bokiem',
        category: 'Barki',
        muscleGroup: 'Boczne aktony',
      ),
      const ExerciseInfo(
        name: 'Unoszenie przodem',
        category: 'Barki',
        muscleGroup: 'Przednie aktony',
      ),
      const ExerciseInfo(
        name: 'Face pulls',
        category: 'Barki',
        muscleGroup: 'Tylne aktony',
      ),

      // Biceps
      const ExerciseInfo(
        name: 'Uginanie ze sztangą',
        category: 'Biceps',
      ),
      const ExerciseInfo(
        name: 'Uginanie z hantlami',
        category: 'Biceps',
      ),
      const ExerciseInfo(
        name: 'Uginanie młotkowe',
        category: 'Biceps',
        muscleGroup: 'Ramiona',
      ),

      // Triceps
      const ExerciseInfo(
        name: 'Wyciskanie francuskie',
        category: 'Triceps',
      ),
      const ExerciseInfo(
        name: 'Pompki wąskie',
        category: 'Triceps',
      ),
      const ExerciseInfo(
        name: 'Wyciskanie wąskie',
        category: 'Triceps',
      ),

      // Brzuch
      const ExerciseInfo(
        name: 'Plank',
        category: 'Brzuch',
        muscleGroup: 'Core',
      ),
      const ExerciseInfo(
        name: 'Brzuszki',
        category: 'Brzuch',
        muscleGroup: 'Górne partie',
      ),
      const ExerciseInfo(
        name: 'Unoszenie nóg',
        category: 'Brzuch',
        muscleGroup: 'Dolne partie',
      ),
      const ExerciseInfo(
        name: 'Mountain climbers',
        category: 'Brzuch',
        muscleGroup: 'Core',
      ),

      // Cardio
      const ExerciseInfo(
        name: 'Bieganie',
        category: 'Cardio',
      ),
      const ExerciseInfo(
        name: 'Rower',
        category: 'Cardio',
      ),
      const ExerciseInfo(
        name: 'Pływanie',
        category: 'Cardio',
      ),
      const ExerciseInfo(
        name: 'Skakanka',
        category: 'Cardio',
      ),
    ];
  }

  /// Search exercises by name (case-insensitive).
  static List<ExerciseInfo> searchExercises(String query) {
    if (query.trim().isEmpty) {
      return getAllExercises();
    }

    final lowerQuery = query.toLowerCase().trim();
    return getAllExercises()
        .where((exercise) =>
            exercise.name.toLowerCase().contains(lowerQuery) ||
            exercise.category.toLowerCase().contains(lowerQuery) ||
            (exercise.muscleGroup != null &&
                exercise.muscleGroup!.toLowerCase().contains(lowerQuery)))
        .toList();
  }
}
