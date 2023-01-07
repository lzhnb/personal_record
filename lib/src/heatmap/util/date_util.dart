// ignore: depend_on_referenced_packages
import "package:intl/intl.dart";

class DateUtil {
  // ignore: constant_identifier_names
  static const int DAYS_IN_WEEK = 7;

  // ignore: constant_identifier_names
  static const List<String> MONTH_LABEL = [
    "",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  // ignore: constant_identifier_names
  static const List<String> SHORT_MONTH_LABEL = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  // ignore: constant_identifier_names
  static const List<String> WEEK_LABEL = [
    "",
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
  ];

  /// Get start day of month.
  static DateTime startDayOfMonth(final DateTime referenceDate) =>
      DateTime(referenceDate.year, referenceDate.month, 1);

  /// Get last day of month.
  static DateTime endDayOfMonth(final DateTime referenceDate) =>
      DateTime(referenceDate.year, referenceDate.month + 1, 0);

  /// Get exactly one year before of [referenceDate].
  static DateTime oneYearBefore(final DateTime referenceDate) =>
      DateTime(referenceDate.year - 1, referenceDate.month, referenceDate.day);

  /// Separate [referenceDate]'s month to List of every weeks.
  static List<Map<DateTime, DateTime>> separatedMonth(
      final DateTime referenceDate) {
    // ignore: no_leading_underscores_for_local_identifiers
    DateTime _startDate = startDayOfMonth(referenceDate);
    // ignore: no_leading_underscores_for_local_identifiers
    DateTime _endDate = DateTime(_startDate.year, _startDate.month,
        _startDate.day + DAYS_IN_WEEK - _startDate.weekday % DAYS_IN_WEEK - 1);
    // ignore: no_leading_underscores_for_local_identifiers
    DateTime _finalDate = endDayOfMonth(referenceDate);
    // ignore: no_leading_underscores_for_local_identifiers
    List<Map<DateTime, DateTime>> _savedMonth = [];

    while (_startDate.isBefore(_finalDate) || _startDate == _finalDate) {
      _savedMonth.add({_startDate: _endDate});
      _startDate = changeDay(_endDate, 1);
      _endDate = changeDay(
          _endDate,
          endDayOfMonth(_endDate).day - _startDate.day >= DAYS_IN_WEEK
              ? DAYS_IN_WEEK
              : endDayOfMonth(_endDate).day - _startDate.day + 1);
    }
    return _savedMonth;
  }

  /// Change day of [referenceDate].
  static DateTime changeDay(final DateTime referenceDate, final int dayCount) =>
      DateTime(referenceDate.year, referenceDate.month,
          referenceDate.day + dayCount);

  /// Change month of [referenceDate].
  static DateTime changeMonth(final DateTime referenceDate, int monthCount) =>
      DateTime(referenceDate.year, referenceDate.month + monthCount,
          referenceDate.day);

  // ignore: non_constant_identifier_names
  static String date_format(DateTime date) =>
      DateFormat("yyyy-MM-dd").format(date);
}
