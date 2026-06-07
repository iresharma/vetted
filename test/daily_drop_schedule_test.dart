import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/features/daily/utils/daily_drop_schedule.dart';

void main() {
  group('DailyDropSchedule', () {
    test('before 6 AM IST today targets same-day drop', () {
      // 2026-06-06 04:00 UTC = 2026-06-06 09:30 IST — wait that's wrong
      // 04:00 UTC + 5:30 = 09:30 IST — past 6 AM
      // 00:00 UTC = 05:30 IST — before 6 AM
      final now = DateTime.utc(2026, 6, 6, 0, 0);
      final drop = DailyDropSchedule.nextDropUtc(utcNow: now);
      expect(drop, DateTime.utc(2026, 6, 6, 0, 30)); // 6 AM IST
    });

    test('after 6 AM IST today targets tomorrow', () {
      final now = DateTime.utc(2026, 6, 6, 1, 0); // 06:30 IST
      final drop = DailyDropSchedule.nextDropUtc(utcNow: now);
      expect(drop, DateTime.utc(2026, 6, 7, 0, 30));
    });

    test('formatCountdown pads segments', () {
      expect(
        DailyDropSchedule.formatCountdown(const Duration(hours: 9, minutes: 4, seconds: 7)),
        '09:04:07',
      );
    });
  });
}
