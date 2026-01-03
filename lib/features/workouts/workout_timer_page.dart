import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/workout_history_service.dart';
import '../../core/models/completed_workout.dart';
import '../../core/models/workout.dart';
import '../../core/services/mock_data.dart';

/// Page for workout timer.
/// Allows users to track workout duration with pause/resume functionality.
class WorkoutTimerPage extends StatefulWidget {
  final String? workoutId;
  final String? workoutName;

  const WorkoutTimerPage({
    super.key,
    this.workoutId,
    this.workoutName,
  });

  @override
  State<WorkoutTimerPage> createState() => _WorkoutTimerPageState();
}

class _WorkoutTimerPageState extends State<WorkoutTimerPage>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  DateTime? _startTime;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause timer when app goes to background, resume when back
    if (state == AppLifecycleState.paused && _isRunning && !_isPaused) {
      _pauseTimer();
    } else if (state == AppLifecycleState.resumed && _isPaused && _isRunning) {
      // Don't auto-resume, let user resume manually
    }
  }

  void _startTimer() {
    if (_isRunning && !_isPaused) return; // Don't start if already running and not paused

    setState(() {
      _isRunning = true;
      _isPaused = false;
      if (_startTime == null) {
        _startTime = DateTime.now();
      } else if (_pausedTime != null) {
        // Resume from pause - just clear paused time
        _pausedTime = null;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning || _isPaused) return;

    setState(() {
      _isPaused = true;
      _pausedTime = DateTime.now();
    });

    _timer?.cancel();
  }

  void _resumeTimer() {
    if (!_isPaused || !_isRunning) return;

    // Resume the timer by clearing pause state and restarting the periodic timer
    setState(() {
      _isPaused = false;
      _pausedTime = null;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _elapsedSeconds = 0;
      _startTime = null;
      _pausedTime = null;
    });
  }

  Future<void> _finishWorkout() async {
    if (!_isRunning && _elapsedSeconds == 0) {
      // Timer was never started
      Navigator.pop(context);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _FinishWorkoutDialog(
        duration: _elapsedSeconds,
      ),
    );

    if (confirmed == true) {
      // Save workout with duration if workoutId is provided
      if (widget.workoutId != null) {
        // Create a completed workout with the timer duration
        final completedWorkout = await _createCompletedWorkoutFromTimer();
        if (completedWorkout != null) {
          await WorkoutHistoryService.saveCustomWorkout(completedWorkout);
        }
      }

      if (mounted) {
        Navigator.pop(context, _elapsedSeconds);
      }
    }
  }

  Future<CompletedWorkout?> _createCompletedWorkoutFromTimer() async {
    if (widget.workoutId == null && widget.workoutName == null) return null;

    // Determine activity type from workout name or default to gym
    ActivityType activityType = ActivityType.gym;
    String? workoutNameToCheck = widget.workoutName;
    
    // If workoutName is not provided, try to get it from workoutId
    if (workoutNameToCheck == null && widget.workoutId != null) {
      try {
        final workout = await MockDataService.getWorkoutById(widget.workoutId!);
        if (workout != null) {
          workoutNameToCheck = workout.name;
        }
      } catch (e) {
        // If we can't get workout details, use default
      }
    }
    
    if (workoutNameToCheck != null) {
      final workoutNameLower = workoutNameToCheck.toLowerCase();
      if (workoutNameLower.contains('running') || workoutNameLower.contains('bieganie') || 
          workoutNameLower.contains('run') || workoutNameLower.contains('bieg')) {
        activityType = ActivityType.running;
      } else if (workoutNameLower.contains('cycling') || workoutNameLower.contains('rower') ||
                 workoutNameLower.contains('bike') || workoutNameLower.contains('kolarz')) {
        activityType = ActivityType.cycling;
      } else if (workoutNameLower.contains('swimming') || workoutNameLower.contains('pływanie') ||
                 workoutNameLower.contains('swim') || workoutNameLower.contains('pływ')) {
        activityType = ActivityType.swimming;
      }
    }

    // Convert elapsed seconds to minutes and seconds
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;

    return CompletedWorkout(
      workoutId: widget.workoutId,
      completedAt: _startTime ?? DateTime.now(),
      activityType: activityType,
      customName: widget.workoutName,
      durationMinutes: minutes > 0 ? minutes : null,
      durationSeconds: seconds > 0 || minutes > 0 ? seconds : null,
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Get difficulty color.
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutName ?? (l10n?.workoutTimer ?? 'Timer treningu')),
        actions: [
          if (_isRunning || _elapsedSeconds > 0)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _finishWorkout,
              tooltip: l10n?.finishWorkout ?? 'Zakończ trening',
            ),
        ],
      ),
      body: SafeArea(
        child: widget.workoutId != null
            ? FutureBuilder<Workout?>(
                future: MockDataService.getWorkoutById(widget.workoutId!),
                builder: (context, snapshot) {
                  final workout = snapshot.data;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Workout plan card
                        if (workout != null) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workout.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (workout.description != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      workout.description!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Chip(
                                        label: Text(workout.difficulty),
                                        backgroundColor: _getDifficultyColor(workout.difficulty).withValues(alpha: 0.1),
                                        labelStyle: TextStyle(
                                          color: _getDifficultyColor(workout.difficulty),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Chip(
                                        avatar: const Icon(Icons.timer, size: 16),
                                        label: Text('${workout.estimatedDurationMinutes} min'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n?.exercises ?? 'Ćwiczenia',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...workout.exercises.map((exercise) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.fiber_manual_record,
                                              size: 8,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${exercise.name} - ${exercise.sets} x ${exercise.reps}',
                                                style: theme.textTheme.bodyMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Timer section
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Timer display
                                Text(
                                  _formatTime(_elapsedSeconds),
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 64,
                                    color: _isRunning
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Status text
                                Text(
                                  _isRunning
                                      ? (l10n?.timerRunning ?? 'Timer działa')
                                      : _isPaused
                                          ? (l10n?.timerPaused ?? 'Timer wstrzymany')
                                          : (l10n?.timerStopped ?? 'Timer zatrzymany'),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Control buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!_isRunning && _elapsedSeconds == 0)
                                      // Start button
                                      FilledButton.icon(
                                        onPressed: _startTimer,
                                        icon: const Icon(Icons.play_arrow),
                                        label: Text(l10n?.start ?? 'Start'),
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                        ),
                                      )
                                    else ...[
                                      // Pause/Resume button
                                      FilledButton.icon(
                                        onPressed: _isPaused ? _resumeTimer : _pauseTimer,
                                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                                        label: Text(
                                          _isPaused
                                              ? (l10n?.resume ?? 'Wznów')
                                              : (l10n?.pause ?? 'Pauza'),
                                        ),
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Reset button
                                      OutlinedButton.icon(
                                        onPressed: _resetTimer,
                                        icon: const Icon(Icons.refresh),
                                        label: Text(l10n?.reset ?? 'Reset'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                // Finish workout button
                                if (_elapsedSeconds > 0)
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: _finishWorkout,
                                      icon: const Icon(Icons.check),
                                      label: Text(l10n?.finishWorkout ?? 'Zakończ trening'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: theme.colorScheme.tertiary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Timer display
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 72,
                        color: _isRunning
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Status text
                    Text(
                      _isRunning
                          ? (l10n?.timerRunning ?? 'Timer działa')
                          : _isPaused
                              ? (l10n?.timerPaused ?? 'Timer wstrzymany')
                              : (l10n?.timerStopped ?? 'Timer zatrzymany'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isRunning && _elapsedSeconds == 0)
                          // Start button
                          FilledButton.icon(
                            onPressed: _startTimer,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l10n?.start ?? 'Start'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          )
                        else ...[
                          // Pause/Resume button
                          FilledButton.icon(
                            onPressed: _isPaused ? _resumeTimer : _pauseTimer,
                            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                            label: Text(
                              _isPaused
                                  ? (l10n?.resume ?? 'Wznów')
                                  : (l10n?.pause ?? 'Pauza'),
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Reset button
                          OutlinedButton.icon(
                            onPressed: _resetTimer,
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n?.reset ?? 'Reset'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 48),
                    
                    // Finish workout button
                    if (_elapsedSeconds > 0)
                      FilledButton.icon(
                        onPressed: _finishWorkout,
                        icon: const Icon(Icons.check),
                        label: Text(l10n?.finishWorkout ?? 'Zakończ trening'),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.tertiary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Dialog for confirming workout finish.
class _FinishWorkoutDialog extends StatelessWidget {
  final int duration;

  const _FinishWorkoutDialog({required this.duration});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.finishWorkout ?? 'Zakończ trening'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n?.workoutDuration ?? 'Czas trwania treningu:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(duration),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.finishWorkoutConfirmation ??
                'Czy na pewno chcesz zakończyć trening?',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n?.cancel ?? 'Anuluj'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n?.finish ?? 'Zakończ'),
        ),
      ],
    );
  }
}
