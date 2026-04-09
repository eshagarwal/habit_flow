import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _currentMonth;
  int _selectedDayIndex = 0; // 0 = Today, 1 = Yesterday, etc.

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final monthEntriesAsync = ref.watch(monthEntriesProvider(_currentMonth));
    final selectedDate =
        DateTime.now().subtract(Duration(days: _selectedDayIndex));

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        elevation: 0,
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history available yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start creating and completing habits to see your history',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return monthEntriesAsync.when(
            data: (monthData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Month selector and calendar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month/Year header with navigation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(_currentMonth),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () {
                                      setState(() {
                                        _currentMonth = DateTime(
                                          _currentMonth.year,
                                          _currentMonth.month - 1,
                                        );
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () {
                                      setState(() {
                                        _currentMonth = DateTime(
                                          _currentMonth.year,
                                          _currentMonth.month + 1,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Calendar grid
                          _buildCalendarGrid(context, monthData),
                        ],
                      ),
                    ),

                    // Selected day details
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Completion Details',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          _buildDayDetailsCard(
                              context, selectedDate, monthData),
                        ],
                      ),
                    ),

                    // 30-day summary
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Summary',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          _buildMonthlySummary(context, monthData),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error loading history: $error',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading history: $error',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) context.go('/');
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

  Widget _buildCalendarGrid(
      BuildContext context, MonthlyEntriesData monthData) {
    final weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = _currentMonth.month == 12
        ? DateTime(_currentMonth.year + 1, 1, 1)
            .subtract(const Duration(days: 1))
        : DateTime(_currentMonth.year, _currentMonth.month + 1, 1)
            .subtract(const Duration(days: 1));
    final daysInMonth = lastDay.day;
    final startingWeekday = firstDay.weekday;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Weekday headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdayLabels.map((day) {
                return SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // Calendar days
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: (startingWeekday - 1) + daysInMonth,
              itemBuilder: (context, index) {
                // Empty cells before month starts
                if (index < startingWeekday - 1) {
                  return const SizedBox.shrink();
                }

                final day = index - (startingWeekday - 1) + 1;
                final date =
                    DateTime(_currentMonth.year, _currentMonth.month, day);
                final isToday = DateUtils.isSameDay(date, DateTime.now());
                final isSelected = _selectedDayIndex == 0 && isToday;

                // Determine completion status
                bool isCompleted = day % 3 == 0; // Simulate some completed days

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex =
                          DateTime.now().difference(date).inDays;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : isCompleted
                              ? Colors.green.withOpacity(0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (isCompleted)
                            Icon(
                              Icons.check,
                              size: 12,
                              color: isSelected ? Colors.white : Colors.green,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayDetailsCard(
    BuildContext context,
    DateTime selectedDate,
    MonthlyEntriesData monthData,
  ) {
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);

    // Get entries for the selected date
    final dayEntries = monthData.entriesByDay[selectedDate.day] ?? [];
    final completedCount = dayEntries.where((e) => e.completed).length;
    final totalCount = dayEntries.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$completedCount',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                Column(
                  children: [
                    Text(
                      '${totalCount - completedCount}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Missed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                Column(
                  children: [
                    Text(
                      totalCount > 0
                          ? '${((completedCount / totalCount) * 100).toStringAsFixed(0)}%'
                          : '0%',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Habit list for this day
            Text(
              'Habits',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: dayEntries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = dayEntries[index];
                return Row(
                  children: [
                    Icon(
                      entry.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: entry.completed ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Entry ${index + 1}',
                        style: TextStyle(
                          decoration: entry.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: entry.completed ? Colors.grey[600] : null,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(
    BuildContext context,
    MonthlyEntriesData monthData,
  ) {
    final totalEntries = monthData.totalCount;
    final completedEntries = monthData.completedCount;
    final activeDays =
        monthData.entriesByDay.values.where((e) => e.isNotEmpty).length;
    final completionRate = totalEntries > 0
        ? ((completedEntries / totalEntries) * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  icon: Icons.calendar_month,
                  label: 'Active Days',
                  value: '$activeDays',
                  color: Colors.blue,
                ),
                _buildSummaryItem(
                  context,
                  icon: Icons.check_circle,
                  label: 'Completion',
                  value: '$completionRate%',
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  context,
                  icon: Icons.trending_up,
                  label: 'Avg Score',
                  value: '85%',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Simple month heatmap
            Text(
              'Daily Activity',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(30, (index) {
                final isActive = (index + 1) % 3 == 0;
                return Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withOpacity(0.8)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'No activity',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Active',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
