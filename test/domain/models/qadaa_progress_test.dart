import 'package:flutter_test/flutter_test.dart';
import 'package:qadaa_prayer_tracker/domain/models/qadaa_progress.dart';

void main() {
  group('QadaaProgress', () {
    test('remaining = totalMissed - completed', () {
      final p = QadaaProgress(totalMissed: 365, completed: 40);
      expect(p.remaining, 325);
    });

    test('percentage = (completed / totalMissed) * 100', () {
      final p = QadaaProgress(totalMissed: 365, completed: 73);
      expect(p.percentage, 20.0);
    });

    test('percentage is 0 when totalMissed is 0', () {
      final p = QadaaProgress(totalMissed: 0, completed: 0);
      expect(p.percentage, 0.0);
    });

    test('isComplete returns true when remaining == 0', () {
      final p = QadaaProgress(totalMissed: 365, completed: 365);
      expect(p.isComplete, true);
    });

    test('isComplete returns false when remaining > 0', () {
      final p = QadaaProgress(totalMissed: 365, completed: 100);
      expect(p.isComplete, false);
    });
  });
}
