import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/ui/sheets.dart';
import '../application/console_filter.dart';
import '../application/server_controller.dart';
import '../data/log_entry.dart';

/// The log: a filter bar above a scrolling, color-coded list. The list follows
/// new output until you scroll up, and starts at the newest line.
class ConsoleView extends ConsumerStatefulWidget {
  const ConsoleView({super.key, required this.instanceId});

  final String instanceId;

  @override
  ConsumerState<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends ConsumerState<ConsoleView> {
  final _scroll = ScrollController();
  var _following = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients) _following = _scroll.position.extentAfter < 80;
    });
    _jumpToEnd();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToEnd() {
    // Twice: list extents are estimated until the new rows have been laid out.
    for (var i = 0; i < 2; i++) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final id = widget.instanceId;
    final entries = ref.watch(serverControllerProvider(id).select((s) => s.entries));
    final filter = ref.watch(consoleFilterControllerProvider(id));
    final visible = entries.where(filter.accepts).toList();

    ref.listen(serverControllerProvider(id).select((s) => s.entries), (prev, next) {
      // A restart (log cleared) or a command you just sent: show the newest.
      final cleared = prev != null && next.length < prev.length;
      final sentCommand = next.isNotEmpty &&
          next.last.level == LogLevel.command &&
          (prev == null || prev.isEmpty || prev.last.id != next.last.id);
      if (cleared || sentCommand) _following = true;
      if (_following) _jumpToEnd();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterBar(instanceId: id, entries: entries),
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
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.instanceId, required this.entries});

  final String instanceId;
  final List<LogEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(consoleFilterControllerProvider(instanceId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
      child: Row(
        children: [
          for (final f in ConsoleFilter.values) ...[
            FButton(
              size: FButtonSizeVariant.xs,
              variant: filter == f ? FButtonVariant.secondary : FButtonVariant.ghost,
              mainAxisSize: MainAxisSize.min,
              onPress: () => ref.read(consoleFilterControllerProvider(instanceId).notifier).select(f),
              child: Text(f.label),
            ),
            const SizedBox(width: 4),
          ],
          const Spacer(),
          FButton.icon(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            onPress: entries.isEmpty ? null : () => _copy(context),
            child: const Icon(FLucideIcons.copy),
          ),
          FButton.icon(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            onPress: entries.isEmpty
                ? null
                : ref.read(serverControllerProvider(instanceId).notifier).clearLog,
            child: const Icon(FLucideIcons.eraser),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final text = entries
        .map((e) =>
            '${e.time ?? ''} ${e.level == LogLevel.system ? '' : '[${e.level.name}] '}${e.message}${e.count > 1 ? '  (x${e.count})' : ''}'
                .trim())
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

    if (entry.level == LogLevel.command) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Text(
          '› ${entry.message}',
          style: mono.copyWith(color: colors.primary, fontWeight: FontWeight.w600),
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
          if (entry.count > 1)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  child: Text(
                    '×${entry.count}',
                    style: mono.copyWith(fontSize: 10.5, color: colors.mutedForeground),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Input for sending commands to the running server: history, field, send.
class CommandField extends ConsumerStatefulWidget {
  const CommandField({super.key, required this.instanceId});

  final String instanceId;

  @override
  ConsumerState<CommandField> createState() => _CommandFieldState();
}

class _CommandFieldState extends ConsumerState<CommandField> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final command = _text.text.trim();
    if (command.isEmpty) return;
    ref.read(serverControllerProvider(widget.instanceId).notifier).sendCommand(command);
    _text.clear();
    _focus.requestFocus(); // keep the keyboard up for the next command
  }

  void _showHistory(List<String> history) {
    showActionSheet(
      context,
      title: 'Recent commands',
      actions: [
        for (final c in history.take(8))
          SheetAction(c, FLucideIcons.history, () {
            _text.text = c;
            _text.selection = TextSelection.collapsed(offset: c.length);
            _focus.requestFocus();
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final server = ref.watch(serverControllerProvider(widget.instanceId));
    final running = server.status == ServerStatus.running;

    return Row(
      children: [
        FButton.icon(
          variant: FButtonVariant.ghost,
          onPress: server.history.isEmpty ? null : () => _showHistory(server.history),
          child: const Icon(FLucideIcons.history),
        ),
        Expanded(
          child: FTextField(
            control: FTextFieldControl.managed(controller: _text),
            focusNode: _focus,
            enabled: running,
            hint: running ? 'Send a command…' : 'Server is stopped',
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.send,
            onSubmit: (_) => _send(),
          ),
        ),
        const SizedBox(width: 8),
        FButton.icon(
          onPress: running && _text.text.trim().isNotEmpty ? _send : null,
          child: const Icon(FLucideIcons.send),
        ),
      ],
    );
  }
}
