# Flutter Habit & Fitness Tracker Project Brief

## Project overview

This project is a portfolio-grade Flutter application designed to demonstrate production-oriented mobile engineering skills through a habit and fitness tracker. The app should focus on practical daily use cases such as habit creation, recurring schedules, reminder notifications, streak tracking, progress history, and basic analytics, because these features showcase state management, data modeling, local persistence, testing, and UI polish in a way that aligns well with modern Flutter expectations.[cite:19][cite:24][cite:31]

The app should be built as a small but complete product rather than a tutorial-style demo. The goal is to present strong engineering fundamentals: clean architecture, clear separation of concerns, maintainable code, useful tests, and a thoughtful user experience.[cite:19][cite:20][cite:31]

## Portfolio goal

The purpose of this project is to give recruiters evidence that the developer can build, structure, test, and polish a real Flutter application. Flutter’s architecture guidance recommends separating UI concerns from repositories and services, which makes this project a strong vehicle for showing maintainability and engineering maturity.[cite:19]

This app should signal the following:

- Ability to build a structured Flutter app with scalable architecture.[cite:19]
- Ability to work with local notifications and platform-relevant features.[cite:24]
- Ability to model business logic such as streaks and completion rates in a testable way.[cite:31][cite:36]
- Ability to write unit, widget, and integration tests for key flows.[cite:20][cite:31][cite:33]
- Ability to ship a clean, usable interface rather than just assemble packages.[cite:19][cite:20]

## Product vision

The product is a habit and fitness tracker for users who want to build consistent routines such as walking daily, working out several times per week, drinking enough water, meditating, or reading. Users should be able to create habits, define schedules, receive reminders, mark habits complete, review history, and see stats such as current streak, longest streak, and consistency rate.[cite:24][cite:31]

The app should feel lightweight, fast, and focused. It should support offline-first use and avoid unnecessary complexity in version one.[cite:19][cite:20]

## Core user stories

### User stories for MVP

- As a user, I can create a habit with a title, category, target, and schedule.
- As a user, I can edit, archive, or delete a habit.
- As a user, I can view habits due today.
- As a user, I can mark a habit as completed for a given day.
- As a user, I can undo a completion if I made a mistake.
- As a user, I can receive reminder notifications for selected habits.[cite:24]
- As a user, I can see my current streak and longest streak.
- As a user, I can review my recent history and completion trends.
- As a user, I can use the app without a network connection.

### User stories for V2

- As a user, I can group habits by category such as fitness, health, study, or custom.
- As a user, I can view weekly and monthly charts.
- As a user, I can pause a habit without deleting it.
- As a user, I can export my progress data.
- As a user, I can sync data to the cloud.
- As a user, I can connect device or health data in a future release.

## Feature set

## 1. Habit management

Users should be able to create, edit, archive, unarchive, and delete habits. Each habit should store enough information to support tracking, scheduling, and future analytics without becoming over-modeled too early.[cite:19][cite:29]

Suggested habit fields:

- `id`
- `title`
- `description` (optional)
- `category`
- `frequencyType` (daily, weekly)
- `targetCount`
- `unit` (times, minutes, liters, kilometers, reps)
- `daysOfWeek`
- `reminderEnabled`
- `reminderTime`
- `color`
- `icon`
- `createdAt`
- `updatedAt`
- `isArchived`

Validation rules:

- Title is required.
- Target count must be positive.
- Weekly habits should require at least one selected day.
- Reminder time should only be stored when reminders are enabled.

## 2. Daily dashboard

The dashboard should prioritize habits due today and make completion extremely quick. This screen is the app’s main daily surface, so it should be optimized for speed, clarity, and low friction.[cite:19]

Suggested dashboard sections:

- Greeting and today’s date.
- Progress summary for today.
- Habits due today.
- Completed today.
- Quick actions: add habit, undo completion, open history.

Possible habit card actions:

- Mark complete.
- Undo completion.
- Open detail page.
- Snooze reminder in future versions.

## 3. Scheduling

The app should support recurring schedules that map cleanly to habit logic. The initial version should handle daily and weekly recurring habits well before adding more advanced recurrence rules.[cite:31][cite:36]

MVP scheduling options:

- Daily habit.
- Weekly habit on selected weekdays.
- Numeric target, for example 1 workout, 2 liters, or 30 minutes.

V2 scheduling options:

