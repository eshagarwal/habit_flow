import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/providers.dart';
import '../../../domain/models/habit_entry.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, we'd have a provider that fetches entries grouped by date
    // For MVP, we'll fetch all entries and group them here or show a list
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completion History'),
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(child: Text('No history available yet.'));
          }

          // Mocking grouped data for UI demonstration
          final dates = List.generate(7, (i) => DateTime.now().subtract(Duration(days: i)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              return _HistoryDateGroup(date: date, habits: habits);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
        onTap: (index) {
          if (index == 0) context.go('/');
          if (index == 2) context.go('/stats');
        },
      ),
    );
  }
}

class _HistoryDateGroup extends StatelessWidget {
  final DateTime date;
  final List<dynamic> habits;

  const _HistoryDateGroup({required this.date, required this.habits});

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final dateStr = isToday ? 'Today' : DateFormat('EEEE, MMM d').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            dateStr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
          ),
        ),
        ...habits.take(2).map((h) => _HistoryItem(title: h.title, completed: true)).toList(),
        const Divider(),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  final bool completed;

  const _HistoryItem({required this.title, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.cancel,
            color: completed ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
