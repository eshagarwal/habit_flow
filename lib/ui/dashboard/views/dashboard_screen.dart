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
      appBar: AppBar(
        title: const Text('HabitFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          )
        ],
      ),
      body: habitsAsyncValue.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const AppEmptyState(
              title: 'No habits yet',
              subtitle: 'Tap the + button to create your first habit.',
              icon: Icons.list_alt,
            );
          }

          return todayEntriesAsyncValue.when(
            data: (entries) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: habits.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final entry = entries.where((e) => e.habitUuid == habit.uuid).firstOrNull;
                  final isCompleted = entry?.completed ?? false;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: ListTile(
                      onTap: () => context.go('/habit/${habit.uuid}'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isCompleted 
                            ? Colors.green.withOpacity(0.1) 
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.fitness_center, 
                          color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        habit.title,
                        style: TextStyle(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('${habit.category.name} • ${habit.targetCount} ${habit.unit}'),
                      trailing: IconButton(
                        icon: Icon(
                          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isCompleted ? Colors.green : Colors.grey,
                          size: 32,
                        ),
                        onPressed: () async {
                          final repository = ref.read(habitRepositoryProvider);
                          if (isCompleted && entry != null) {
                            await repository.deleteEntry(entry.id.toString());
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
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create-habit'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
        onTap: (index) {
          if (index == 1) context.go('/history');
          if (index == 2) context.go('/stats');
        },
      ),
    );
  }
}
