import 'strength_exercise.dart';

/// Enum for activity types.
enum ActivityType {
  gym, // Siłownia
  running, // Bieganie
  cycling, // Rower
  swimming, // Pływanie
  other, // Inne
}

/// Model representing a completed workout with completion date.
/// Part of the GymVibe app's core data models.
class CompletedWorkout {
  final String? workoutId; // Optional - can be null for custom activities
  final DateTime completedAt;
  final ActivityType activityType;
  final String? customName; // For custom activities without workoutId
  final int? durationMinutes; // Optional duration in minutes (for backward compatibility)
  final int? durationSeconds; // Optional duration in seconds (for precise time tracking)
  final double? distance; // Optional distance (in km)
  final double? pace; // Optional pace in min/km (calculated automatically)
  final String? notes; // Optional notes
  final List<StrengthExercise>? strengthExercises; // For gym workouts - list of exercises with sets

  const CompletedWorkout({
    this.workoutId,
    required this.completedAt,
    required this.activityType,
    this.customName,
    this.durationMinutes,
    this.durationSeconds,
    this.distance,
    this.pace,
    this.notes,
    this.strengthExercises,
  });

  /// Get total duration in seconds.
  int? get totalDurationSeconds {
    if (durationSeconds != null) {
      return durationSeconds;
    }
    if (durationMinutes != null) {
      return durationMinutes! * 60;
    }
    return null;
  }

  /// Calculate pace in min/km from distance and duration.
  /// Returns null if data is incomplete.
  static double? calculatePace(double? distance, int? totalSeconds) {
    if (distance == null || distance <= 0 || totalSeconds == null || totalSeconds <= 0) {
      return null;
    }
    // Pace = total seconds / distance / 60 (to get minutes per km)
    return (totalSeconds / distance) / 60.0;
  }

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      if (workoutId != null) 'workoutId': workoutId,
      'completedAt': completedAt.toIso8601String(),
      'activityType': activityType.name,
      if (customName != null) 'customName': customName,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      if (distance != null) 'distance': distance,
      if (pace != null) 'pace': pace,
      if (notes != null) 'notes': notes,
      if (strengthExercises != null && strengthExercises!.isNotEmpty)
        'strengthExercises': strengthExercises!.map((e) => e.toJson()).toList(),
    };
  }

  /// Create from JSON.
  factory CompletedWorkout.fromJson(Map<String, dynamic> json) {
    List<StrengthExercise>? strengthExercises;
    if (json['strengthExercises'] != null) {
      strengthExercises = (json['strengthExercises'] as List<dynamic>)
          .map((e) => StrengthExercise.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final durationMinutes = json['durationMinutes'] as int?;
    final durationSeconds = json['durationSeconds'] as int?;
    final distance = (json['distance'] as num?)?.toDouble();
    final pace = (json['pace'] as num?)?.toDouble();

    // Calculate pace if not stored but distance and duration are available
    double? calculatedPace = pace;
    if (calculatedPace == null && distance != null) {
      final totalSeconds = durationSeconds ?? (durationMinutes != null ? durationMinutes * 60 : null);
      calculatedPace = calculatePace(distance, totalSeconds);
    }

    return CompletedWorkout(
      workoutId: json['workoutId'] as String?,
      completedAt: DateTime.parse(json['completedAt'] as String),
      activityType: ActivityType.values.firstWhere(
        (type) => type.name == json['activityType'],
        orElse: () => ActivityType.other,
      ),
      customName: json['customName'] as String?,
      durationMinutes: durationMinutes,
      durationSeconds: durationSeconds,
      distance: distance,
      pace: calculatedPace,
      notes: json['notes'] as String?,
      strengthExercises: strengthExercises,
    );
  }

  /// Get display name for the workout.
  /// Note: This method doesn't have access to localization context.
  /// For UI display, use getActivityTypeDisplayName() with l10n parameter instead.
  String getDisplayName() {
    if (customName != null && customName!.isNotEmpty) {
      return customName!;
    }
    if (workoutId != null) {
      // Will be resolved by caller using MockDataService
      // Return activity type name as fallback (will be translated by caller)
      return _getActivityTypeName(activityType);
    }
    return _getActivityTypeName(activityType);
  }

  /// Get activity type display name.
  static String _getActivityTypeName(ActivityType type) {
    switch (type) {
      case ActivityType.gym:
        return 'Siłownia';
      case ActivityType.running:
        return 'Bieganie';
      case ActivityType.cycling:
        return 'Rower';
      case ActivityType.swimming:
        return 'Pływanie';
      case ActivityType.other:
        return 'Inne';
    }
  }

  /// Get activity type display name (static method).
  /// If AppLocalizations is provided, uses translations; otherwise falls back to Polish.
  static String getActivityTypeDisplayName(ActivityType type, {dynamic l10n}) {
    if (l10n != null) {
      switch (type) {
        case ActivityType.gym:
          return l10n.gym;
        case ActivityType.running:
          return l10n.running;
        case ActivityType.cycling:
          return l10n.cycling;
        case ActivityType.swimming:
          return l10n.swimming;
        case ActivityType.other:
          return l10n.other;
      }
    }
    return _getActivityTypeName(type);
  }
}
