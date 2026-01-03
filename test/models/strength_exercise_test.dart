import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/models/strength_exercise.dart';
import 'package:trening_tracker/core/models/exercise_set.dart';

void main() {
  group('StrengthExercise', () {
    test('should create StrengthExercise with name and sets', () {
      const exercise = StrengthExercise(
        name: 'Przysiad',
        sets: [
          ExerciseSet(weight: 50.0, reps: 10),
          ExerciseSet(weight: 60.0, reps: 8),
        ],
      );
      
      expect(exercise.name, 'Przysiad');
      expect(exercise.sets.length, 2);
      expect(exercise.sets[0].weight, 50.0);
      expect(exercise.sets[0].reps, 10);
      expect(exercise.sets[1].weight, 60.0);
      expect(exercise.sets[1].reps, 8);
    });

    test('should convert to JSON', () {
      const exercise = StrengthExercise(
        name: 'Wyciskanie na ławce',
        sets: [
          ExerciseSet(weight: 80.0, reps: 5),
          ExerciseSet(reps: 10),
        ],
      );
      
      final json = exercise.toJson();
      
      expect(json['name'], 'Wyciskanie na ławce');
      expect(json['sets'], isA<List>());
      expect(json['sets'].length, 2);
      expect(json['sets'][0]['weight'], 80.0);
      expect(json['sets'][0]['reps'], 5);
      expect(json['sets'][1]['reps'], 10);
      expect(json['sets'][1].containsKey('weight'), false);
    });

    test('should create from JSON', () {
      final json = {
        'name': 'Martwy ciąg',
        'sets': [
          {'weight': 100.0, 'reps': 5},
          {'reps': 8},
        ],
      };
      
      final exercise = StrengthExercise.fromJson(json);
      
      expect(exercise.name, 'Martwy ciąg');
      expect(exercise.sets.length, 2);
      expect(exercise.sets[0].weight, 100.0);
      expect(exercise.sets[0].reps, 5);
      expect(exercise.sets[1].weight, isNull);
      expect(exercise.sets[1].reps, 8);
    });

    test('should handle empty sets list', () {
      const exercise = StrengthExercise(
        name: 'Rozgrzewka',
        sets: [],
      );
      
      expect(exercise.name, 'Rozgrzewka');
      expect(exercise.sets.isEmpty, true);
    });
  });
}
