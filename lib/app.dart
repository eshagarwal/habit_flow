import 'package:flutter/material.dart';
import 'routing/app_router.dart';
import 'ui/core/theme/app_theme.dart';

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HabitFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Or listen to a provider
      routerConfig: appRouter,
    );
  }
}
