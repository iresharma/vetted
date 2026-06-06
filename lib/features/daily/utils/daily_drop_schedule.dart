/// Daily 5 queue drops at 6 AM India Standard Time (UTC+5:30, no DST).
abstract final class DailyDropSchedule {
  static const _istOffset = Duration(hours: 5, minutes: 30);

  /// UTC instant of the next 6 AM IST drop (today if before 6 AM, else tomorrow).
  static DateTime nextDropUtc({DateTime? utcNow}) {
    final now = (utcNow ?? DateTime.now()).toUtc();
    final ist = now.add(_istOffset);

    var dropUtc = DateTime.utc(ist.year, ist.month, ist.day, 6, 0).subtract(_istOffset);
    if (!now.isBefore(dropUtc)) {
      dropUtc = dropUtc.add(const Duration(days: 1));
    }
    return dropUtc;
  }

  static Duration timeUntilNextDrop({DateTime? utcNow}) {
    final remaining = nextDropUtc(utcNow: utcNow).difference((utcNow ?? DateTime.now()).toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static String formatCountdown(Duration remaining) {
    final totalSeconds = remaining.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
