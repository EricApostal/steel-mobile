enum LogLevel { trace, debug, info, warn, error, system, command }

class LogEntry {
  const LogEntry({
    required this.id,
    required this.level,
    required this.message,
    this.time,
    this.count = 1,
  });

  final int id;
  final LogLevel level;

  /// Seconds since the server started, as printed by Steel (e.g. `0.02s`).
  final String? time;
  final String message;

  /// How many consecutive identical lines this entry stands for.
  final int count;

  LogEntry withMessage(String message) =>
      LogEntry(id: id, level: level, message: message, time: time, count: count);

  /// This entry again, one more time (identical consecutive line).
  LogEntry repeated(String? latestTime) =>
      LogEntry(id: id, level: level, message: message, time: latestTime ?? time, count: count + 1);

  bool sameAs(LogEntry other) =>
      level == other.level && message == other.message;

  /// Parses a Steel log line such as `  0.02s [Info] Started Steel Server`.
  /// Returns null for lines that aren't in that format (continuations).
  static LogEntry? parse(String line, int id) {
    final m = _line.firstMatch(line);
    if (m == null) return null;
    return LogEntry(
      id: id,
      time: m.group(1),
      level: switch (m.group(2)!.toLowerCase()) {
        'trace' => LogLevel.trace,
        'debug' => LogLevel.debug,
        'warn' || 'warning' => LogLevel.warn,
        'error' || 'fatal' => LogLevel.error,
        _ => LogLevel.info,
      },
      message: m.group(3)!,
    );
  }

  static final _line = RegExp(r'^\s*(\d+(?:\.\d+)?s)\s+\[(\w+)\]\s?(.*)$');
}
