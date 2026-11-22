import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/log_entry.dart';

part 'console_filter.g.dart';

enum ConsoleFilter {
  all('All'),
  warnings('Warnings'),
  errors('Errors');

  const ConsoleFilter(this.label);
  final String label;

  /// App messages and echoed commands always stay visible for context.
  bool accepts(LogEntry e) => switch (this) {
        all => true,
        warnings => const {LogLevel.warn, LogLevel.error, LogLevel.system, LogLevel.command}.contains(e.level),
        errors => const {LogLevel.error, LogLevel.system, LogLevel.command}.contains(e.level),
      };
}

/// The selected log filter for an instance, kept while you switch tabs.
@Riverpod(keepAlive: true)
class ConsoleFilterController extends _$ConsoleFilterController {
  @override
  ConsoleFilter build(String instanceId) => ConsoleFilter.all;

  void select(ConsoleFilter filter) => state = filter;
}
