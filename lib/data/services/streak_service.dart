import '../../domain/models/habit.dart';
import '../../domain/models/habit_entry.dart';
import '../../domain/models/stats_summary.dart';

class StreakService {
  StatsSummary calculateStats(Habit habit, List<HabitEntry> entries) {
    if (entries.isEmpty) {
      return StatsSummary.empty();
    }

    // Sort entries by date descending
    entries.sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    int longestStreak = 0;
    int currentTempStreak = 0;
    
    // Simplistic daily streak calculation for MVP
    // Assuming 1 entry = 1 day
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    
    // Filter completed entries
    final completedEntries = entries.where((e) => e.completed).toList();
    if (completedEntries.isEmpty) {
      return StatsSummary.empty();
    }

    // Calculate streaks
    DateTime? lastDate;
    for (var i = 0; i < completedEntries.length; i++) {
      var entryDate = DateTime(
          completedEntries[i].date.year,
          completedEntries[i].date.month,
          completedEntries[i].date.day);

      if (lastDate == null) {
        currentTempStreak = 1;
        if (entryDate == today || entryDate == today.subtract(const Duration(days: 1))) {
          currentStreak = 1;
        }
      } else {
        final difference = lastDate.difference(entryDate).inDays;
        if (difference == 1) {
          currentTempStreak++;
          if (currentStreak > 0) {
            currentStreak++;
          }
        } else if (difference > 1) {
          if (currentTempStreak > longestStreak) {
            longestStreak = currentTempStreak;
          }
          currentTempStreak = 1;
          if (currentStreak > 0 && lastDate != today && lastDate != today.subtract(const Duration(days: 1))) {
            currentStreak = 0; // Streak broken
          }
        }
      }
      lastDate = entryDate;
    }

    if (currentTempStreak > longestStreak) {
      longestStreak = currentTempStreak;
    }

    // Calculate completion rate (completed / total entries)
    // For a real app, this should be (completed / days since creation)
    final daysSinceCreation = today.difference(DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day)).inDays + 1;
    final completionRate = daysSinceCreation > 0 ? completedEntries.length / daysSinceCreation : 0.0;

    // Completed this week
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final completedThisWeek = completedEntries.where((e) => e.date.isAfter(startOfWeek.subtract(const Duration(days: 1)))).length;

    // Completed this month
    final startOfMonth = DateTime(today.year, today.month, 1);
    final completedThisMonth = completedEntries.where((e) => e.date.isAfter(startOfMonth.subtract(const Duration(days: 1)))).length;

    return StatsSummary(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      completionRate: completionRate,
      completedThisWeek: completedThisWeek,
      completedThisMonth: completedThisMonth,
    );
  }
}
