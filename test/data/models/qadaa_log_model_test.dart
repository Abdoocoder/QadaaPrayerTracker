import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/data/models/qadaa_log_model.dart';

void main() {
  group('QadaaLogModel', () {
    test('toMap / fromMap round-trip', () {
      final model = QadaaLogModel(
        id: 1,
        prayerName: 'fajr',
        count: 4,
        createdAt: '2026-05-30T10:00:00',
      );
      final map = model.toMap();
      final restored = QadaaLogModel.fromMap(map);
      expect(restored.id, 1);
      expect(restored.prayerName, 'fajr');
      expect(restored.count, 4);
      expect(restored.createdAt, '2026-05-30T10:00:00');
    });

    test('fromMap works without id (for new inserts)', () {
      final map = <String, dynamic>{
        'prayer_name': 'maghrib',
        'count': 3,
        'created_at': '2026-05-30T12:00:00',
      };
      final model = QadaaLogModel.fromMap(map);
      expect(model.id, isNull);
      expect(model.prayerName, 'maghrib');
      expect(model.count, 3);
    });
  });
}
