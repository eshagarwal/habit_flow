import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/providers.dart';
import '../../../domain/models/habit.dart';
import '../../../domain/models/habit_entry.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitUuid;

  const HabitDetailScreen({super.key, required this.habitUuid});

  String _getEnumName(dynamic enumValue) {
    return enumValue.toString().split('.').last.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      data: (habits) {
        final habit = habits.where((h) => h.uuid == habitUuid).firstOrNull;
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Habit Details')),
            body: const Center(child: Text('Habit not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Habit Details'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.go('/create-habit?uuid=${habit.uuid}'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteDialog(context, habit, ref),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Habit Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      if (habit.description != null)
                        Text(
                          habit.description!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildBadge(context, _getEnumName(habit.category)),
                          const SizedBox(width: 8),
                          _buildBadge(
                              context, '${habit.targetCount} ${habit.unit}'),
                          const SizedBox(width: 8),
                          _buildBadge(
                              context, _getEnumName(habit.frequencyType)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer(builder: (context, ref, _) {
                    final entriesAsync =
                        ref.watch(entriesByHabitProvider(habitUuid));
                    return entriesAsync.when(
                      data: (entries) {
                        final streakService = ref.read(streakServiceProvider);
                        final stats =
                            streakService.calculateStats(habit, entries);
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    icon: Icons.local_fire_department,
                                    label: 'Current Streak',
                                    value: '${stats.currentStreak}',
                                    unit: 'days',
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    icon: Icons.star,
                                    label: 'Best Streak',
                                    value: '${stats.longestStreak}',
                                    unit: 'days',
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    icon: Icons.check_circle,
                                    label: 'Total Completed',
                                    value:
                                        '${entries.where((e) => e.completed).length}',
                                    unit: 'times',
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    icon: Icons.percent,
                                    label: 'Completion Rate',
                                    value:
                                        '${(stats.completionRate * 100).toStringAsFixed(0)}%',
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      loading: () => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  icon: Icons.local_fire_department,
                                  label: 'Current Streak',
                                  value: '...',
                                  unit: 'days',
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  icon: Icons.star,
                                  label: 'Best Streak',
                                  value: '...',
                                  unit: 'days',
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  icon: Icons.check_circle,
                                  label: 'Total Completed',
                                  value: '...',
                                  unit: 'times',
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  icon: Icons.percent,
                                  label: 'Completion Rate',
                                  value: '...',
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      error: (_, __) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  icon: Icons.local_fire_department,
                                  label: 'Current Streak',
                                  value: '--',
                                  unit: 'days',
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  icon: Icons.star,
                                  label: 'Best Streak',
                                  value: '--',
                                  unit: 'days',
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  icon: Icons.check_circle,
                                  label: 'Total Completed',
                                  value: '--',
                                  unit: 'times',
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  icon: Icons.percent,
                                  label: 'Completion Rate',
                                  value: '--',
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                // Recent Activity
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Consumer(builder: (context, ref, _) {
                        final entriesAsync =
                            ref.watch(entriesByHabitProvider(habitUuid));
                        return entriesAsync.when(
                          data: (entries) {
                            final recent = entries.toList()
                              ..sort((a, b) => b.date.compareTo(a.date));
                            if (recent.isEmpty) {
                              return const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('No activity yet'),
                                ),
                              );
                            }
                            return Card(
                              child: ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: recent.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final entry = recent[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    leading: Icon(
                                      entry.completed
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: entry.completed
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    title: Text(DateFormat('MMM d, yyyy')
                                        .format(entry.date)),
                                    trailing: Text(
                                      entry.completed ? 'Completed' : 'Missed',
                                      style: TextStyle(
                                        color: entry.completed
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, __) =>
                              Center(child: Text('Error: $err')),
                        );
                      }),
                    ],
                  ),
                ),

                // Information Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Information',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: [
                            _buildInfoTile(
                              context,
                              'Created',
                              DateFormat('MMM d, yyyy').format(habit.createdAt),
                            ),
                            const Divider(height: 1),
                            _buildInfoTile(
                              context,
                              'Last Updated',
                              DateFormat('MMM d, yyyy').format(habit.updatedAt),
                            ),
                            const Divider(height: 1),
                            _buildInfoTile(
                              context,
                              'Reminders',
                              habit.reminderEnabled ? 'Enabled' : 'Disabled',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Habit Details')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Habit Details')),
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? unit,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Habit habit, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text(
          'Are you sure you want to delete "${habit.title}" and all its history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repository = ref.read(habitRepositoryProvider);
              await repository.deleteHabit(habit.uuid);
              ref.invalidate(habitsProvider);
              if (context.mounted) {
                Navigator.pop(context);
                context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
