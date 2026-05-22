/// Week utility class for ISO 8601 week number calculations.
class WeekUtils {
  /// Returns the current year.
  static int getCurrentYear() {
    return DateTime.now().year;
  }

  /// Returns the current ISO week number (1-53).
  ///
  /// Uses ISO 8601 standard: week 1 contains the first Thursday of the year.
  static int getCurrentWeekNumber() {
    final now = DateTime.now();
    final year = now.year;

    // Jan 4 is always in week 1 of the year
    final jan4 = DateTime(year, 1, 4);

    // Find the Monday of the week containing Jan 4
    final week1Monday = jan4.subtract(Duration(days: jan4.weekday - 1));

    // If current date is before week 1 Monday, it's in the last week of previous year
    if (now.isBefore(week1Monday)) {
      final prevYear = year - 1;
      final prevJan4 = DateTime(prevYear, 1, 4);
      final prevWeek1Monday =
          prevJan4.subtract(Duration(days: prevJan4.weekday - 1));
      final daysSincePrevWeek1 = now.difference(prevWeek1Monday).inDays;
      return (daysSincePrevWeek1 ~/ 7) + 1;
    }

    // Calculate week number for this year
    final daysSinceWeek1Monday = now.difference(week1Monday).inDays;
    return (daysSinceWeek1Monday ~/ 7) + 1;
  }

  /// Returns the current week key in format "service_clicks_{year}_W{week}".
  static String getCurrentWeekKey() {
    final year = getCurrentYear();
    final week = getCurrentWeekNumber();
    return 'service_clicks_${year}_W$week';
  }
}
