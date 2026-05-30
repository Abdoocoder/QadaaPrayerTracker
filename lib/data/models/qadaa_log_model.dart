class QadaaLogModel {
  final int? id;
  final String prayerName;
  final int count;
  final String createdAt;

  const QadaaLogModel({
    this.id,
    required this.prayerName,
    required this.count,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'prayer_name': prayerName,
        'count': count,
        'created_at': createdAt,
      };

  factory QadaaLogModel.fromMap(Map<String, dynamic> map) => QadaaLogModel(
        id: map['id'] as int?,
        prayerName: map['prayer_name'] as String,
        count: map['count'] as int,
        createdAt: map['created_at'] as String,
      );
}
