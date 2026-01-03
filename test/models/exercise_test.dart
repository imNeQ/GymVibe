import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/models/exercise.dart';

void main() {
  group('Exercise', () {
    test('should create Exercise with all fields', () {
      const exercise = Exercise(
        name: 'Przysiad',
        sets: 3,
        reps: 10,
        restSeconds: 60,
      );
      
      expect(exercise.name, 'Przysiad');
      expect(exercise.sets, 3);
      expect(exercise.reps, 10);
      expect(exercise.restSeconds, 60);
    });

    test('should create Exercise without restSeconds', () {
      const exercise = Exercise(
        name: 'Wyciskanie',
        sets: 4,
        reps: 8,
      );
      
      expect(exercise.name, 'Wyciskanie');
      expect(exercise.sets, 4);
      expect(exercise.reps, 8);
      expect(exercise.restSeconds, isNull);
    });

    test('should create Exercise with zero restSeconds', () {
      const exercise = Exercise(
        name: 'Rozgrzewka',
        sets: 1,
        reps: 20,
        restSeconds: 0,
      );
      
      expect(exercise.restSeconds, 0);
    });
  });
}
