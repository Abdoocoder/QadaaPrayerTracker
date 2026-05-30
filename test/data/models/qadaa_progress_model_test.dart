import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/data/models/qadaa_progress_model.dart';

void main() {
  group('QadaaProgressModel', () {
    test('toMap / fromMap round-trip', () {
      final model = QadaaProgressModel(
        prayerName: 'fajr',
        totalMissed: 365,
        completed: 40,
        updatedAt: '2026-05-30T10:00:00',
      );
      final map = model.toMap();
      final restored = QadaaProgressModel.fromMap(map);
      expect(restored.prayerName, 'fajr');
      expect(restored.totalMissed, 365);
      expect(restored.completed, 40);
      expect(restored.updatedAt, '2026-05-30T10:00:00');
    });

    test('toDomain creates QadaaProgress', () {
      final model = QadaaProgressModel(
        prayerName: 'dhuhr',
        totalMissed: 365,
        completed: 50,
        updatedAt: '2026-05-30T10:00:00',
      );
      final domain = model.toDomain();
      expect(domain.totalMissed, 365);
      expect(domain.completed, 50);
      expect(domain.remaining, 315);
    });
  });
}