- Multiple times per day.
- Specific dates.
- Pause/resume windows.
- Monthly recurrence.

## 4. Reminders and notifications

Reminder support is an important feature because it makes the app feel product-complete and demonstrates practical Flutter integration work. The `flutter_local_notifications` package supports cross-platform local notifications and is a strong fit for this feature.[cite:24][cite:21]

Reminder requirements:

- Enable or disable reminders per habit.
- Pick reminder time.
- Update scheduled reminder when habit changes.
- Cancel reminder when habit is deleted or reminders are disabled.
- Handle permission flow cleanly.
- Provide settings-level notification master switch.

Nice-to-have reminder features:

- Quiet hours.
- Weekend skip.
- Multiple reminders per habit.
- Reminder preview text customization.

## 5. Streaks and business logic

Streak logic is one of the best engineering showcase features in this project because it involves non-trivial business rules and is ideal for unit testing. Testing guidance for Flutter emphasizes keeping logic testable and separated from UI-heavy code where possible.[cite:20][cite:31][cite:36]

Metrics to support:

- Current streak.
- Longest streak.
- Total completions.
- Completion rate.
- Missed days.
- Weekly consistency.

Logic considerations:

- Daily habits and weekly habits should be handled differently.
- Undo should recalculate streaks correctly.
- Edited schedules should not silently corrupt historical stats.
- Paused habits in later versions should avoid unfairly breaking streaks.

## 6. History and analytics

The app should include a history or calendar-like screen that helps users review completed and missed habits. Stats should be derived from entry data instead of manually duplicated where possible, because derived state reduces bugs and inconsistency.[cite:19][cite:31]

MVP analytics:

- Current streak.
- Longest streak.
- 7-day completion trend.
- Monthly consistency percentage.
- Habit-by-habit completion summary.

V2 analytics:

- Heatmap calendar.
- Best performing category.
- Most skipped habit.
- Weekday consistency trends.

## 7. Settings

The settings screen should stay small but useful. It is also a good place to show clean Flutter form and toggle handling.

Suggested settings:

- Theme mode: system, light, dark.
- Notification master toggle.
- Reminder testing action.
- About page.
- Demo data reset.
- Export data in a future version.

## Non-functional requirements

### Architecture

The project should follow a layered architecture inspired by Flutter’s app architecture guidance, using a UI layer for views and view models, and a data layer for repositories and services. This separation improves maintainability, testability, and clarity.[cite:19]

Recommended principles:

- Feature-first organization for screens and UI code.[cite:29][cite:34]
- Shared reusable services in a data layer.[cite:19]
- Keep widgets mostly presentation-focused.
- Put business logic in services or view models, not directly in screens.[cite:19][cite:32]
- Use repository interfaces to isolate storage implementation.[cite:19]

### Performance

The app should feel fast on normal student-level Android devices and should not rely on network calls for basic use. Local-first persistence is ideal for a habit tracker because core functionality should remain available offline.[cite:19][cite:20]

### Testing

The project should include three levels of testing: unit tests for logic, widget tests for screens and interactions, and a smaller number of integration tests for end-to-end flows. Flutter testing guidance consistently treats this as a strong quality baseline.[cite:20][cite:31][cite:33][cite:36]

Recommended test distribution:

- Unit tests for business rules and transformations.
- Widget tests for form validation, screen states, and user interactions.
- Integration tests for the main user journey only.

### UX quality

The app should include:

- Good empty states.
- Inline validation.
- Loading states where needed.
- Undo flows for destructive actions.
- Dark mode support.
- Accessible tap targets and readable type.

## Recommended tech stack

The stack below is optimized for a portfolio app that is realistic, maintainable, and not overcomplicated.

| Area | Recommendation | Notes |
|---|---|---|
| Framework | Flutter | Core framework for mobile UI. |
| Language | Dart | Native language for Flutter. |
| State management | Riverpod or Provider | Provider aligns closely with common Flutter architecture examples; Riverpod is also strong for scalability.[cite:19] |
| Routing | go_router | Clean declarative navigation. |
| Local database | Isar or Hive | Good offline-first fit for local persistence. |
| Notifications | flutter_local_notifications | Strong package for local scheduled notifications.[cite:24] |
| Charts | fl_chart | Good for simple trend visualizations. |
| Dependency injection | Riverpod providers or get_it | Choose one simple pattern, not many. |
| Testing | flutter_test, integration_test, mocktail | Solid base for unit, widget, and integration coverage.[cite:31][cite:33] |
| Linting | flutter_lints or very_good_analysis | Improves code consistency. |

