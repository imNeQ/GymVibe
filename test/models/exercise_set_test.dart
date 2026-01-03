import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/models/exercise_set.dart';

void main() {
  group('ExerciseSet', () {
    test('should create ExerciseSet with weight and reps', () {
      const set = ExerciseSet(weight: 50.0, reps: 10);
      
      expect(set.weight, 50.0);
      expect(set.reps, 10);
    });

    test('should create ExerciseSet without weight', () {
      const set = ExerciseSet(reps: 15);
      
      expect(set.weight, isNull);
      expect(set.reps, 15);
    });

    test('should convert to JSON with weight', () {
      const set = ExerciseSet(weight: 75.5, reps: 8);
      final json = set.toJson();
      
      expect(json['weight'], 75.5);
      expect(json['reps'], 8);
    });

    test('should convert to JSON without weight', () {
      const set = ExerciseSet(reps: 12);
      final json = set.toJson();
      
      expect(json.containsKey('weight'), false);
      expect(json['reps'], 12);
    });

    test('should create from JSON with weight', () {
      final json = {'weight': 60.0, 'reps': 10};
      final set = ExerciseSet.fromJson(json);
      
      expect(set.weight, 60.0);
      expect(set.reps, 10);
    });

    test('should create from JSON without weight', () {
      final json = {'reps': 20};
      final set = ExerciseSet.fromJson(json);
      
      expect(set.weight, isNull);
      expect(set.reps, 20);
    });

    test('should handle integer weight in JSON', () {
      final json = {'weight': 50, 'reps': 10};
      final set = ExerciseSet.fromJson(json);
      
      expect(set.weight, 50.0);
      expect(set.reps, 10);
    });
  });
}
