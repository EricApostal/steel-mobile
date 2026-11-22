import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/ui/sheets.dart';
import '../application/console_filter.dart';
import '../application/server_controller.dart';
import '../data/log_entry.dart';

/// The log as slivers, so it scrolls together with the rest of the page:
/// a filter bar, then one color-coded row per entry.
class ConsoleSliver extends ConsumerWidget {
  const ConsoleSliver({super.key, required this.instanceId});

  final String instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final entries = ref.watch(serverControllerProvider(instanceId).select((s) => s.entries));
    final filter = ref.watch(consoleFilterControllerProvider(instanceId));
    final visible = entries.where(filter.accepts).toList();
    final background = theme.colors.secondary;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _FilterBar(instanceId: instanceId, entries: entries)),
        SliverToBoxAdapter(
          child: ColoredBox(color: background, child: const SizedBox(height: 6, width: double.infinity)),
        ),
        if (visible.isEmpty)
          SliverToBoxAdapter(
            child: ColoredBox(
              color: background,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    entries.isEmpty ? 'No output yet.' : 'Nothing matches this filter.',
                    style: theme.typography.body.sm.copyWith(color: theme.colors.mutedForeground),
                  ),
                ),
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: visible.length,
            itemBuilder: (_, i) => ColoredBox(color: background, child: _LogRow(entry: visible[i])),
          ),
        // Keeps the panel filling the screen when the log is short.
        SliverFillRemaining(hasScrollBody: false, child: ColoredBox(color: background)),
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
  const CommandField({super.key, required this.instanceId, required this.onSent});

  final String instanceId;
  final VoidCallback onSent;

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
    widget.onSent();
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
