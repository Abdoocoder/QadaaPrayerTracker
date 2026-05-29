import 'prayer_name.dart';

class DayLog {
  final DateTime date;
  final Map<PrayerName, bool> prayers;

  const DayLog({required this.date, required this.prayers});

  int get total => prayers.length;
  int get completed => prayers.values.where((v) => v).length;
  double get percentage => total > 0 ? completed / total : 0;

  bool isCompleted(PrayerName name) => prayers[name] ?? false;
}
