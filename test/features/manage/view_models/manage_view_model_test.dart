import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/domain/models/prayer_name.dart';
import 'package:qadaa_prayer_tracker/ui/features/manage/view_models/manage_view_model.dart';
import '../../../helpers/mocks.dart';

void main() {
  late ManageViewModel vm;
  late MockLogRepo logRepo;
  late MockTimeRepo timeRepo;

  setUp(() {
    logRepo = MockLogRepo();
    timeRepo = MockTimeRepo();
    vm = ManageViewModel(logRepo: logRepo, timeRepo: timeRepo);
  });

  group('ManageViewModel', () {
    test('initial state', () {
      expect(vm.loading, isTrue);
      expect(vm.selectedDay, 0);
      expect(vm.dayLog, isNull);
      expect(vm.times, isNull);
      expect(vm.error, isNull);
      expect(vm.dates.length, 7);
    });

    test('loadDay sets data on success', () async {
      await vm.loadDay();
      expect(vm.loading, isFalse);
      expect(vm.dayLog, isNotNull);
      expect(vm.times, isNotNull);
      expect(vm.error, isNull);
    });

    test('loadDay sets day log', () async {
      await vm.loadDay();
      expect(vm.dayLog!.date, testDayLog.date);
    });

    test('loadDay sets prayer times', () async {
      await vm.loadDay();
      expect(vm.times!.fajr, '04:30');
    });

    test('loadDay sets error on failure', () async {
      final failingLogRepo = MockLogRepo();
      failingLogRepo.failOnGetDayLog = true;
      vm = ManageViewModel(logRepo: failingLogRepo, timeRepo: timeRepo);
      await vm.loadDay();
      expect(vm.error, isNotNull);
      expect(vm.loading, isFalse);
    });

    test('selectDay updates selected day and reloads', () async {
      await vm.loadDay();
      expect(vm.selectedDay, 0);
      vm.selectDay(2);
      expect(vm.selectedDay, 2);
      expect(vm.loading, isTrue);
    });

    test('toggle prayer calls repository', () async {
      await vm.loadDay();
      var toggled = false;
      logRepo.onToggle = (date, prayer) {
        toggled = true;
        expect(prayer, PrayerName.fajr);
      };
      await vm.toggle(PrayerName.fajr);
      expect(toggled, isTrue);
    });

    test('toggle sets error on failure', () async {
      await vm.loadDay();
      final failingLogRepo = MockLogRepo();
      failingLogRepo.failOnToggle = true;
      vm = ManageViewModel(logRepo: failingLogRepo, timeRepo: timeRepo);
      await vm.loadDay();
      failingLogRepo.failOnToggle = true;
      await vm.toggle(PrayerName.fajr);
      expect(vm.error, isNotNull);
    });

    test('notifies listeners on loadDay', () async {
      int notifyCount = 0;
      vm.addListener(() => notifyCount++);
      await vm.loadDay();
      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });
}
