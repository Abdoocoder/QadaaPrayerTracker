import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/data/models/prayer_times_model.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';

void main() {
  final sampleJson = {
    'timings': {
      'Fajr': '04:30 (AST)',
      'Sunrise': '05:45',
      'Dhuhr': '12:30',
      'Asr': '16:00',
      'Maghrib': '19:30',
      'Isha': '21:00',
    },
    'meta': {
      'timezone': 'Asia/Amman',
    },
  };

  group('PrayerTimesModel', () {
    test('fromJson parses timings and cleans time strings', () {
      final model = PrayerTimesModel.fromJson(sampleJson, '2026-05-29');
      expect(model.date, '2026-05-29');
      expect(model.fajr, '04:30');
      expect(model.sunrise, '05:45');
      expect(model.dhuhr, '12:30');
      expect(model.asr, '16:00');
      expect(model.maghrib, '19:30');
      expect(model.isha, '21:00');
    });

    test('fromJson uses timezone from meta', () {
      final model = PrayerTimesModel.fromJson(sampleJson, '2026-05-29');
      expect(model.timezone, 'Asia/Amman');
    });

    test('fromJson defaults timezone when meta is missing', () {
      final json = {
        'timings': {
          'Fajr': '04:30', 'Sunrise': '05:45', 'Dhuhr': '12:30',
          'Asr': '16:00', 'Maghrib': '19:30', 'Isha': '21:00',
        },
        'meta': <String, dynamic>{},
      };
      final model = PrayerTimesModel.fromJson(json, '2026-05-29');
      expect(model.timezone, 'Asia/Amman');
    });

    test('toMap returns all fields', () {
      final model = PrayerTimesModel(
        date: '2026-05-29',
        fajr: '04:30', sunrise: '05:45', dhuhr: '12:30',
        asr: '16:00', maghrib: '19:30', isha: '21:00',
        timezone: 'Asia/Amman',
      );
      final map = model.toMap();
      expect(map['date'], '2026-05-29');
      expect(map['fajr'], '04:30');
      expect(map['sunrise'], '05:45');
      expect(map['dhuhr'], '12:30');
      expect(map['asr'], '16:00');
      expect(map['maghrib'], '19:30');
      expect(map['isha'], '21:00');
      expect(map['timezone'], 'Asia/Amman');
    });

    test('fromMap reconstructs model correctly', () {
      final map = <String, dynamic>{
        'date': '2026-06-01',
        'fajr': '05:00', 'sunrise': '06:00', 'dhuhr': '12:00',
        'asr': '15:30', 'maghrib': '18:45', 'isha': '20:15',
        'timezone': 'America/New_York',
      };
      final model = PrayerTimesModel.fromMap(map);
      expect(model.date, '2026-06-01');
      expect(model.fajr, '05:00');
      expect(model.timezone, 'America/New_York');
    });

    test('fromMap defaults timezone when null', () {
      final map = <String, dynamic>{
        'date': '2026-06-01',
        'fajr': '05:00', 'sunrise': '06:00', 'dhuhr': '12:00',
        'asr': '15:30', 'maghrib': '18:45', 'isha': '20:15',
      };
      final model = PrayerTimesModel.fromMap(map);
      expect(model.timezone, 'Asia/Amman');
    });

    test('toDomain creates PrayerTimes with correct times', () {
      final model = PrayerTimesModel(
        date: '2026-05-29',
        fajr: '04:30', sunrise: '05:45', dhuhr: '12:30',
        asr: '16:00', maghrib: '19:30', isha: '21:00',
        timezone: 'Asia/Amman',
      );
      final domain = model.toDomain();
      expect(domain.fajr, '04:30');
      expect(domain.sunrise, '05:45');
      expect(domain.dhuhr, '12:30');
      expect(domain.asr, '16:00');
      expect(domain.maghrib, '19:30');
      expect(domain.isha, '21:00');
      expect(domain.timezone, 'Asia/Amman');
    });

    test('toDomain values can be looked up via forPrayer', () {
      final model = PrayerTimesModel(
        date: '2026-05-29',
        fajr: '04:30', sunrise: '05:45', dhuhr: '12:30',
        asr: '16:00', maghrib: '19:30', isha: '21:00',
        timezone: 'Asia/Amman',
      );
      final domain = model.toDomain();
      expect(domain.forPrayer(PrayerName.fajr), '04:30');
      expect(domain.forPrayer(PrayerName.dhuhr), '12:30');
      expect(domain.forPrayer(PrayerName.asr), '16:00');
      expect(domain.forPrayer(PrayerName.maghrib), '19:30');
      expect(domain.forPrayer(PrayerName.isha), '21:00');
    });

    test('fromJson round-trips through toDomain', () {
      final model = PrayerTimesModel.fromJson(sampleJson, '2026-05-29');
      final domain = model.toDomain();
      expect(domain.fajr, '04:30');
      expect(domain.sunrise, '05:45');
    });
  });
}
