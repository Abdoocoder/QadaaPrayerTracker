import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';

void main() {
  group('PrayerName', () {
    test('has 5 prayer values', () {
      expect(PrayerName.values.length, 5);
    });

    test('includes fajr, dhuhr, asr, maghrib, isha', () {
      expect(PrayerName.values, containsAll([
        PrayerName.fajr,
        PrayerName.dhuhr,
        PrayerName.asr,
        PrayerName.maghrib,
        PrayerName.isha,
      ]));
    });

    test('allPrayers contains all 5 prayers', () {
      expect(allPrayers.length, 5);
      expect(allPrayers, unorderedEquals(PrayerName.values));
    });

    test('fajr has correct arName', () {
      expect(PrayerName.fajr.arName, 'الفجر');
    });

    test('dhuhr has correct arName', () {
      expect(PrayerName.dhuhr.arName, 'الظهر');
    });

    test('asr has correct arName', () {
      expect(PrayerName.asr.arName, 'العصر');
    });

    test('maghrib has correct arName', () {
      expect(PrayerName.maghrib.arName, 'المغرب');
    });

    test('isha has correct arName', () {
      expect(PrayerName.isha.arName, 'العشاء');
    });

    test('fajr has 2 rakahs', () {
      expect(PrayerName.fajr.rakah, 2);
    });

    test('dhuhr has 4 rakahs', () {
      expect(PrayerName.dhuhr.rakah, 4);
    });

    test('asr has 4 rakahs', () {
      expect(PrayerName.asr.rakah, 4);
    });

    test('maghrib has 3 rakahs', () {
      expect(PrayerName.maghrib.rakah, 3);
    });

    test('isha has 4 rakahs', () {
      expect(PrayerName.isha.rakah, 4);
    });

    test('allPrayers matches PrayerName.values order', () {
      expect(allPrayers, orderedEquals(PrayerName.values));
    });

    test('PrayerName.values byName works for all', () {
      for (final p in allPrayers) {
        expect(PrayerName.values.byName(p.name), p);
      }
    });

    test('index values are sequential', () {
      for (int i = 0; i < PrayerName.values.length; i++) {
        expect(PrayerName.values[i].index, i);
      }
    });
  });
}
