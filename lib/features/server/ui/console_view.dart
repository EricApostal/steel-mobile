import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../application/server_controller.dart';
import '../data/log_entry.dart';

enum _Filter {
  all('All'),
  warnings('Warnings'),
  errors('Errors');

  const _Filter(this.label);
  final String label;

  bool accepts(LogEntry e) => switch (this) {
        all => true,
        warnings => e.level == LogLevel.warn || e.level == LogLevel.error || e.level == LogLevel.system,
        errors => e.level == LogLevel.error || e.level == LogLevel.system,
      };
}

/// Compact, color-coded server log with a level filter.
class ConsoleView extends ConsumerStatefulWidget {
  const ConsoleView({super.key, required this.instanceId});

  final String instanceId;

  @override
  ConsumerState<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends ConsumerState<ConsoleView> {
  final _scroll = ScrollController();
  var _filter = _Filter.all;
  var _following = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients) _following = _scroll.position.extentAfter < 48;
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final entries = ref.watch(
      serverControllerProvider(widget.instanceId).select((s) => s.entries),
    );
    ref.listen(serverControllerProvider(widget.instanceId).select((s) => s.entries), (_, _) {
      if (_following) _jumpToEnd();
    });
    final visible = entries.where(_filter.accepts).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 4, 8),
          child: Row(
            children: [
              for (final f in _Filter.values) ...[
                FButton(
                  size: FButtonSizeVariant.xs,
                  variant: _filter == f ? FButtonVariant.secondary : FButtonVariant.ghost,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => setState(() => _filter = f),
                  child: Text(f.label),
                ),
                const SizedBox(width: 4),
              ],
              const Spacer(),
              FButton.icon(
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.sm,
                onPress: entries.isEmpty ? null : () => _copy(context, entries),
                child: const Icon(FLucideIcons.copy),
              ),
              FButton.icon(
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.sm,
                onPress: entries.isEmpty
                    ? null
                    : ref.read(serverControllerProvider(widget.instanceId).notifier).clearLog,
                child: const Icon(FLucideIcons.eraser),
              ),
            ],
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: theme.colors.secondary,
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      entries.isEmpty ? 'No output yet.' : 'Nothing matches this filter.',
                      style: theme.typography.body.sm.copyWith(color: theme.colors.mutedForeground),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: visible.length,
                    itemBuilder: (_, i) => _LogRow(entry: visible[i]),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _copy(BuildContext context, List<LogEntry> entries) async {
    final text = entries
        .map((e) => '${e.time ?? ''} ${e.level == LogLevel.system ? '' : '[${e.level.name}] '}${e.message}'.trim())
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showFToast(context: context, title: const Text('Log copied'));
    }
  }
}

const _warn = Color(0xFFD97706);

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final mono = TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.35, color: colors.foreground);

    if (entry.level == LogLevel.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          entry.message,
          style: theme.typography.body.xs.copyWith(
            color: colors.mutedForeground,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final accent = switch (entry.level) {
      LogLevel.error => colors.destructive,
      LogLevel.warn => _warn,
      _ => null,
    };

    return Container(
      decoration: BoxDecoration(
        color: accent?.withValues(alpha: 0.10),
        border: accent == null ? null : Border(left: BorderSide(color: accent, width: 3)),
      ),
      padding: EdgeInsets.fromLTRB(accent == null ? 12 : 9, 2, 12, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              entry.time?.replaceAll('s', '') ?? '',
              style: mono.copyWith(fontSize: 10.5, color: colors.mutedForeground),
            ),
          ),
          Expanded(
            child: Text(
              entry.message,
              style: mono.copyWith(
                color: switch (entry.level) {
                  LogLevel.trace || LogLevel.debug => colors.mutedForeground,
                  _ => accent ?? colors.foreground,
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
