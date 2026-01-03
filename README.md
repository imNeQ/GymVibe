# 💪 GymVibe

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)

**Aplikacja mobilna do planowania i śledzenia treningów domowych oraz siłowniowych**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Screenshots](#-screenshots) • [Tech Stack](#-tech-stack)

</div>

---

## 📖 O projekcie

**GymVibe** to nowoczesna aplikacja mobilna stworzona w Flutter, która pomaga użytkownikom planować, śledzić i analizować swoje treningi. Aplikacja oferuje kompleksowe rozwiązanie do zarządzania treningami siłowymi, cardio oraz innymi formami aktywności fizycznej.

### ✨ Główne zalety

- 🚀 **Działa bez logowania** - rozpocznij od razu, bez zbędnych formalności
- 💾 **Lokalne przechowywanie danych** - wszystkie dane są bezpiecznie przechowywane na urządzeniu
- 🌍 **Dwujęzyczność** - pełne wsparcie dla języka polskiego i angielskiego
- 🎨 **Material 3 Design** - nowoczesny, intuicyjny interfejs użytkownika
- 🌙 **Dark Mode** - przyjazny dla oczu tryb ciemny
- 📊 **Szczegółowe statystyki** - śledź swój progres w czasie

---

## 🎯 Features

### 📊 Dashboard
- **Przegląd tygodniowy** - szybki podgląd liczby treningów w bieżącym tygodniu
- **Ostatnie treningi** - lista 5 najnowszych aktywności
- **Statystyki** - suma dystansu i czasu z ostatnich 7 dni
- **Sugestie treningów** - rekomendacje na podstawie planu

### 🏋️ Zarządzanie treningami
- **Dodawanie treningów** - szybkie dodawanie treningów z dashboardu
- **Historia treningów** - pełna lista wszystkich aktywności
- **Szczegóły treningu** - kompletne informacje o każdym treningu
- **Edycja i usuwanie** - możliwość modyfikacji i usuwania własnych treningów
- **Własne treningi** - tworzenie i zapisywanie własnych planów treningowych

### 💪 Treningi siłowe
- **Ćwiczenia i serie** - szczegółowe śledzenie ćwiczeń z seriami i powtórzeniami
- **Ciężary** - zapisywanie użytych ciężarów
- **Progres** - analiza postępów w wybranych ćwiczeniach

### 🏃 Treningi cardio
- **Dystans i czas** - śledzenie dystansu i czasu trwania
- **Tempo** - automatyczne obliczanie tempa (min/km)
- **Różne aktywności** - bieganie, rower, pływanie i inne

### 📅 Plan tygodniowy
- **Plan treningowy** - tygodniowy harmonogram treningów
- **Edycja planu** - dodawanie, usuwanie i zmiana kolejności treningów
- **Wiele treningów dziennie** - możliwość przypisania wielu treningów do jednego dnia

### 📈 Statystyki
- **Wykresy** - wizualizacja treningów w czasie
- **Progres ćwiczeń** - śledzenie maksymalnych ciężarów
- **Podsumowania** - statystyki tygodniowe i miesięczne

### 👤 Profil użytkownika
- **Edycja profilu** - personalizacja imienia i celu treningowego
- **Osiągnięcia** - system odznak za osiągnięcia
- **Historia treningów** - ostatnie 3-5 treningów w profilu
- **Wyszukiwarka ćwiczeń** - szybkie wyszukiwanie ćwiczeń

### ⚙️ Ustawienia
- **Język** - wybór między polskim a angielskim
- **Jednostki** - wybór jednostek dystansu (km/mile)
- **Motyw** - tryb jasny, ciemny lub systemowy
- **Reset ustawień** - przywracanie domyślnych wartości

### ⏱️ Timer treningu
- **Timer z pauzą** - śledzenie czasu trwania treningu
- **Plan treningu** - wyświetlanie planu podczas treningu
- **Automatyczne zapisywanie** - zapis czasu trwania po zakończeniu

---

## 📸 Screenshots

<div align="center">

| Dashboard | Workouts | Plan |
|:---------:|:--------:|:----:|
| ![Dashboard](https://github.com/imNeQ/GymVibe/raw/main/assets/images/1.PNG) | ![Workouts](https://github.com/imNeQ/GymVibe/raw/main/assets/images/2.PNG) | ![Plan](https://github.com/imNeQ/GymVibe/raw/main/assets/images/3.PNG) |

| Statistics | Profile | Edit Profile |
|:----------:|:-------:|:--------:|
| ![Statistics](https://github.com/imNeQ/GymVibe/raw/main/assets/images/4.PNG) | ![Profile](https://github.com/imNeQ/GymVibe/raw/main/assets/images/5.PNG) | ![Edit Profile](https://github.com/imNeQ/GymVibe/raw/main/assets/images/6.PNG) |

| Settings | Workout History | Exercise Search |
|:-----------:|:---------------:|:---------------:|
| ![Settings](https://github.com/imNeQ/GymVibe/raw/main/assets/images/7.PNG) | ![Workout History](https://github.com/imNeQ/GymVibe/raw/main/assets/images/8.PNG) | ![Exercise Search](https://github.com/imNeQ/GymVibe/raw/main/assets/images/9.PNG) |

| Add Workout |
|:------------:|
| ![Add Workout](https://github.com/imNeQ/GymVibe/raw/main/assets/images/10.PNG) |

</div>

---

## 🚀 Installation

### Wymagania

- **Flutter SDK** >= 3.0.0
- **Dart** >= 3.0.0
- **Android Studio / VS Code** z rozszerzeniem Flutter
- **Emulator/Urządzenie** (Android/iOS) lub przeglądarka (web)

### Kroki instalacji

1. **Sklonuj repozytorium**
   ```bash
   git clone https://github.com/imNeQ/GymVibe.git
   cd GymVibe
   ```

2. **Zainstaluj zależności**
   ```bash
   flutter pub get
   ```

3. **Sprawdź konfigurację Flutter**
   ```bash
   flutter doctor
   ```

---

## 💻 Usage

### Uruchomienie aplikacji

#### Na emulatorze/urządzeniu mobilnym:
```bash
# Sprawdź dostępne urządzenia
flutter devices

# Uruchom aplikację
flutter run
```

#### Na web (przeglądarka):
```bash
flutter run -d chrome
# lub
flutter run -d edge
```

#### Wybór konkretnego urządzenia:
```bash
# Lista dostępnych urządzeń
flutter devices

# Uruchom na konkretnym urządzeniu
flutter run -d <device-id>
```

### Hot Reload

Podczas działania aplikacji możesz używać:
- **`r`** - Hot reload (szybkie odświeżenie)
- **`R`** - Hot restart (pełne przeładowanie)
- **`q`** - Wyjście z aplikacji

### Build aplikacji

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS (wymaga macOS)
flutter build ios

# Web
flutter build web
```

---

## 🏗️ Project Structure

```
lib/
├── main.dart                    # Punkt wejścia aplikacji
├── core/
│   ├── models/                  # Modele danych
│   │   ├── workout.dart
│   │   ├── exercise.dart
│   │   ├── workout_plan.dart
│   │   ├── completed_workout.dart
│   │   ├── user_profile.dart
│   │   └── achievement.dart
│   ├── services/                # Serwisy biznesowe
│   │   ├── mock_data.dart
│   │   ├── workout_history_service.dart
│   │   ├── custom_workout_service.dart
│   │   ├── weekly_plan_service.dart
│   │   ├── user_profile_service.dart
│   │   ├── achievement_service.dart
│   │   ├── exercise_search_service.dart
│   │   └── settings_service.dart
│   ├── theme/
│   │   └── app_theme.dart       # Konfiguracja motywu Material 3
│   ├── navigation/
│   │   └── main_navigation.dart # Główna nawigacja z bottom bar
│   ├── localization/
│   │   └── app_localizations.dart # Lokalizacja PL/EN
│   ├── routes.dart              # Named routes
│   └── utils/
│       └── translations.dart    # Pomocnicze funkcje tłumaczeń
├── features/
│   ├── dashboard/               # Ekran główny
│   │   └── dashboard_page.dart
│   ├── workouts/                # Zarządzanie treningami
│   │   ├── workout_list_page.dart
│   │   ├── workout_detail_page.dart
│   │   ├── add_workout_page.dart
│   │   ├── add_workout_history_page.dart
│   │   ├── edit_workout_history_page.dart
│   │   ├── workout_history_list_page.dart
│   │   ├── workout_history_detail_page.dart
│   │   └── workout_timer_page.dart
│   ├── plans/                   # Plan tygodniowy
│   │   ├── plan_page.dart
│   │   └── edit_plan_page.dart
│   ├── statistics/              # Statystyki
│   │   ├── statistics_page.dart
│   │   └── exercise_progress_page.dart
│   ├── profile/                 # Profil użytkownika
│   │   ├── profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   └── exercise_search_page.dart
│   └── settings/                # Ustawienia
│       └── settings_page.dart
└── widgets/
    └── custom_button.dart       # Reużywalne komponenty
```

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) 3.0+
- **Język:** [Dart](https://dart.dev/) 3.0+
- **Design System:** Material 3
- **State Management:** StatefulWidget (bez dodatkowych bibliotek)
- **Routing:** Navigator 1.0
- **Local Storage:** SharedPreferences
- **Localization:** Flutter Localizations (PL/EN)

### Główne zależności

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  shared_preferences: ^2.2.2
```

---

## 🧪 Testing

```bash
# Uruchom wszystkie testy
flutter test

# Testy z coverage
flutter test --coverage

# Analiza kodu
flutter analyze
```

---

## 📝 Development

### Analiza kodu

Przed commitem zawsze uruchom:
```bash
flutter analyze
```

### Struktura testów

```
test/
├── integration/          # Testy integracyjne
├── models/              # Testy modeli
├── services/            # Testy serwisów
└── widgets/             # Testy widgetów
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Development Team** - *Initial work*
