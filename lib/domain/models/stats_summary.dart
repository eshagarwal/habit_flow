class StatsSummary {
  final int currentStreak;
  final int longestStreak;
  final double completionRate;
  final int completedThisWeek;
  final int completedThisMonth;

  StatsSummary({
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    required this.completedThisWeek,
    required this.completedThisMonth,
  });

  factory StatsSummary.empty() {
    return StatsSummary(
      currentStreak: 0,
      longestStreak: 0,
      completionRate: 0.0,
      completedThisWeek: 0,
      completedThisMonth: 0,
    );
  }
}
