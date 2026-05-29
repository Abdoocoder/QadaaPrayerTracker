import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/data/models/prayer_log_model.dart';

void main() {
  group('PrayerLogModel', () {
    test('toMap returns correct map with all fields', () {
      final model = PrayerLogModel(
        id: 1,
        date: '2026-05-29',
        prayerName: 'fajr',
        completed: true,
        createdAt: '2026-05-29',
      );
      final map = model.toMap();
      expect(map['id'], 1);
      expect(map['date'], '2026-05-29');
      expect(map['prayer_name'], 'fajr');
      expect(map['completed'], 1);
      expect(map['created_at'], '2026-05-29');
    });

    test('toMap omits id when null', () {
      final model = PrayerLogModel(
        date: '2026-05-29',
        prayerName: 'dhuhr',
        completed: false,
        createdAt: '2026-05-29',
      );
      final map = model.toMap();
      expect(map.containsKey('id'), false);
      expect(map['prayer_name'], 'dhuhr');
      expect(map['completed'], 0);
    });

    test('toMap stores false as 0', () {
      final model = PrayerLogModel(
        date: '2026-05-29',
        prayerName: 'asr',
        completed: false,
        createdAt: '2026-05-29',
      );
      expect(model.toMap()['completed'], 0);
    });

    test('toMap stores true as 1', () {
      final model = PrayerLogModel(
        date: '2026-05-29',
        prayerName: 'maghrib',
        completed: true,
        createdAt: '2026-05-29',
      );
      expect(model.toMap()['completed'], 1);
    });

    test('fromMap reconstructs model correctly', () {
      final map = <String, dynamic>{
        'id': 5,
        'date': '2026-06-01',
        'prayer_name': 'isha',
        'completed': 1,
        'created_at': '2026-06-01',
      };
      final model = PrayerLogModel.fromMap(map);
      expect(model.id, 5);
      expect(model.date, '2026-06-01');
      expect(model.prayerName, 'isha');
      expect(model.completed, isTrue);
      expect(model.createdAt, '2026-06-01');
    });

    test('fromMap handles null id', () {
      final map = <String, dynamic>{
        'date': '2026-06-02',
        'prayer_name': 'fajr',
        'completed': 0,
        'created_at': '2026-06-02',
      };
      final model = PrayerLogModel.fromMap(map);
      expect(model.id, isNull);
      expect(model.completed, isFalse);
    });

    test('fromMap round-trip preserves all fields', () {
      final original = PrayerLogModel(
        id: 10,
        date: '2026-07-15',
        prayerName: 'dhuhr',
        completed: true,
        createdAt: '2026-07-15T10:00:00',
      );
      final model = PrayerLogModel.fromMap(original.toMap());
      expect(model.id, 10);
      expect(model.date, '2026-07-15');
      expect(model.prayerName, 'dhuhr');
      expect(model.completed, isTrue);
      expect(model.createdAt, '2026-07-15T10:00:00');
    });

    test('dateToStr formats DateTime correctly', () {
      final date = DateTime(2026, 5, 29);
      expect(PrayerLogModel.dateToStr(date), '2026-05-29');
    });

    test('dateToStr pads single-digit month and day', () {
      final date = DateTime(2026, 1, 3);
      expect(PrayerLogModel.dateToStr(date), '2026-01-03');
    });

    test('dateToStr handles end of year', () {
      final date = DateTime(2026, 12, 31);
      expect(PrayerLogModel.dateToStr(date), '2026-12-31');
    });

    test('strToDate parses date string correctly', () {
      final date = PrayerLogModel.strToDate('2026-05-29');
      expect(date.year, 2026);
      expect(date.month, 5);
      expect(date.day, 29);
    });

    test('strToDate round-trips with dateToStr', () {
      final original = DateTime(2026, 10, 5);
      final str = PrayerLogModel.dateToStr(original);
      final parsed = PrayerLogModel.strToDate(str);
      expect(parsed.year, original.year);
      expect(parsed.month, original.month);
      expect(parsed.day, original.day);
    });
  });
}
