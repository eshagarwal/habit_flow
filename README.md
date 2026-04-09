# HabitFlow - Flutter Habit & Fitness Tracker

HabitFlow is a production-quality Flutter application demonstrating professional mobile engineering through a comprehensive habit and fitness tracking system. Built with modern architecture patterns, responsive UI design, and comprehensive testing.

## Features

### ✨ Core Functionality
- **Habit Management** - Create, edit, archive, and delete habits with flexible scheduling
- **Daily Dashboard** - Track today's progress with visual completion status and quick actions
- **Weekly & Monthly Tracking** - View habit completion trends across time periods
- **Streaks & Statistics** - Automatic calculation of current/longest streaks
- **Habit Details** - Comprehensive view with timeline, statistics, and edit options
- **History & Calendar** - Visual calendar with monthly summaries and completion rates

### 📊 Analytics & Visualization
- **Statistics Dashboard** - Multiple chart types (bar, line, pie) for habit analysis
- **Completion Rates** - Track percentage completion for each habit
- **Trend Analysis** - Visual representation of habit performance over time
- **Monthly Summaries** - Quick overview of completion rates by month

### 🔔 Notifications & Reminders
- **Smart Reminders** - Timezone-aware local notifications for habit reminders
- **Customizable Timing** - Set reminders for specific times of day
- **Background Support** - Reminders work even when app is closed

### 🎨 User Experience
- **Material 3 Design** - Modern, clean UI following Material Design 3 guidelines
- **Dark Mode Support** - Full light/dark theme with system preference detection
- **Responsive Layout** - Optimized for all screen sizes
- **Smooth Animations** - Polished transitions throughout the app
- **Onboarding Flow** - 3-page animated introduction for new users

### 💾 Data & Persistence
- **Offline-First** - Complete functionality without internet connection
- **Local Database** - Isar for efficient local data persistence
- **Real-Time Updates** - UI automatically reflects data changes via Riverpod

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Dart) |
| **State Management** | Riverpod |
| **Navigation** | GoRouter |
| **Database** | Isar |
| **Notifications** | flutter_local_notifications |
| **Theming** | Material 3 with Riverpod providers |
| **Testing** | flutter_test, mocktail |

## Architecture

HabitFlow follows a clean, layered architecture separating concerns:

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Main app widget with Riverpod setup
├── routing/                     # Navigation configuration
│   └── app_router.dart         # GoRouter with 7 screens
├── domain/                      # Business logic & entities
│   └── models/                 # Habit, HabitEntry, ReminderConfig
├── data/                        # Data layer
│   ├── providers.dart          # All Riverpod providers
│   ├── repositories/           # Data abstraction layer
│   └── services/               # Business logic (StreakService, ReminderService)
└── ui/                         # Presentation layer
    ├── core/                   # Shared widgets & theme
    ├── onboarding/             # Onboarding screens
    ├── dashboard/              # Main dashboard
    ├── habits/                 # Create/edit habits
    ├── history/                # Calendar & history view
    ├── stats/                  # Analytics & charts
    └── settings/               # Settings & preferences
```

### Key Architectural Decisions

1. **Feature-First Organization** - Each feature has its own directory with screens, widgets, and state
2. **Provider-Based State** - Riverpod manages all app state (habits, theme, filters)
3. **Repository Pattern** - Data access abstracted through repositories
4. **Service Layer** - Complex logic (streak calculation, reminders) isolated in services
5. **Responsive UI** - Screens adapt to different screen sizes using LayoutBuilder

## Getting Started

### Prerequisites
- Flutter SDK (≥3.0.0)
- Dart SDK (≥3.0.0)
- iOS 11+ or Android 5.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/habit_flow.git
   cd habit_flow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Isar boilerplate** (if modifying database schemas)
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Running on Different Platforms

```bash
# iOS
flutter run -d iphone

# Android
flutter run -d android

