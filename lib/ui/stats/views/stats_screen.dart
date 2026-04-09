import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers.dart';
import '../../../domain/models/habit.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final statsAsync = ref.watch(statsProvider);
    final weeklyAsync = ref.watch(weeklyActivityProvider);
    final trendAsync = ref.watch(monthlyTrendProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
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
                    Icons.bar_chart,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No statistics available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create and complete habits to see your statistics',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return statsAsync.when(
            data: (stats) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Overview Cards
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Top row cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: 'Active Habits',
                                  value: stats.activeHabits.toString(),
                                  icon: Icons.fitness_center,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: 'Overall Rate',
                                  value:
                                      '${stats.overallCompletionRate.toStringAsFixed(0)}%',
                                  icon: Icons.percent,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Bottom row cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: 'Streak',
                                  value: stats.currentStreak.toString(),
                                  unit: 'days',
                                  icon: Icons.local_fire_department,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: 'This Week',
                                  value: stats.completedThisWeek.toString(),
                                  unit: 'completed',
                                  icon: Icons.check_circle,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Weekly Chart
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Activity',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                height: 220,
                                child: weeklyAsync.when(
                                  data: (weekly) => _buildWeeklyChart(
                                      weekly.dailyCompletions),
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (e, st) =>
                                      Center(child: Text('Error: $e')),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Completion Trend
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Completion Trend',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                height: 220,
                                child: trendAsync.when(
                                  data: (trend) => _buildTrendChart(
                                      trend.weeklyCompletionRates),
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (e, st) =>
                                      Center(child: Text('Error: $e')),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Habit Performance
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Habit Performance',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: habits.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final habit = habits[index];
                                return _buildHabitPerformanceRow(
                                    context, habit, index, ref);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Category Breakdown
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'By Category',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                height: 200,
                                child: _buildCategoryChart(
                                    stats.categoryBreakdown),
                              ),
                            ),
                          ),
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
                'Error loading statistics: $error',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading statistics: $error',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0) context.go('/');
          if (index == 1) context.go('/history');
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

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    String? unit,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Icon(icon, color: color, size: 20),
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

  Widget _buildWeeklyChart(List<int> dailyCompletions) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (dailyCompletions.isEmpty
            ? 10
            : dailyCompletions.reduce((a, b) => a > b ? a : b).toDouble() + 2),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ];
                return Text(
                  titles[value.toInt()],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          dailyCompletions.length,
          (index) => _makeBarGroup(index, dailyCompletions[index].toDouble()),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildTrendChart(List<double> weeklyCompletionRates) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
                final idx = value.toInt();
                return Text(
                  idx < titles.length ? titles[idx] : '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              weeklyCompletionRates.length,
              (index) => FlSpot(index.toDouble(), weeklyCompletionRates[index]),
            ),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(Map<String, int> categoryBreakdown) {
    if (categoryBreakdown.isEmpty) {
      return const Center(child: Text('No category data available'));
    }

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];

    return PieChart(
      PieChartData(
        sections: List.generate(
          categoryBreakdown.length,
          (index) {
            final entry = categoryBreakdown.entries.toList()[index];
            return PieChartSectionData(
              color: colors[index % colors.length],
              value: entry.value.toDouble(),
              title: entry.key,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHabitPerformanceRow(
    BuildContext context,
    Habit habit,
    int index,
    WidgetRef ref,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final entriesAsync = ref.watch(entriesByHabitProvider(habit.uuid));

        return entriesAsync.when(
          data: (entries) {
            if (entries.isEmpty) {
              return const SizedBox.shrink();
            }

            final completed = entries.where((e) => e.completed).length;
            final completionRate = (completed / entries.length * 100).toInt();
            final streakColor =
                completionRate >= 80 ? Colors.green : Colors.orange;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${habit.category.toString().split('.').last.toUpperCase()} • ${habit.frequencyType.toString().split('.').last.toUpperCase()}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Stats
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$completionRate%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: streakColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: completionRate / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(streakColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
        );
      },
    );
  }
}
