import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/ui/features/home/view_models/home_view_model.dart';
import '../../../helpers/mocks.dart';

void main() {
  late HomeViewModel vm;
  late MockLogRepo logRepo;
  late MockTimeRepo timeRepo;

  setUp(() {
    logRepo = MockLogRepo();
    timeRepo = MockTimeRepo();
    vm = HomeViewModel(logRepo: logRepo, timeRepo: timeRepo);
  });

  group('HomeViewModel', () {
    test('initial state', () {
      expect(vm.loading, isTrue);
      expect(vm.today, isNull);
      expect(vm.times, isNull);
      expect(vm.agg, isNull);
      expect(vm.error, isNull);
    });

    test('load sets data on success', () async {
      await vm.load();
      expect(vm.loading, isFalse);
      expect(vm.today, isNotNull);
      expect(vm.times, isNotNull);
      expect(vm.agg, isNotNull);
      expect(vm.error, isNull);
    });

    test('load sets today day log', () async {
      await vm.load();
      expect(vm.today!.date, testDayLog.date);
    });

    test('load sets aggregates', () async {
      await vm.load();
      expect(vm.agg!['today_done'], 0);
    });

    test('load sets prayer times', () async {
      await vm.load();
      expect(vm.times!.fajr, '04:30');
    });

    test('load sets error on failure', () async {
      final failingRepo = MockLogRepo();
      failingRepo.failOnGetDayLog = true;
      vm = HomeViewModel(logRepo: failingRepo, timeRepo: timeRepo);
      await vm.load();
      expect(vm.loading, isFalse);
      expect(vm.error, isNotNull);
    });

    test('load sets loading state correctly', () async {
      final loadFuture = vm.load();
      expect(vm.loading, isTrue);
      await loadFuture;
      expect(vm.loading, isFalse);
    });

    test('notifies listeners on load', () async {
      int notifyCount = 0;
      vm.addListener(() => notifyCount++);
      await vm.load();
      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });
}
