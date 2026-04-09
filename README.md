# HabitFlow - Flutter Habit & Fitness Tracker

HabitFlow is a production-quality Flutter application demonstrating professional mobile engineering through a comprehensive habit and fitness tracking system. Built with clean architecture, responsive Material 3 design, and comprehensive testing.

## ✨ Features

### Habit Management
- **Create Habits** - Add habits with title, description, category, and scheduling
- **Edit Habits** - Modify habit details with real-time updates
- **Delete & Archive** - Remove or archive habits as needed
- **Flexible Scheduling** - Support for daily and weekly recurring habits
- **Habit Categories** - Organize by Fitness, Health, Study, or Custom categories

### Daily Dashboard
- **Today's View** - See all habits due today at a glance
- **Progress Tracking** - Circular progress indicator showing daily completion percentage
- **Quick Actions** - Mark habits complete with a single tap
- **Undo Functionality** - Reverse mistaken completions
- **Empty States** - Helpful prompts when no habits exist
- **Bottom Navigation** - Easy access to all app screens

### Streak & Analytics
- **Current Streak** - Track consecutive days of habit completion
- **Longest Streak** - See your best performance periods
- **Completion Rates** - Percentage-based habit success metrics
- **Total Completions** - View total times habits have been completed
- **Historical Data** - Complete history of all habit entries

### History & Calendar
- **Calendar View** - Visual representation of completion history
- **Monthly Summaries** - See completion percentages by month
- **Heatmap Display** - Color-coded completion patterns
- **Activity Timeline** - Review when habits were completed

### Statistics & Charts
- **Bar Charts** - Daily and weekly completion visualization
- **Line Charts** - Trend analysis over time
- **Pie Charts** - Category and habit distribution
- **Performance Cards** - Summary metrics at a glance
- **Real Data** - All statistics calculated from actual habit entries

### Reminders & Notifications
- **Local Notifications** - Timezone-aware reminder scheduling
- **Custom Timing** - Set reminder times for each habit
- **Enable/Disable** - Control reminders per habit
- **Settings Toggle** - Master notification switch in settings
- **Cross-Platform** - Works on both iOS and Android

### User Experience
- **Material 3 Design** - Modern, clean UI following Material Design 3 guidelines
- **Light & Dark Modes** - Full theme support with system preference detection
- **Responsive Layout** - Optimized for all screen sizes
- **Form Validation** - Clear error messages and inline validation
- **Loading States** - Visual feedback during data operations
- **Onboarding Flow** - 3-page animated introduction for new users

### Data & Persistence
- **Offline-First** - Complete functionality without internet connection
- **Local Database** - Isar provides fast, reliable local persistence
- **Real-Time Updates** - UI automatically reflects data changes via Riverpod
- **Automatic Persistence** - All changes saved immediately to device

## Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Framework** | Flutter | 3.x |
| **Language** | Dart | 3.x |
| **State Management** | Riverpod | 2.4.9 |
| **Navigation** | GoRouter | 13.1.0 |
| **Database** | Isar | 3.1.0 |
| **Notifications** | flutter_local_notifications | 17.1.2 |
| **Charts** | fl_chart | 0.65.0 |
| **Utilities** | intl, uuid, timezone | Latest |
| **Testing** | flutter_test, mocktail | Built-in |

## Architecture

HabitFlow follows a clean, layered architecture separating concerns:

```
lib/
├── main.dart                    # App entry point with Isar initialization
├── app.dart                     # Main app widget with Riverpod providers
├── routing/
│   └── app_router.dart         # GoRouter navigation configuration
├── domain/                      # Business entities and interfaces
│   └── models/
│       ├── habit.dart          # Habit model with @collection for Isar
│       ├── habit_entry.dart    # Completion record model
│       └── stats_summary.dart   # Computed statistics model
├── data/                        # Data layer with repositories and services
│   ├── providers.dart          # All Riverpod providers
│   ├── repositories/
│   │   ├── habit_repository.dart         # Interface
│   │   └── habit_repository_impl.dart    # Implementation
│   ├── datasources/
│   │   └── local/
│   │       └── habit_local_source.dart   # Isar integration
│   └── services/
│       ├── reminder_service.dart         # Notification scheduling
│       └── streak_service.dart           # Streak calculations
└── ui/                         # Presentation layer
    ├── core/
    │   ├── theme/
    │   │   ├── app_theme.dart  # Material 3 light/dark themes
    │   │   └── app_colors.dart # Color palette
    │   └── widgets/
    │       └── app_empty_state.dart # Reusable empty state widget
    ├── onboarding/             # Onboarding screens
    │   └── views/
    │       └── onboarding_screen.dart
    ├── dashboard/              # Main app screen
    │   └── views/
    │       └── dashboard_screen.dart
    ├── habits/                 # Habit CRUD screens
    │   └── views/
    │       ├── create_habit_screen.dart   # Create and edit
    │       └── habit_detail_screen.dart   # Detail view
    ├── history/                # Calendar view
    │   └── views/
    │       └── history_screen.dart
    ├── stats/                  # Analytics and charts
    │   └── views/
    │       └── stats_screen.dart
    └── settings/               # App preferences
        └── views/
            └── settings_screen.dart

test/
├── widget/                      # Widget tests for UI
│   ├── dashboard/
│   ├── habits/
│   └── stats/
```

