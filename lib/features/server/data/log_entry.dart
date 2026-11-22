enum LogLevel { trace, debug, info, warn, error, system }

class LogEntry {
  const LogEntry({
    required this.id,
    required this.level,
    required this.message,
    this.time,
  });

  final int id;
  final LogLevel level;

  /// Seconds since the server started, as printed by Steel (e.g. `0.02s`).
  final String? time;
  final String message;

  LogEntry withMessage(String message) =>
      LogEntry(id: id, level: level, message: message, time: time);

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
