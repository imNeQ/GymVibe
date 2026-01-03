import 'package:flutter/material.dart';

/// Localization class for managing app translations.
/// Provides translations for Polish and English.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Navigation
  String get home => _translate('home', 'Strona główna');
  String get workouts => _translate('workouts', 'Treningi');
  String get plan => _translate('plan', 'Plan');
  String get statistics => _translate('statistics', 'Statystyki');
  String get profile => _translate('profile', 'Profil');

  // Dashboard
  String get hello => _translate('hello', 'Cześć');
  String get readyForWorkout => _translate('readyForWorkout', 'Gotowy na dzisiejszy trening?');
  String get todayWorkout => _translate('todayWorkout', 'Dzisiejszy trening');
  String get startWorkout => _translate('startWorkout', 'Rozpocznij trening');
  String get thisWeek => _translate('thisWeek', 'Ten tydzień');
  String get suggestions => _translate('suggestions', 'Sugestie');
  String get workoutsCount => _translate('workoutsCount', 'Treningi');
  String get thisMonth => _translate('thisMonth', 'Ten miesiąc');
  String get statisticsTitle => _translate('statisticsTitle', 'Statystyki');
  String get totalTime => _translate('totalTime', 'Całkowity czas');
  String get allWorkouts => _translate('allWorkouts', 'Wszystkie treningi');
  String get recentWorkouts => _translate('recentWorkouts', 'Ostatnie treningi');
  String get addWorkout => _translate('addWorkout', 'Dodaj trening');
  String get last7Days => _translate('last7Days', 'Ostatnie 7 dni');
  String get distanceKm => _translate('distanceKm', 'Dystans [km]');
  String get timeMin => _translate('timeMin', 'Czas [min]');

  // Settings
  String get settings => _translate('settings', 'Ustawienia');
  String get appLanguage => _translate('appLanguage', 'Język aplikacji');
  String get language => _translate('language', 'Język');
  String get polish => _translate('polish', 'Polski');
  String get polishLanguage => _translate('polishLanguage', 'Język polski');
  String get english => _translate('english', 'English');
  String get englishLanguage => _translate('englishLanguage', 'English language');
  String get units => _translate('units', 'Jednostki');
  String get kilometers => _translate('kilometers', 'Kilometry (km)');
  String get metricUnit => _translate('metricUnit', 'Jednostka metryczna');
  String get miles => _translate('miles', 'Mile (mi)');
  String get imperialUnit => _translate('imperialUnit', 'Jednostka imperialna');
  String get settingsSaved => _translate('settingsSaved', 'Ustawienia zapisane');
  String get resetToDefaults => _translate('resetToDefaults', 'Reset do domyślnych');
  String get resetSettings => _translate('resetSettings', 'Resetuj ustawienia');
  String get resetConfirmation => _translate('resetConfirmation', 'Czy na pewno chcesz zresetować wszystkie ustawienia do wartości domyślnych?');

  // Workouts
  String get workoutDetail => _translate('workoutDetail', 'Szczegóły treningu');
  String get exercises => _translate('exercises', 'Ćwiczenia');
  String get sets => _translate('sets', 'serie');
  String get set => _translate('set', 'seria');
  String get reps => _translate('reps', 'powtórzenia');
  String get rest => _translate('rest', 'Odpoczynek');
  String get markAsDone => _translate('markAsDone', 'Oznacz jako ukończony');
  String get completed => _translate('completed', 'Ukończony');
  String get workoutMarkedAsCompleted => _translate('workoutMarkedAsCompleted', 'Trening oznaczony jako ukończony!');
  String get addWorkoutToHistory => _translate('addWorkoutToHistory', 'Dodaj trening do historii');
  String get workoutDate => _translate('workoutDate', 'Data treningu');
  String get activityType => _translate('activityType', 'Typ aktywności');
  String get gym => _translate('gym', 'Siłownia');
  String get running => _translate('running', 'Bieganie');
  String get cycling => _translate('cycling', 'Rower');
  String get swimming => _translate('swimming', 'Pływanie');
  String get other => _translate('other', 'Inne');
  String get activityName => _translate('activityName', 'Nazwa aktywności');
  String get additionalInfo => _translate('additionalInfo', 'Dodatkowe informacje (opcjonalnie)');
  String get durationMinutes => _translate('durationMinutes', 'Czas trwania (minuty)');
  String get minutes => _translate('minutes', 'Minuty');
  String get seconds => _translate('seconds', 'Sekundy');
  String get distance => _translate('distance', 'Dystans (km)');
  String get pace => _translate('pace', 'Tempo');
  String get paceMinKm => _translate('paceMinKm', 'min/km');
  String get notes => _translate('notes', 'Notatki (opcjonalnie)');
  String get saveWorkout => _translate('saveWorkout', 'Zapisz trening');
  String get workoutSaved => _translate('workoutSaved', 'Trening został zapisany!');
  String get addExercise => _translate('addExercise', 'Dodaj ćwiczenie');
  String get addSet => _translate('addSet', 'Dodaj serię');
  String get exerciseName => _translate('exerciseName', 'Nazwa ćwiczenia');
  String get weight => _translate('weight', 'Ciężar (kg)');
  String get noExercises => _translate('noExercises', 'Brak ćwiczeń. Kliknij "Dodaj ćwiczenie" aby dodać pierwsze ćwiczenie.');
  String get noWeight => _translate('noWeight', 'bez ciężaru');
  String get cancel => _translate('cancel', 'Anuluj');
  String get add => _translate('add', 'Dodaj');
  String get provideExerciseName => _translate('provideExerciseName', 'Podaj nazwę ćwiczenia');
  String get provideReps => _translate('provideReps', 'Podaj liczbę powtórzeń');
  String get provideActivityName => _translate('provideActivityName', 'Podaj nazwę aktywności');
  String get editWorkout => _translate('editWorkout', 'Edytuj trening');
  String get saveChanges => _translate('saveChanges', 'Zapisz zmiany');
  String get workoutUpdated => _translate('workoutUpdated', 'Trening został zaktualizowany!');
  String get deleteWorkout => _translate('deleteWorkout', 'Usuń trening');
  String get deleteConfirmation => _translate('deleteConfirmation', 'Czy na pewno chcesz usunąć ten trening? Tej operacji nie można cofnąć.');
  String get delete => _translate('delete', 'Usuń');
  String get workoutDeleted => _translate('workoutDeleted', 'Trening został usunięty');
  String get deleteFailed => _translate('deleteFailed', 'Nie udało się usunąć treningu');
  String get workoutHistory => _translate('workoutHistory', 'Historia treningów');
  String get noWorkoutsInHistory => _translate('noWorkoutsInHistory', 'Brak treningów w historii');
  String get addWorkoutToSeeHere => _translate('addWorkoutToSeeHere', 'Dodaj trening, aby zobaczyć go tutaj');
  String get workoutDetails => _translate('workoutDetails', 'Szczegóły treningu');
  String get time => _translate('time', 'Czas');
  String get distanceLabel => _translate('distanceLabel', 'Dystans');
  String get notesLabel => _translate('notesLabel', 'Notatki');

  // Statistics
  String get workoutsThisWeek => _translate('workoutsThisWeek', 'Treningi w tym tygodniu');
  String get workoutsThisMonth => _translate('workoutsThisMonth', 'Treningi w tym miesiącu');
  String get allWorkoutsCount => _translate('allWorkoutsCount', 'Wszystkie treningi');
  String get chartsAndAnalytics => _translate('chartsAndAnalytics', 'Wykresy i analityka');
  String get detailedCharts => _translate('detailedCharts', 'Szczegółowe wykresy i analityka będą wyświetlane tutaj.');
  String get chartPlaceholder => _translate('chartPlaceholder', 'Miejsce na wykres');
  String get exerciseProgress => _translate('exerciseProgress', 'Progres ćwiczenia');
  String get viewMaxWeightHistory => _translate('viewMaxWeightHistory', 'Zobacz historię maksymalnych ciężarów');
  String get noStrengthExercises => _translate('noStrengthExercises', 'Brak ćwiczeń siłowych w historii');
  String get addStrengthWorkout => _translate('addStrengthWorkout', 'Dodaj trening siłowy z ćwiczeniami, aby zobaczyć progres');
  String get noWeightData => _translate('noWeightData', 'Brak danych o ciężarze');
  String get addWorkoutsWithWeight => _translate('addWorkoutsWithWeight', 'Dodaj treningi z tym ćwiczeniem i podaj ciężar, aby zobaczyć progres');
  String get maxWeight => _translate('maxWeight', 'Maksymalny ciężar');
  String get noDataForChart => _translate('noDataForChart', 'Brak danych do wyświetlenia');

  // Profile
  String get editProfile => _translate('editProfile', 'Edytuj profil');
  String get editProfileSoon => _translate('editProfileSoon', 'Funkcja edycji profilu wkrótce');
  String get exerciseSearch => _translate('exerciseSearch', 'Wyszukiwarka ćwiczeń');
  String get exerciseSearchSoon => _translate('exerciseSearchSoon', 'Funkcja wyszukiwarki ćwiczeń wkrótce');
  String get searchExercises => _translate('searchExercises', 'Szukaj ćwiczeń');
  String get searchExercisesHint => _translate('searchExercisesHint', 'Wpisz nazwę ćwiczenia...');
  String get noResults => _translate('noResults', 'Brak wyników');
  String get tryDifferentQuery => _translate('tryDifferentQuery', 'Spróbuj innej frazy wyszukiwania');
  String get additionalFeatures => _translate('additionalFeatures', 'Dodatkowe funkcje');
  String get moreProfileFeatures => _translate('moreProfileFeatures', 'Więcej funkcji profilu zostanie dodanych tutaj: osiągnięcia, historia treningów itp.');
  String get profileSaved => _translate('profileSaved', 'Profil został zapisany');
  String get name => _translate('name', 'Imię / Nick');
  String get nameHint => _translate('nameHint', 'np. Jan, Trener123');
  String get trainingGoal => _translate('trainingGoal', 'Cel treningowy');
  String get trainingGoalHint => _translate('trainingGoalHint', 'np. Budowanie masy, Utrata wagi, Wytrzymałość');
  String get provideName => _translate('provideName', 'Podaj imię lub nick');
  String get provideGoal => _translate('provideGoal', 'Podaj cel treningowy');
  String get completeProfile => _translate('completeProfile', 'Uzupełnij profil');
  String get save => _translate('save', 'Zapisz');

  // Difficulty
  String get beginner => _translate('beginner', 'Początkujący');
  String get intermediate => _translate('intermediate', 'Średnio zaawansowany');
  String get advanced => _translate('advanced', 'Zaawansowany');

  // Common
  String get today => _translate('today', 'Dzisiaj');
  String get yesterday => _translate('yesterday', 'Wczoraj');
  String get daysAgo => _translate('daysAgo', 'dni temu');
  String get filterByLevel => _translate('filterByLevel', 'Filtruj według poziomu');
  String get all => _translate('all', 'Wszystkie');
  String get restDay => _translate('restDay', 'Dzień odpoczynku');
  String get edit => _translate('edit', 'Edytuj');
  String get editPlanSoon => _translate('editPlanSoon', 'Funkcja edycji planu wkrótce');
  String get editPlan => _translate('editPlan', 'Edytuj plan');
  String get planSaved => _translate('planSaved', 'Plan został zapisany');
  String get monday => _translate('monday', 'Poniedziałek');
  String get tuesday => _translate('tuesday', 'Wtorek');
  String get wednesday => _translate('wednesday', 'Środa');
  String get thursday => _translate('thursday', 'Czwartek');
  String get friday => _translate('friday', 'Piątek');
  String get saturday => _translate('saturday', 'Sobota');
  String get sunday => _translate('sunday', 'Niedziela');
  String get moveUp => _translate('moveUp', 'Przenieś w górę');
  String get moveDown => _translate('moveDown', 'Przenieś w dół');
  String get remove => _translate('remove', 'Usuń');
  String get selectWorkout => _translate('selectWorkout', 'Wybierz trening');
  String get workout => _translate('workout', 'trening');
  String get workoutsPlural => _translate('workoutsPlural', 'treningów');
  String get workoutIdRequired => _translate('workoutIdRequired', 'Wymagane ID treningu');
  String get workoutNotFound => _translate('workoutNotFound', 'Treningu nie znaleziono');
  String get startTrainingTimer => _translate('startTrainingTimer', 'Timer treningu uruchomi się tutaj');
  String get workoutTimer => _translate('workoutTimer', 'Timer treningu');
  String get timerRunning => _translate('timerRunning', 'Timer działa');
  String get timerPaused => _translate('timerPaused', 'Timer wstrzymany');
  String get timerStopped => _translate('timerStopped', 'Timer zatrzymany');
  String get finishWorkout => _translate('finishWorkout', 'Zakończ trening');
  String get finishWorkoutConfirmation => _translate('finishWorkoutConfirmation', 'Czy na pewno chcesz zakończyć trening?');
  String get workoutDuration => _translate('workoutDuration', 'Czas trwania treningu:');
  String get finish => _translate('finish', 'Zakończ');
  String get pause => _translate('pause', 'Pauza');
  String get resume => _translate('resume', 'Wznów');
  String get reset => _translate('reset', 'Reset');
  String get start => _translate('start', 'Start');
  String get achievements => _translate('achievements', 'Osiągnięcia');
  String get unlocked => _translate('unlocked', 'odblokowanych');
  String get noAchievements => _translate('noAchievements', 'Brak osiągnięć');
  String get themeMode => _translate('themeMode', 'Tryb motywu');
  String get lightMode => _translate('lightMode', 'Jasny');
  String get lightModeDescription => _translate('lightModeDescription', 'Użyj jasnego motywu');
  String get darkMode => _translate('darkMode', 'Ciemny');
  String get darkModeDescription => _translate('darkModeDescription', 'Użyj ciemnego motywu');
  String get systemMode => _translate('systemMode', 'Systemowy');
  String get systemModeDescription => _translate('systemModeDescription', 'Użyj motywu systemowego');
  
  // Achievements
  String get achievementFirstStep => _translate('achievementFirstStep', 'Pierwszy krok');
  String get achievementFirstStepDesc => _translate('achievementFirstStepDesc', 'Ukończ swój pierwszy trening');
  String get achievementFiredUp => _translate('achievementFiredUp', 'Zapalony');
  String get achievementFiredUpDesc => _translate('achievementFiredUpDesc', 'Ukończ 5 treningów');
  String get achievementTen => _translate('achievementTen', 'Dziesiątka');
  String get achievementTenDesc => _translate('achievementTenDesc', 'Ukończ 10 treningów');
  String get achievementExerciser => _translate('achievementExerciser', 'Ćwiczący');
  String get achievementExerciserDesc => _translate('achievementExerciserDesc', 'Ukończ 25 treningów');
  String get achievementMaster => _translate('achievementMaster', 'Mistrz');
  String get achievementMasterDesc => _translate('achievementMasterDesc', 'Ukończ 50 treningów');
  String get achievementRunner => _translate('achievementRunner', 'Biegacz');
  String get achievementRunnerDesc => _translate('achievementRunnerDesc', 'Przebiegnij/przejedź 5 km');
  String get achievementMarathoner => _translate('achievementMarathoner', 'Maratończyk');
  String get achievementMarathonerDesc => _translate('achievementMarathonerDesc', 'Przebiegnij/przejedź 10 km');
  String get achievementTimeForTraining => _translate('achievementTimeForTraining', 'Czas na trening');
  String get achievementTimeForTrainingDesc => _translate('achievementTimeForTrainingDesc', 'Spędź 10 godzin na treningach');
  String get achievementHabit => _translate('achievementHabit', 'Nawyk');
  String get achievementHabitDesc => _translate('achievementHabitDesc', 'Ćwicz przez 3 dni z rzędu');
  String get achievementDiscipline => _translate('achievementDiscipline', 'Dyscyplina');
  String get achievementDisciplineDesc => _translate('achievementDisciplineDesc', 'Ćwicz przez 7 dni z rzędu');
  
  // Additional translations
  String get workoutName => _translate('workoutName', 'Nazwa treningu');
  String get workoutNameHint => _translate('workoutNameHint', 'np. Trening siłowy');
  String get provideWorkoutName => _translate('provideWorkoutName', 'Podaj nazwę treningu');
  String get workoutDescription => _translate('workoutDescription', 'Krótki opis treningu');
  String get addAtLeastOneExercise => _translate('addAtLeastOneExercise', 'Dodaj przynajmniej jedno ćwiczenie');
  String get error => _translate('error', 'Błąd');
  String get series => _translate('series', 'seria');
  String get seriesPlural => _translate('seriesPlural', 'serii');
  String get repetitions => _translate('repetitions', 'powtórzeń');
  String get timeLabel => _translate('timeLabel', 'Czas');
  String get distanceColon => _translate('distanceColon', 'Dystans');
  String get paceColon => _translate('paceColon', 'Tempo');
  String get notesColon => _translate('notesColon', 'Notatki');
  String get exerciseNameHint => _translate('exerciseNameHint', 'np. Przysiad, Wyciskanie na ławce');
  String get durationMinutesLabel => _translate('durationMinutesLabel', 'Czas trwania (minuty)');
  String get notesHint => _translate('notesHint', 'np. samopoczucie, kontuzja, uwagi do treningu');
  String get distanceKmLabel => _translate('distanceKmLabel', 'Dystans (km)');
  String get estimatedDuration => _translate('estimatedDuration', 'Szacowany czas (minuty)');
  String get estimatedDurationMinutes => _translate('estimatedDurationMinutes', 'minut');
  String get noExercisesMessage => _translate('noExercisesMessage', 'Brak ćwiczeń. Kliknij "Dodaj ćwiczenie" aby dodać pierwsze ćwiczenie.');
  String get restSeconds => _translate('restSeconds', 'Odpoczynek (sekundy)');

  /// Translate a key to the current locale.
  String _translate(String key, String polishText) {
    if (locale.languageCode == 'en') {
      return _getEnglishTranslation(key, polishText);
    }
    return polishText;
  }

  /// Get plural form of "workout" in Polish.
  /// Polish pluralization rules:
  /// - 1: trening
  /// - 2-4, 22-24, 32-34, etc. (but not 12-14): treningi
  /// - 5-21, 25-31, etc., or 12-14: treningów
  String getWorkoutPlural(int count) {
    if (locale.languageCode == 'pl') {
      if (count == 1) {
        return 'trening';
      }
      final mod10 = count % 10;
      final mod100 = count % 100;
      // 2-4, 22-24, 32-34, etc. (but not 12-14)
      if ((mod10 >= 2 && mod10 <= 4) && !(mod100 >= 12 && mod100 <= 14)) {
        return 'treningi';
      }
      // 5-21, 25-31, etc., or 12-14
      return 'treningów';
    } else {
      // English
      return count == 1 ? 'workout' : 'workouts';
    }
  }

  /// Get English translation for a key.
  String _getEnglishTranslation(String key, String polishText) {
    // English translations
    final translations = {
      'home': 'Home',
      'workouts': 'Workouts',
      'plan': 'Plan',
      'statistics': 'Statistics',
      'profile': 'Profile',
      'hello': 'Hello',
      'readyForWorkout': 'Ready for today\'s workout?',
      'todayWorkout': 'Today\'s Workout',
      'startWorkout': 'Start Workout',
      'thisWeek': 'This Week',
      'suggestions': 'Suggestions',
      'workoutsCount': 'Workouts',
      'thisMonth': 'This Month',
      'statisticsTitle': 'Statistics',
      'totalTime': 'Total Time',
      'allWorkouts': 'All Workouts',
      'recentWorkouts': 'Recent Workouts',
      'addWorkout': 'Add Workout',
      'last7Days': 'Last 7 Days',
      'distanceKm': 'Distance [km]',
      'timeMin': 'Time [min]',
      'settings': 'Settings',
      'appLanguage': 'App Language',
      'language': 'Language',
      'polish': 'Polish',
      'polishLanguage': 'Polish language',
      'english': 'English',
      'englishLanguage': 'English language',
      'units': 'Units',
      'kilometers': 'Kilometers (km)',
      'metricUnit': 'Metric unit',
      'miles': 'Miles (mi)',
      'imperialUnit': 'Imperial unit',
      'settingsSaved': 'Settings saved',
      'resetToDefaults': 'Reset to Defaults',
      'resetSettings': 'Reset Settings',
      'resetConfirmation': 'Are you sure you want to reset all settings to default values?',
      'workoutDetail': 'Workout Details',
      'exercises': 'Exercises',
      'sets': 'sets',
      'set': 'set',
      'reps': 'reps',
      'rest': 'Rest',
      'markAsDone': 'Mark as Done',
      'completed': 'Completed',
      'workoutMarkedAsCompleted': 'Workout marked as completed!',
      'addWorkoutToHistory': 'Add Workout to History',
      'workoutDate': 'Workout Date',
      'activityType': 'Activity Type',
      'gym': 'Gym',
      'running': 'Running',
      'cycling': 'Cycling',
      'swimming': 'Swimming',
      'other': 'Other',
      'activityName': 'Activity Name',
      'additionalInfo': 'Additional Information (optional)',
      'durationMinutes': 'Duration (minutes)',
      'minutes': 'Minutes',
      'seconds': 'Seconds',
      'distance': 'Distance (km)',
      'pace': 'Pace',
      'paceMinKm': 'min/km',
      'notes': 'Notes (optional)',
      'saveWorkout': 'Save Workout',
      'workoutSaved': 'Workout saved!',
      'addExercise': 'Add Exercise',
      'addSet': 'Add Set',
      'exerciseName': 'Exercise Name',
      'weight': 'Weight (kg)',
      'noExercises': 'No exercises. Click "Add Exercise" to add the first exercise.',
      'noWeight': 'no weight',
      'cancel': 'Cancel',
      'add': 'Add',
      'provideExerciseName': 'Enter exercise name',
      'provideReps': 'Enter number of repetitions',
      'provideActivityName': 'Enter activity name',
      'editWorkout': 'Edit Workout',
      'saveChanges': 'Save Changes',
      'workoutUpdated': 'Workout has been updated!',
      'deleteWorkout': 'Delete Workout',
      'deleteConfirmation': 'Are you sure you want to delete this workout? This action cannot be undone.',
      'delete': 'Delete',
      'workoutDeleted': 'Workout has been deleted',
      'deleteFailed': 'Failed to delete workout',
      'workoutHistory': 'Workout History',
      'noWorkoutsInHistory': 'No workouts in history',
      'addWorkoutToSeeHere': 'Add a workout to see it here',
      'workoutDetails': 'Workout Details',
      'time': 'Time',
      'distanceLabel': 'Distance',
      'notesLabel': 'Notes',
      'workoutsThisWeek': 'Workouts This Week',
      'workoutsThisMonth': 'Workouts This Month',
      'allWorkoutsCount': 'All Workouts',
      'chartsAndAnalytics': 'Charts and Analytics',
      'detailedCharts': 'Detailed charts and analytics will be displayed here.',
      'chartPlaceholder': 'Chart Placeholder',
      'exerciseProgress': 'Exercise Progress',
      'viewMaxWeightHistory': 'View maximum weight history',
      'noStrengthExercises': 'No strength exercises in history',
      'addStrengthWorkout': 'Add a strength workout with exercises to see progress',
      'noWeightData': 'No weight data',
      'addWorkoutsWithWeight': 'Add workouts with this exercise and provide weight to see progress',
      'maxWeight': 'Maximum Weight',
      'noDataForChart': 'No data to display',
      'editProfile': 'Edit Profile',
      'editProfileSoon': 'Edit profile feature coming soon',
      'exerciseSearch': 'Exercise Search',
      'exerciseSearchSoon': 'Exercise search feature coming soon',
      'searchExercises': 'Search Exercises',
      'searchExercisesHint': 'Enter exercise name...',
      'noResults': 'No results',
      'tryDifferentQuery': 'Try a different search query',
      'additionalFeatures': 'Additional Features',
      'moreProfileFeatures': 'More profile features will be added here: achievements, workout history, etc.',
      'profileSaved': 'Profile saved',
      'name': 'Name / Nickname',
      'nameHint': 'e.g. John, Trainer123',
      'trainingGoal': 'Training Goal',
      'trainingGoalHint': 'e.g. Build muscle, Lose weight, Endurance',
      'provideName': 'Enter name or nickname',
      'provideGoal': 'Enter training goal',
      'completeProfile': 'Complete Profile',
      'save': 'Save',
      'beginner': 'Beginner',
      'intermediate': 'Intermediate',
      'advanced': 'Advanced',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'daysAgo': 'days ago',
      'filterByLevel': 'Filter by Level',
      'all': 'All',
      'restDay': 'Rest Day',
      'edit': 'Edit',
      'editPlanSoon': 'Edit plan feature coming soon',
      'editPlan': 'Edit Plan',
      'planSaved': 'Plan saved',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'moveUp': 'Move Up',
      'moveDown': 'Move Down',
      'remove': 'Remove',
      'selectWorkout': 'Select Workout',
      'workout': 'workout',
      'workoutsPlural': 'workouts',
      'workoutIdRequired': 'Workout ID required',
      'workoutNotFound': 'Workout not found',
      'startTrainingTimer': 'Training timer will start here',
      'workoutName': 'Workout Name',
      'workoutNameHint': 'e.g. Strength Training',
      'provideWorkoutName': 'Enter workout name',
      'workoutDescription': 'Short workout description',
      'addAtLeastOneExercise': 'Add at least one exercise',
      'error': 'Error',
      'series': 'Series',
      'seriesPlural': 'series',
      'repetitions': 'repetitions',
      'timeLabel': 'Time',
      'distanceColon': 'Distance',
      'paceColon': 'Pace',
      'notesColon': 'Notes',
      'exerciseNameHint': 'e.g. Squat, Bench Press',
      'durationMinutesLabel': 'Duration (minutes)',
      'notesHint': 'e.g. mood, injury, workout notes',
      'distanceKmLabel': 'Distance (km)',
      'achievements': 'Achievements',
      'unlocked': 'unlocked',
      'noAchievements': 'No achievements',
      'themeMode': 'Theme Mode',
      'lightMode': 'Light',
      'lightModeDescription': 'Use light theme',
      'darkMode': 'Dark',
      'darkModeDescription': 'Use dark theme',
      'systemMode': 'System',
      'systemModeDescription': 'Use system theme',
      'achievementFirstStep': 'First Step',
      'achievementFirstStepDesc': 'Complete your first workout',
      'achievementFiredUp': 'Fired Up',
      'achievementFiredUpDesc': 'Complete 5 workouts',
      'achievementTen': 'Ten',
      'achievementTenDesc': 'Complete 10 workouts',
      'achievementExerciser': 'Exerciser',
      'achievementExerciserDesc': 'Complete 25 workouts',
      'achievementMaster': 'Master',
      'achievementMasterDesc': 'Complete 50 workouts',
      'achievementRunner': 'Runner',
      'achievementRunnerDesc': 'Run/ride 5 km',
      'achievementMarathoner': 'Marathoner',
      'achievementMarathonerDesc': 'Run/ride 10 km',
      'achievementTimeForTraining': 'Time for Training',
      'achievementTimeForTrainingDesc': 'Spend 10 hours on workouts',
      'achievementHabit': 'Habit',
      'achievementHabitDesc': 'Exercise for 3 days in a row',
      'achievementDiscipline': 'Discipline',
      'achievementDisciplineDesc': 'Exercise for 7 days in a row',
      'estimatedDuration': 'Estimated Duration (minutes)',
      'estimatedDurationMinutes': 'minutes',
      'noExercisesMessage': 'No exercises. Click "Add Exercise" to add the first exercise.',
      'restSeconds': 'Rest (seconds)',
    };

    return translations[key] ?? polishText;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'pl'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
