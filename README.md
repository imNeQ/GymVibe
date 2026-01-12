# 💪 GymVibe

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20Web-blue)

**Aplikacja mobilna do planowania i śledzenia treningów domowych oraz siłowniowych**

[Funkcje](#-funkcje) • [Instalacja](#-instalacja) • [Użycie](#-użycie) • [Zrzuty ekranu](#-zrzuty-ekranu) • [Stack technologiczny](#-stack-technologiczny)

</div>

---

## 📖 O projekcie

**GymVibe** to aplikacja mobilna stworzona w Flutter do planowania i śledzenia treningów siłowych oraz cardio.

---

## 🎯 Funkcje

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

| Dashboard | Treningi | Plan |
|:---------:|:--------:|:----:|
| ![Dashboard](https://github.com/imNeQ/GymVibe/raw/main/assets/images/1.PNG) | ![Treningi](https://github.com/imNeQ/GymVibe/raw/main/assets/images/2.PNG) | ![Plan](https://github.com/imNeQ/GymVibe/raw/main/assets/images/3.PNG) |

| Statystyki | Profil | Edytuj Profil |
|:----------:|:-------:|:--------:|
| ![Statystyki](https://github.com/imNeQ/GymVibe/raw/main/assets/images/4.PNG) | ![Profil](https://github.com/imNeQ/GymVibe/raw/main/assets/images/5.PNG) | ![Edytuj Profil](https://github.com/imNeQ/GymVibe/raw/main/assets/images/6.PNG) |

| Ustawienia | Historia treningów | Wyszukiwarka ćwiczeń |
|:-----------:|:---------------:|:---------------:|
| ![Ustawienia](https://github.com/imNeQ/GymVibe/raw/main/assets/images/7.PNG) | ![Historia treningów](https://github.com/imNeQ/GymVibe/raw/main/assets/images/8.PNG) | ![Wyszukiwarka ćwiczeń](https://github.com/imNeQ/GymVibe/raw/main/assets/images/9.PNG) |

| Dodaj trening |
|:------------:|
| ![Dodaj trening](https://github.com/imNeQ/GymVibe/raw/main/assets/images/10.PNG) |

</div>

---

## 🚀 Instalacja

### Wymagania

- **Flutter SDK** >= 3.0.0
- **Dart** >= 3.0.0
- **Android Studio / VS Code** z rozszerzeniem Flutter
- **Emulator/Urządzenie** (Android/iOS/Windows) lub przeglądarka (web)

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

## 💻 Użycie

### Uruchomienie aplikacji

#### Na emulatorze/urządzeniu mobilnym:
```bash
# Sprawdź dostępne urządzenia
flutter devices

# Uruchom aplikację
flutter run
```

#### Na Windows:
```bash
flutter run -d windows
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

# Windows
flutter build windows

# Web
flutter build web
```

---

## 🏗️ Struktura projektu

```
lib/
├── main.dart                    
├── core/
│   ├── models/                  
│   │   ├── workout.dart
│   │   ├── exercise.dart
│   │   ├── exercise_set.dart
│   │   ├── strength_exercise.dart
│   │   ├── exercise_info.dart
│   │   ├── workout_plan.dart
│   │   ├── completed_workout.dart
│   │   ├── user_profile.dart
│   │   └── achievement.dart
│   ├── services/                
│   │   ├── mock_data.dart
│   │   ├── workout_history_service.dart
│   │   ├── custom_workout_service.dart
│   │   ├── weekly_plan_service.dart
│   │   ├── user_profile_service.dart
│   │   ├── achievement_service.dart
│   │   ├── exercise_search_service.dart
│   │   └── settings_service.dart
│   ├── theme/
│   │   └── app_theme.dart       
│   ├── navigation/
│   │   └── main_navigation.dart 
│   ├── localization/
│   │   └── app_localizations.dart 
│   └── routes.dart             
├── features/
│   ├── dashboard/               
│   │   └── dashboard_page.dart
│   ├── workouts/               
│   │   ├── workout_list_page.dart
│   │   ├── workout_detail_page.dart
│   │   ├── add_workout_page.dart
│   │   ├── add_workout_history_page.dart
│   │   ├── edit_workout_history_page.dart
│   │   ├── workout_history_list_page.dart
│   │   ├── workout_history_detail_page.dart
│   │   └── workout_timer_page.dart
│   ├── plans/                   
│   │   ├── plan_page.dart
│   │   └── edit_plan_page.dart
│   ├── statistics/             
│   │   ├── statistics_page.dart
│   │   └── exercise_progress_page.dart
│   ├── profile/                 
│   │   ├── profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   └── exercise_search_page.dart
│   └── settings/                
│       └── settings_page.dart
└── widgets/
    └── custom_button.dart       
```

---

## 🛠️ Stack technologiczny

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

## 🧪 Testowanie

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
├── models/              # Testy modeli
└── services/            # Testy serwisów
```

---

## 👥 Autorzy

Projekt realizowany w ramach przedmiotu **Zwinne zarządzanie projektami**.

- Łukasz Augusewicz
- Tomasz Czarnota
- Szymon Fiałkowski
- Gabriela Sumera
- Grzegorz Stanik
- Michał Nowak
