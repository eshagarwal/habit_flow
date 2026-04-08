import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers.dart';
import '../../../domain/models/habit.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitUuid;

  const HabitDetailScreen({super.key, required this.habitUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      data: (habits) {
        final habit = habits.where((h) => h.uuid == habitUuid).firstOrNull;
        if (habit == null) return const Scaffold(body: Center(child: Text('Habit not found')));

        return Scaffold(
          appBar: AppBar(
            title: Text(habit.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Habit'),
                      content: const Text('Are you sure you want to delete this habit and all its history?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE')),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final repository = ref.read(habitRepositoryProvider);
                    await repository.deleteHabit(habit.uuid);
                    ref.invalidate(habitsProvider);
                    if (context.mounted) context.pop();
                  }
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection('Category', habit.category.name.toUpperCase()),
                _buildInfoSection('Frequency', habit.frequencyType.name.toUpperCase()),
                _buildInfoSection('Target', '${habit.targetCount} ${habit.unit}'),
                if (habit.description != null) _buildInfoSection('Description', habit.description!),
                const Spacer(),
                const Text(
                  'Streak Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStreakBox('Current', '5'),
                    _buildStreakBox('Best', '12'),
                    _buildStreakBox('Total', '45'),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStreakBox(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
