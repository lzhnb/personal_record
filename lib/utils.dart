import "package:tuple/tuple.dart";
import "package:intl/intl.dart";

/* Calendar */
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 1, 1, 1);
final kLastDay = DateTime(kToday.year + 1, 12, 31);