# Web (if enabled)
flutter run -d chrome
```

## Testing

### Unit & Widget Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget/dashboard/dashboard_screen_test.dart

# Run with coverage
flutter test --coverage
```

### Integration Tests
```bash
flutter test test/integration_test/app_flow_test.dart
```

### Testing Coverage
- **Dashboard Screen** - 5 test cases covering main functionality
- **Stats Screen** - 5 test cases for analytics display
- **Create Habit Screen** - 7 test cases for form validation
- **Providers** - Unit tests for business logic

## Screens & Navigation

| Screen | Purpose | Features |
|--------|---------|----------|
| **Onboarding** | First-time user introduction | 3-page animated flow, skip option |
| **Dashboard** | Main app interface | Today's habits, completion status, quick actions |
| **Habit Detail** | Individual habit view | Statistics, timeline, edit/delete options |
| **Create/Edit Habit** | Habit creation & modification | Form validation, time picker, schedule selection |
| **History** | Calendar & completion tracking | Visual calendar, monthly summaries |
| **Statistics** | Analytics & trends | Multiple chart types, completion rates |
| **Settings** | App preferences | Theme selection (Light/Dark/System), notifications |

## Key Features Implementation

### Habit Completion Status
- Completed habits show with icon and color highlight
- Smart sorting: incomplete habits at top, completed at bottom
- Real-time updates across all screens

### Streak Calculation
- Automatic tracking of current and longest streaks
- Handles gaps in habit completion
- Displayed on dashboard and detail screens

### Theme System
- Light/Dark/System modes with persistent user preference
- Material 3 color scheme
- Dynamic theme provider using Riverpod

### Data Providers
- `habitsProvider` - All user habits
- `habitEntriesProvider` - Completion history
- `themeProvider` - User theme preference
- `statsProvider` - Computed statistics
- `monthEntriesProvider` - Monthly habit data

## Performance Optimizations

- **Efficient Rebuilds** - Riverpod ensures only affected widgets rebuild
- **Lazy Loading** - Data loaded on-demand
- **Database Indexing** - Isar queries optimized for common access patterns
- **Memory Management** - Proper disposal of resources

## Future Enhancements

- [ ] Cloud sync with Firebase
- [ ] Habit templates and suggestions
- [ ] Social features (share habits, friend tracking)
- [ ] Advanced analytics and insights
- [ ] Habit categories and grouping
- [ ] Custom reminders and quiet hours
- [ ] Export data functionality
- [ ] Habit streaks leaderboard

## Project Documentation

- **[IMPLEMENTATION_STATUS.md](./IMPLEMENTATION_STATUS.md)** - Detailed feature completion status and architecture overview
- **[flutter_habit_tracker_project_brief.md](./flutter_habit_tracker_project_brief.md)** - Original project specification and requirements

## Development Guide

### Adding a New Screen
1. Create feature directory under `lib/ui/`
2. Add `views/` subdirectory with screen widget
3. Create Riverpod providers in `data/providers.dart` if needed
4. Add route in `routing/app_router.dart`
5. Add navigation in `lib/ui/core/widgets/bottom_navigation.dart`

### Adding a New Provider
1. Define in `lib/data/providers.dart`
2. Use `@riverpod` annotation for auto-generation
3. Update `pubspec.yaml` if adding new dependencies
4. Run `flutter pub run build_runner build` if using code generation

### Testing a Feature
1. Create test file in `test/widget/` matching feature structure
2. Use mocktail for mocking Riverpod providers
3. Include test cases for happy path and edge cases
4. Run `flutter test` to verify

## Code Quality

- **Linting** - Uses `analysis_options.yaml` with strict Dart rules
- **Formatting** - Code formatted with `dart format`
- **Testing** - Comprehensive widget and unit test coverage
- **Documentation** - Code comments for complex logic

## License

This project is provided as-is for portfolio purposes.

## Support

For issues, questions, or feedback, please refer to the project documentation or create an issue in the repository.
