extension DateExtension on DateTime {
  String dateToHours() {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }
}