### Key Architectural Principles

1. **Layered Separation** - Domain (models), Data (repositories/services), UI (screens/widgets)
2. **Repository Pattern** - Data access abstracted through interfaces
3. **Service Layer** - Complex business logic isolated (StreakService, ReminderService)
4. **Provider-Based State** - Riverpod manages all app state
5. **Feature-First Organization** - Each screen/feature in its own directory
6. **Testable Design** - Easy to mock and test all layers

## Screens & Navigation

| Screen | Purpose | Features |
|--------|---------|----------|
| **Onboarding** | First-time user introduction | 3-page animated flow, skip option |
| **Dashboard** | Main app interface | Today's habits, progress indicator, quick actions |
| **Habit Detail** | Individual habit view | Statistics, timeline, edit/delete options |
| **Create/Edit Habit** | Habit creation & modification | Form validation, time picker, frequency selection |
| **History** | Calendar & completion tracking | Visual calendar, monthly summaries, heatmap |
| **Statistics** | Analytics & trends | Multiple chart types, completion rates, performance metrics |
| **Settings** | App preferences | Theme selection (Light/Dark/System), notifications |

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

3. **Generate Isar boilerplate** (required for database)
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

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/widget/dashboard/dashboard_screen_test.dart
```

### Test Coverage
- **Dashboard Screen** - 5 test cases covering main interactions
- **Stats Screen** - 5 test cases for analytics display
- **Create Habit Screen** - 5 test cases for form validation and interactions
- **Mock Setup** - Proper Riverpod provider overrides and mocktail configuration

## Habit Features

### Creating a Habit

When creating a habit, you can specify:
- **Title** - The name of the habit (required)
- **Description** - Optional details about the habit
- **Category** - Fitness, Health, Study, or Custom
- **Frequency** - Daily or Weekly
- **Schedule** - For weekly habits, select which days
- **Target** - Number of times per day (e.g., 1, 2, 3)
- **Unit** - What you're tracking (times, minutes, kilometers, etc.)
- **Reminders** - Enable and set a specific time for daily reminders

### Tracking Habits

On the Dashboard:
1. **Mark Complete** - Tap the habit to mark it done for today
2. **Undo** - Mistakenly marked? Undo your completion
3. **View Details** - Tap habit name to see full statistics
4. **Edit** - Update habit details at any time
5. **Delete** - Remove habits you no longer want to track

### Viewing Progress

**Habit Detail Screen:**
- Current and longest streaks
- Total completions
- Completion percentage
- Recent activity timeline

**History Screen:**
- Calendar view of all completions
- Monthly completion percentage
- Color-coded activity heatmap

**Stats Screen:**
- Multiple visualization types
- Trend analysis over time
- Performance by category
- Top performing habits

## State Management

The app uses **Riverpod** for all state management:

```dart
// Data providers
final habitsProvider = FutureProvider<List<Habit>>(...);
final habitEntriesProvider = FutureProvider<List<HabitEntry>>(...);

// Computed providers
final statsProvider = FutureProvider<HabitStats>(...);
final monthEntriesProvider = FutureProvider<Map<String, List<HabitEntry>>>(...);

