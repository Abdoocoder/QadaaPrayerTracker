import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_times.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';

void main() {
  const sample = PrayerTimes(
    fajr: '04:30',
    sunrise: '05:45',
    dhuhr: '12:30',
    asr: '16:00',
    maghrib: '19:30',
    isha: '21:00',
    timezone: 'Asia/Amman',
  );

  group('PrayerTimes', () {
    test('stores all prayer times', () {
      expect(sample.fajr, '04:30');
      expect(sample.sunrise, '05:45');
      expect(sample.dhuhr, '12:30');
      expect(sample.asr, '16:00');
      expect(sample.maghrib, '19:30');
      expect(sample.isha, '21:00');
    });

    test('defaults timezone to Asia/Amman', () {
      expect(sample.timezone, 'Asia/Amman');
    });

    test('forPrayer returns correct time for each prayer', () {
      expect(sample.forPrayer(PrayerName.fajr), '04:30');
      expect(sample.forPrayer(PrayerName.dhuhr), '12:30');
      expect(sample.forPrayer(PrayerName.asr), '16:00');
      expect(sample.forPrayer(PrayerName.maghrib), '19:30');
      expect(sample.forPrayer(PrayerName.isha), '21:00');
    });

    test('forPrayer handles sunrise', () {
      expect(sample.forPrayer(PrayerName.fajr), '04:30');
    });

    test('custom timezone is preserved', () {
      const custom = PrayerTimes(
        fajr: '05:00', sunrise: '06:00', dhuhr: '12:00',
        asr: '15:30', maghrib: '18:45', isha: '20:15',
        timezone: 'America/New_York',
      );
      expect(custom.timezone, 'America/New_York');
    });

    test('const constructor works', () {
      const times = PrayerTimes(
        fajr: '04:30', sunrise: '05:45', dhuhr: '12:30',
        asr: '16:00', maghrib: '19:30', isha: '21:00',
      );
      expect(times.fajr, '04:30');
    });
  });
}
