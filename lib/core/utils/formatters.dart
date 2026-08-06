import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM dd').format(dateTime);
  }

  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }
}