// UI state
final themeProvider = StateProvider<ThemeMode>(...);
```

All providers use async/await patterns with proper error handling and loading states.

## Data Models

### Habit
```dart
@collection
class Habit {
  late String uuid;           // Unique identifier
  late String title;          // Habit name
  String? description;        // Optional details
  late HabitCategory category;
  late FrequencyType frequencyType;
  late int targetCount;       // Target number
  late String unit;           // What's being tracked
  List<int> daysOfWeek = [];  // For weekly habits
  bool reminderEnabled = false;
  DateTime? reminderTime;
  bool isArchived = false;
  late DateTime createdAt;
  late DateTime updatedAt;
}
```

### HabitEntry
```dart
@collection
class HabitEntry {
  late String habitUuid;      // Reference to habit
  late DateTime date;         // When it was completed
  late int value;             // Completion value
  bool completed = false;     // Is it done?
}
```

## Theme System

HabitFlow supports three theme modes:

- **Light Mode** - Clean, bright Material 3 design
- **Dark Mode** - Easy on the eyes for evening use
- **System** - Follows device theme preference

Switch themes anytime in Settings without restarting the app.

## Notifications

### How Reminders Work

1. Create or edit a habit and enable reminders
2. Select your preferred reminder time
3. The app schedules a local notification for that time
4. Notification appears even if the app is closed
5. Tap the notification to open the app

### Permission Handling

The app requests notification permissions when first needed. You can manage permissions in:
- **iOS**: Settings > Notifications > HabitFlow
- **Android**: Settings > Apps > HabitFlow > Notifications

## Performance

HabitFlow is optimized for fast performance:

- **Lazy Loading** - Data loaded on-demand with proper caching
- **Efficient Rebuilds** - Riverpod ensures only affected widgets rebuild
- **Database Optimization** - Isar provides fast local queries
- **No Network Calls** - Completely offline-first, no cloud dependencies
- **Responsive UI** - Async operations with loading indicators

## Code Quality

- **Lint Rules** - flutter_lints configuration for consistent code
- **Clean Architecture** - Clear separation of concerns
- **Error Handling** - Try-catch blocks and error UI states
- **Widget Tests** - Comprehensive test coverage for main flows
- **Type Safety** - Full null-safety throughout

## Project Structure Highlights

### Domain Layer (`lib/domain/`)
- Pure data models with no dependencies
- Business logic rules and calculations
- Enum definitions (HabitCategory, FrequencyType)

### Data Layer (`lib/data/`)
- Repository interfaces and implementations
- Data source abstractions
- Business logic services
- Riverpod provider definitions

### UI Layer (`lib/ui/`)
- Screen widgets (StatefulWidget, ConsumerStatefulWidget)
- Custom reusable widgets
- Theme and styling
- Material 3 design system

## Building for Production

### Android
```bash
flutter build apk
# or for app bundle:
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## Troubleshooting

### Database Issues
```bash
# Regenerate Isar code if you modify models
flutter pub run build_runner build --delete-conflicting-outputs
```

### Notifications Not Working
- Check that permissions are granted in app settings
- Verify notification settings in device settings
- Check that reminder time is set correctly

### Theme Not Updating
- Restart the app if theme toggle doesn't work
- Clear app cache: `flutter clean && flutter pub get`

### Build Errors
```bash
# Clean everything and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build
flutter run
```

## Code Examples

### Creating a Habit Programmatically
```dart
final habit = Habit()
  ..uuid = const Uuid().v4()
  ..title = 'Morning Jog'
  ..category = HabitCategory.fitness
  ..frequencyType = FrequencyType.daily
  ..targetCount = 1
  ..unit = 'times'
  ..reminderEnabled = true
  ..reminderTime = DateTime.now().copyWith(hour: 6, minute: 0)
  ..createdAt = DateTime.now()
  ..updatedAt = DateTime.now();

await repository.saveHabit(habit);
```

### Listening to Habit Changes
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final habitsAsync = ref.watch(habitsProvider);
  
  return habitsAsync.when(
    data: (habits) => ListView(
      children: habits.map((habit) => HabitCard(habit)).toList(),
    ),
    loading: () => const LoadingIndicator(),
    error: (err, st) => ErrorWidget(error: err),
  );
}
```

### Computing Statistics
```dart
final stats = await streakService.calculateStats(habitUuid, entries);
print('Streak: ${stats.currentStreak} days');
print('Completion: ${stats.completionRate}%');
```

## Contributing

This is a portfolio project, but improvements are welcome. Please:
1. Follow the existing architecture patterns
2. Write tests for new features
3. Maintain Material 3 design consistency
4. Keep the codebase clean and documented

## License

This project is provided as-is for portfolio purposes.

## Support & Feedback

For issues, questions, or feedback about the implementation, please refer to the repository structure and code comments.

---

**Last Updated:** April 2026  
**Flutter Version:** 3.x  
**Status:** Production-Ready MVP ✅