### Recommended package direction

A practical and balanced stack would be:

- `flutter_riverpod`
- `go_router`
- `isar` or `hive`
- `flutter_local_notifications`
- `fl_chart`
- `intl`
- `uuid`
- `mocktail`
- `integration_test`

## Folder structure

```text
lib/
  main.dart
  app.dart

  routing/
    app_router.dart

  domain/
    models/
      habit.dart
      habit_entry.dart
      reminder_config.dart
      stats_summary.dart
    enums/
      frequency_type.dart
      habit_category.dart

  data/
    repositories/
      habit_repository.dart
      habit_repository_impl.dart
      stats_repository.dart
    services/
      streak_service.dart
      reminder_service.dart
      local_storage_service.dart
      date_service.dart
    datasources/
      local/
        habit_local_source.dart

  ui/
    core/
      theme/
        app_theme.dart
        app_colors.dart
      widgets/
        app_button.dart
        app_text_field.dart
        app_empty_state.dart
        loading_indicator.dart

    dashboard/
      views/
        dashboard_screen.dart
      view_models/
        dashboard_view_model.dart
      widgets/
        today_habit_list.dart
        habit_progress_card.dart

    habits/
      views/
        create_habit_screen.dart
        edit_habit_screen.dart
        habit_detail_screen.dart
      view_models/
        habit_form_view_model.dart
        habit_detail_view_model.dart
      widgets/
        frequency_picker.dart
        reminder_picker.dart
        day_selector.dart

    history/
      views/
        history_screen.dart
      view_models/
        history_view_model.dart
      widgets/
        completion_calendar.dart

    stats/
      views/
        stats_screen.dart
      view_models/
        stats_view_model.dart
      widgets/
        streak_summary_card.dart
        weekly_chart.dart

    settings/
      views/
        settings_screen.dart
      view_models/
        settings_view_model.dart

test/
  unit/
    services/
      streak_service_test.dart
      stats_repository_test.dart
  widget/
    habits/
      create_habit_screen_test.dart
    dashboard/
      dashboard_screen_test.dart
  integration_test/
    app_flow_test.dart
```

This structure reflects a layered approach where features own their UI while repositories and services remain reusable across the app.[cite:19][cite:29]

## Domain model design

### Habit

Represents the core trackable entity.

Suggested fields:

- `id: String`
- `title: String`
- `description: String?`
- `category: HabitCategory`
- `frequencyType: FrequencyType`
- `targetCount: int`
- `unit: String`
- `daysOfWeek: List<int>`
- `reminderEnabled: bool`
- `reminderTime: DateTime?`
- `isArchived: bool`
- `createdAt: DateTime`
- `updatedAt: DateTime`

### HabitEntry

Represents a completion record.

Suggested fields:

- `id: String`
- `habitId: String`
- `date: DateTime`
- `value: int`
- `completed: bool`
- `completedAt: DateTime?`

### ReminderConfig

Represents local reminder behavior.

Suggested fields:

- `habitId: String`
- `enabled: bool`
- `time: DateTime?`
- `daysOfWeek: List<int>`

### StatsSummary

Represents derived metrics for the dashboard and stats screens.

Suggested fields:

- `currentStreak: int`
- `longestStreak: int`
- `completionRate: double`
- `completedThisWeek: int`
- `completedThisMonth: int`

## Screen-by-screen breakdown

### 1. Onboarding or welcome

Purpose:

- Introduce the app briefly.
- Let user continue immediately.
- Optionally preload demo habits.

### 2. Dashboard

Purpose:

- Show today’s tasks.
- Surface quick progress.
- Make completion easy.

Key widgets:

- Header with date.
- Today progress ring or summary card.
- Habit list.
- Add habit FAB.
- Empty state when there are no habits.

### 3. Create/edit habit

Purpose:

- Capture all required configuration with low friction.

Fields:

- Title.
- Description optional.
- Category.
- Frequency type.
- Days of week.
- Target count.
- Unit.
- Reminder toggle and time.
- Save button.

### 4. Habit detail

Purpose:

- Show detailed stats for one habit.
- Allow edit, archive, or delete.

Key content:

- Current streak.
- Longest streak.
- Last 7 to 30 days of activity.
- Schedule details.

### 5. History

