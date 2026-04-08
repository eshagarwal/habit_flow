# HabitFlow - Flutter Habit & Fitness Tracker

HabitFlow is a portfolio-grade Flutter application designed to demonstrate production-oriented mobile engineering skills through a habit and fitness tracker.

## Features
- **Habit Management:** Create, edit, archive, and delete habits.
- **Daily Dashboard:** Track today's progress, mark complete, and undo.
- **Scheduling:** Support for daily and weekly habits.
- **Streaks & Stats:** Calculates current and longest streaks.
- **Local Notifications:** Reminders using `flutter_local_notifications`.
- **Offline-First:** Local persistence using Isar.
- **Dark Mode:** System-aware theme support.

## Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Routing:** go_router
- **Local Database:** Isar
- **Notifications:** flutter_local_notifications
- **Testing:** flutter_test, integration_test, mocktail

## Architecture
The project follows a layered, feature-first architecture:
- **`domain/`**: Core models (`Habit`, `HabitEntry`) and enums.
- **`data/`**: Repositories for data abstraction, Services for business logic (`StreakService`).
- **`ui/`**: Feature modules (`dashboard`, `habits`, `history`, `stats`, `settings`).

## How to Run
1. Ensure you have Flutter installed.
2. Clone this repository and run `flutter pub get`.
3. (Optional) Run `flutter pub run build_runner build` to generate Isar boilerplate if modifying schemas.
4. Run the app with `flutter run`.

## How to Test
- **Unit & Widget Tests:** Run `flutter test`
- **Integration Tests:** Run `flutter test test/integration_test/app_flow_test.dart`

## Future Improvements
- Cloud sync with Firebase.
- Interactive charts using fl_chart.
- Complex recurrence rules.
