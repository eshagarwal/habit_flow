import 'package:go_router/go_router.dart';
import '../ui/onboarding/views/onboarding_screen.dart';
import '../ui/dashboard/views/dashboard_screen.dart';
import '../ui/habits/views/create_habit_screen.dart';
import '../ui/habits/views/habit_detail_screen.dart';
import '../ui/history/views/history_screen.dart';
import '../ui/stats/views/stats_screen.dart';
import '../ui/settings/views/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
      routes: [
        GoRoute(
          path: 'create-habit',
          builder: (context, state) => const CreateHabitScreen(),
        ),
        GoRoute(
          path: 'habit/:uuid',
          builder: (context, state) => HabitDetailScreen(
            habitUuid: state.pathParameters['uuid']!,
          ),
        ),
        GoRoute(
          path: 'history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: 'stats',
          builder: (context, state) => const StatsScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
