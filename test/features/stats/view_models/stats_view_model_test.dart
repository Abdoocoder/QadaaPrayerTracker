import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/ui/features/stats/view_models/stats_view_model.dart';
import '../../../helpers/mocks.dart';

void main() {
  late StatsViewModel vm;
  late MockLogRepo logRepo;

  setUp(() {
    logRepo = MockLogRepo();
    vm = StatsViewModel(logRepo: logRepo);
  });

  group('StatsViewModel', () {
    test('initial state', () {
      expect(vm.loading, isTrue);
      expect(vm.agg, isNull);
      expect(vm.dist, isNull);
      expect(vm.weekLogs, isNull);
      expect(vm.error, isNull);
    });

    test('load sets aggregates on success', () async {
      await vm.load();
      expect(vm.agg, isNotNull);
      expect(vm.agg!['all_done'], 200);
    });

    test('load sets distribution on success', () async {
      await vm.load();
      expect(vm.dist, isNotNull);
      expect(vm.dist!['fajr'], 50);
    });

    test('load sets week logs on success', () async {
      await vm.load();
      expect(vm.weekLogs, isNotNull);
      expect(vm.weekLogs!.length, 7);
    });

    test('load sets loading false after completion', () async {
      await vm.load();
      expect(vm.loading, isFalse);
    });

    test('load sets error on failure', () async {
      final failingLogRepo = MockLogRepo();
      failingLogRepo.failOnGetDayLog = true;
      vm = StatsViewModel(logRepo: failingLogRepo);
      await vm.load();
      expect(vm.error, isNotNull);
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