Purpose:

- Review past completions.
- Support simple calendar or list view.

### 6. Stats

Purpose:

- Show overall consistency and trends.

Key content:

- Weekly trend chart.
- Longest streak card.
- Completion rate card.
- Top habits summary.

### 7. Settings

Purpose:

- App preferences and maintenance actions.

## State management strategy

A good state management strategy for this app is to keep data retrieval and mutations in repositories, business rules in services, and screen-facing state in view models or providers. This keeps widgets simpler and matches common Flutter architectural guidance for scalable apps.[cite:19][cite:32]

Example responsibilities:

- Repository: load and save habits and entries.
- Reminder service: schedule or cancel notifications.[cite:24]
- Streak service: compute streaks and completion summaries.
- View model: expose loading, error, and success state to the screen.
- Screen/widget: render UI and handle user interaction.

## Data persistence plan

The app should be offline-first. Local persistence is enough for version one and makes the app more realistic for daily use.

Storage recommendation:

- Primary choice: Isar, if typed local collections and performance are important.
- Alternative: Hive, if faster setup is preferred.

Persistence requirements:

- Save habits locally.
- Save completions locally.
- Restore app state after restart.
- Support updates and deletions safely.
- Keep derived stats calculated from stored records rather than stored redundantly.

## Notification implementation plan

Use `flutter_local_notifications` for local reminder scheduling. The implementation should abstract notification behavior behind a reminder service so the rest of the app is not tightly coupled to the package directly.[cite:24]

Reminder service responsibilities:

- Request permissions.
- Schedule habit reminder.
- Reschedule after edits.
- Cancel on delete.
- Handle app-level notification settings.

## Testing strategy

Testing should be part of the planned deliverable, not an afterthought. Guidance on Flutter testing consistently recommends combining unit, widget, and integration tests for balanced confidence and maintainability.[cite:20][cite:31][cite:33][cite:36]

### Unit tests

Focus on:

- Streak calculations.
- Completion rate calculations.
- Schedule resolution logic.
- Stats aggregation.
- Validation helpers.

### Widget tests

Focus on:

- Create habit form validation.
- Dashboard rendering with habits and empty state.
- Completion toggle behavior.
- Settings switches.

### Integration tests

Focus on the critical happy path:

1. Open app.
2. Create a habit.
3. Mark it complete.
4. Verify the dashboard updates.
5. Verify streak/stat display changes.

## Suggested roadmap

### Phase 1: Foundation

- Initialize Flutter project.
- Set up theme, routing, linting, and base architecture.
- Add placeholder screens.

### Phase 2: Habit CRUD

- Implement models.
- Add local persistence.
- Build create, edit, delete, archive flows.

### Phase 3: Daily tracking

- Build today dashboard.
- Add completion and undo.
- Show daily progress.

### Phase 4: Streak logic

- Implement streak service.
- Add habit detail metrics.
- Add unit tests.

### Phase 5: Notifications

- Integrate local reminders.[cite:24]
- Add permissions and settings.

### Phase 6: History and stats

- Build charts and summaries.
- Add history screen.

### Phase 7: Testing and polish

- Add widget and integration tests.[cite:31][cite:33]
- Improve UX, loading states, and dark mode.
- Prepare screenshots, demo video, and README.

## GitHub deliverables

A strong portfolio repository should include:

- Clean codebase with meaningful commit history.
- README with screenshots and setup steps.
- Short architecture explanation.
- Testing section.
- Demo GIF or short screen recording.
- Clear list of future improvements.

Suggested README sections:

- Project title.
- Summary.
- Features.
- Tech stack.
- Architecture.
- Screenshots.
- How to run.
- How to test.
- Future improvements.

## Definition of done

The project is ready for portfolio use when the following are true:

- Users can create, edit, complete, archive, and delete habits.
- Reminder scheduling works locally.[cite:24]
- Dashboard, detail, history, stats, and settings screens are functional.
- Streak and completion logic are tested.[cite:20][cite:31]
- There is at least one integration test for the main app flow.[cite:33]
- The app has polished empty states, validation, and dark mode.
- The repository includes a clear README and visuals.

## Stretch goals

These are useful, but should only be attempted after the MVP is stable:

- Cloud sync.
- Authentication.
- Health or pedometer integration.
- Home screen widgets.
- CSV or PDF export.
- Social accountability features.
- AI-generated habit suggestions.

