import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/domain/models/day_log.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';

void main() {
  final allFalse = {for (final p in allPrayers) p: false};
  final allTrue = {for (final p in allPrayers) p: true};
  final oneTrue = {for (final p in allPrayers) p: p == PrayerName.fajr};
  final twoTrue = {for (final p in allPrayers) p: p == PrayerName.fajr || p == PrayerName.dhuhr};

  group('DayLog', () {
    test('constructor sets date and prayers', () {
      final date = DateTime(2026, 5, 29);
      final log = DayLog(date: date, prayers: allFalse);
      expect(log.date, date);
      expect(log.prayers, allFalse);
    });

    test('total returns 5 for all prayers', () {
      final log = DayLog(date: DateTime.now(), prayers: allFalse);
      expect(log.total, 5);
    });

    test('completed returns 0 when none done', () {
      final log = DayLog(date: DateTime.now(), prayers: allFalse);
      expect(log.completed, 0);
    });

    test('completed returns 5 when all done', () {
      final log = DayLog(date: DateTime.now(), prayers: allTrue);
      expect(log.completed, 5);
    });

    test('completed returns 1 when one prayer done', () {
      final log = DayLog(date: DateTime.now(), prayers: oneTrue);
      expect(log.completed, 1);
    });

    test('completed returns 2 when two prayers done', () {
      final log = DayLog(date: DateTime.now(), prayers: twoTrue);
      expect(log.completed, 2);
    });

    test('percentage returns 0 when none done', () {
      final log = DayLog(date: DateTime.now(), prayers: allFalse);
      expect(log.percentage, 0.0);
    });

    test('percentage returns 1.0 when all done', () {
      final log = DayLog(date: DateTime.now(), prayers: allTrue);
      expect(log.percentage, 1.0);
    });

    test('percentage returns 0.2 when one of five done', () {
      final log = DayLog(date: DateTime.now(), prayers: oneTrue);
      expect((log.percentage * 100).round(), 20);
    });

    test('percentage returns 0.4 when two of five done', () {
      final log = DayLog(date: DateTime.now(), prayers: twoTrue);
      expect((log.percentage * 100).round(), 40);
    });

    test('isCompleted returns true for completed prayer', () {
      final log = DayLog(date: DateTime.now(), prayers: oneTrue);
      expect(log.isCompleted(PrayerName.fajr), isTrue);
    });

    test('isCompleted returns false for incomplete prayer', () {
      final log = DayLog(date: DateTime.now(), prayers: oneTrue);
      expect(log.isCompleted(PrayerName.dhuhr), isFalse);
    });

    test('isCompleted returns false for missing prayer key', () {
      final log = DayLog(date: DateTime.now(), prayers: {});
      expect(log.isCompleted(PrayerName.fajr), isFalse);
    });

    test('immutable after construction', () {
      final date = DateTime(2026, 5, 29);
      final log = DayLog(date: date, prayers: {});
      expect(log.date, date);
      expect(log.prayers, {});
    });
  });
}
