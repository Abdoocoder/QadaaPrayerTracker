class PrayerLogModel {
  final int? id;
  final String date;
  final String prayerName;
  final bool completed;
  final String createdAt;

  PrayerLogModel({
    this.id,
    required this.date,
    required this.prayerName,
    required this.completed,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'date': date,
    'prayer_name': prayerName,
    'completed': completed ? 1 : 0,
    'created_at': createdAt,
  };

  factory PrayerLogModel.fromMap(Map<String, dynamic> map) => PrayerLogModel(
    id: map['id'] as int?,
    date: map['date'] as String,
    prayerName: map['prayer_name'] as String,
    completed: (map['completed'] as int) == 1,
    createdAt: map['created_at'] as String,
  );

  static String dateToStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime strToDate(String s) {
    final parts = s.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}
