/// Translation utilities for the GymVibe app.
/// Provides functions to translate English text to Polish.
class Translations {
  /// Translate difficulty level to Polish.
  static String translateDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Początkujący';
      case 'intermediate':
        return 'Średnio zaawansowany';
      case 'advanced':
        return 'Zaawansowany';
      default:
        return difficulty;
    }
  }
}
