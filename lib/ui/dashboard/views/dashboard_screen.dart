import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/providers.dart';
import '../../../domain/models/habit_entry.dart';
import '../../core/widgets/app_empty_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsyncValue = ref.watch(habitsProvider);
    final todayEntriesAsyncValue = ref.watch(todayEntriesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Professional App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Today\'s Habits',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  color: Colors.white,
                  onPressed: () => context.go('/settings'),
                ),
              )
            ],
          ),
          // Body content
          SliverToBoxAdapter(
            child: habitsAsyncValue.when(
              data: (habits) {
                if (habits.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: AppEmptyState(
                      title: 'No habits yet',
                      subtitle:
                          'Create your first habit to get started on your journey to building better routines.',
                      icon: Icons.list_alt,
                      actionLabel: 'Create Habit',
                      onAction: () => context.go('/create-habit'),
                    ),
                  );
                }

                return todayEntriesAsyncValue.when(
                  data: (entries) {
                    // Sort habits: incomplete first, completed last
                    final sortedHabits = List<dynamic>.from(habits);
                    sortedHabits.sort((a, b) {
                      final aCompleted = entries
                              .where((e) => e.habitUuid == a.uuid)
                              .firstOrNull
                              ?.completed ??
                          false;
                      final bCompleted = entries
                              .where((e) => e.habitUuid == b.uuid)
                              .firstOrNull
                              ?.completed ??
                          false;

                      // Incomplete habits first (false < true)
                      return aCompleted ? 1 : (bCompleted ? -1 : 0);
                    });

                    final completedCount =
                        entries.where((e) => e.completed).length;
                    final progressPercent =
                        habits.isEmpty ? 0.0 : completedCount / habits.length;

                    return Column(
                      children: [
                        // Progress summary card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // Progress circle
                                  SizedBox(
                                    height: 140,
                                    width: 140,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: progressPercent,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: AlwaysStoppedAnimation(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$completedCount/${habits.length}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Completed',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    '${(progressPercent * 100).toStringAsFixed(0)}% Complete',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progressPercent,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Habits list title
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your Habits',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                '${habits.length} habit${habits.length == 1 ? '' : 's'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Habits list
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shrinkWrap: true,
                          itemCount: sortedHabits.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final habit = sortedHabits[index];
                            final entry = entries
                                .where((e) => e.habitUuid == habit.uuid)
                                .firstOrNull;
                            final isCompleted = entry?.completed ?? false;

                            return _HabitCard(
                              habit: habit,
                              isCompleted: isCompleted,
                              onTap: () => context.go('/habit/${habit.uuid}'),
                              onToggle: () async {
                                final repository =
                                    ref.read(habitRepositoryProvider);
                                if (isCompleted && entry != null) {
                                  await repository
                                      .deleteEntry(entry.id.toString());
                                } else {
                                  final newEntry = HabitEntry()
                                    ..habitUuid = habit.uuid
                                    ..date = DateTime.now()
                                    ..value = 1
                                    ..completed = true
                                    ..completedAt = DateTime.now();
                                  await repository.saveEntry(newEntry);
                                }
                                ref.invalidate(todayEntriesProvider);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Error loading today\'s habits',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Error loading habits',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/create-habit'),
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) context.go('/history');
          if (index == 2) context.go('/stats');
          if (index == 3) context.go('/settings');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final dynamic habit;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _HabitCard({
    required this.habit,
    required this.isCompleted,
    required this.onTap,
    required this.onToggle,
  });

  String _getCategoryName(dynamic category) {
    return category.toString().split('.').last.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.fitness_center,
                  color: isCompleted
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.grey[600] : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getCategoryName(habit.category)} • ${habit.targetCount} ${habit.unit}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Toggle button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isCompleted ? Colors.green : Colors.grey,
                      size: 24,
                    ),
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
