import 'package:qadaa_prayer_tracker/domain/models/qadaa_progress.dart';

class QadaaProgressModel {
  final String prayerName;
  final int totalMissed;
  final int completed;
  final String updatedAt;

  const QadaaProgressModel({
    required this.prayerName,
    required this.totalMissed,
    required this.completed,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'prayer_name': prayerName,
        'total_missed': totalMissed,
        'completed': completed,
        'updated_at': updatedAt,
      };

  factory QadaaProgressModel.fromMap(Map<String, dynamic> map) =>
      QadaaProgressModel(
        prayerName: map['prayer_name'] as String,
        totalMissed: map['total_missed'] as int,
        completed: map['completed'] as int,
        updatedAt: map['updated_at'] as String,
      );

  QadaaProgress toDomain() => QadaaProgress(
        totalMissed: totalMissed,
        completed: completed,
      );
}
