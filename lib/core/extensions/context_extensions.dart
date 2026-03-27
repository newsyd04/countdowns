import 'package:flutter/material.dart';

/// Convenience extensions on BuildContext for cleaner widget code.
extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Brightness get brightness => Theme.of(this).brightness;
}

/// Convenience extensions on DateTime.
extension DateTimeExtensions on DateTime {
  /// Returns true if this date is the same calendar day as [other].
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Returns a new DateTime with only the date components (no time).
  DateTime get dateOnly => DateTime(year, month, day);
}
