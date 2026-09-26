/// "1:05" for timers (m:ss), "1:02:05" past an hour.
String formatClock(Duration d) {
  final negative = d.isNegative;
  d = d.abs();
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final body = h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
  return negative ? '-$body' : body;
}

/// "45 min", "1 h 12 min" for summaries.
String formatDurationShort(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h == 0) return '${d.inMinutes} min';
  return m == 0 ? '$h h' : '$h h $m min';
}
