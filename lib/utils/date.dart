extension DateComparision on DateTime {
  // Year, Month, Day, Hour, Minute
  bool equalsYMD(DateTime other) =>
      this.year == other.year &&
      this.month == other.month &&
      this.day == other.day;

  // Hour, Minute
  bool equalsHM(DateTime other) =>
      this.hour == other.hour && this.minute == other.minute;
}
