import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/ui/sheets.dart';
import '../../files/ui/file_browser.dart';
import '../../server/application/server_controller.dart';
import '../../server/ui/console_view.dart';
import '../application/instances_controller.dart';
import '../application/network_providers.dart';
import 'instance_bottom_bar.dart';
import 'instance_form_sheet.dart';
import 'instances_page.dart';

/// One instance: status, address, and a Console/Files switcher. Everything
/// above the bottom bar is a single scroll view.
class InstancePage extends ConsumerStatefulWidget {
  const InstancePage({super.key, required this.instanceId});

  final String instanceId;

  @override
  ConsumerState<InstancePage> createState() => _InstancePageState();
}

class _InstancePageState extends ConsumerState<InstancePage> {
  final _scroll = ScrollController();
  var _tab = 0;

  /// Whether new log output should keep the view pinned to the bottom. True
  /// once the user is at (or has been taken to) the end of the log.
  var _following = false;

  String get _id => widget.instanceId;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients) _following = _scroll.position.extentAfter < 80;
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _followOutput() {
    _following = true;
    _jumpToEnd();
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
    final instance = ref.watch(instanceProvider(_id));
    if (instance == null) {
      return const FScaffold(child: SizedBox.shrink()); // deleted
    }

    ref.listen(serverControllerProvider(_id).select((s) => s.entries), (_, _) {
      if (_tab == 0 && _following) _jumpToEnd();
    });

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(instance.name),
        prefixes: [FHeaderAction.back(onPress: () => Navigator.of(context).pop())],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.ellipsisVertical),
            onPress: _showMenu,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(child: _InfoHeader(instanceId: _id)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _TabSwitcher(
                      index: _tab,
                      onChange: (i) => setState(() => _tab = i),
                    ),
                  ),
                ),
                if (_tab == 0)
                  ConsoleSliver(instanceId: _id)
                else
                  FileBrowserSliver(instanceId: _id),
              ],
            ),
          ),
          InstanceBottomBar(
            instanceId: _id,
            showCommands: _tab == 0,
            onOutputExpected: () {
              if (_tab == 0) _followOutput();
            },
          ),
        ],
      ),
    );
  }

  void _showMenu() {
    final instance = ref.read(instanceProvider(_id));
    if (instance == null) return;
    showActionSheet(
      context,
      title: instance.name,
      actions: [
        SheetAction('Edit', FLucideIcons.pencil, () async {
          await showInstanceFormSheet(context, editing: instance);
        }),
        SheetAction('Delete', FLucideIcons.trash2, () async {
          final ok = await showConfirmSheet(
            context,
            title: 'Delete "${instance.name}"?',
            message: 'This permanently deletes its worlds and config.',
            confirmLabel: 'Delete',
            destructive: true,
          );
          if (!ok || !mounted) return;
          Navigator.of(context).pop();
          ref.invalidate(serverControllerProvider(_id)); // kills the process
          await ref.read(instancesControllerProvider.notifier).remove(_id);
        }, destructive: true),
      ],
    );
  }
}

/// Console | Files switcher.
class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.index, required this.onChange});

  final int index;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return FTabs(
      control: FTabControl.lifted(index: index, onChange: onChange),
      children: const [
        FTabEntry(label: Text('Console'), child: SizedBox.shrink()),
        FTabEntry(label: Text('Files'), child: SizedBox.shrink()),
      ],
    );
  }
}

class _InfoHeader extends ConsumerWidget {
  const _InfoHeader({required this.instanceId});

  final String instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instance = ref.watch(instanceProvider(instanceId));
    if (instance == null) return const SizedBox.shrink();

    final theme = context.theme;
    final status = ref.watch(serverControllerProvider(instanceId).select((s) => s.status));
    final port = ref.watch(instancePortProvider(instanceId));
    final mc = instance.version.minecraft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              StatusBadge(status: status),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  [
                    'Steel ${instance.version.steel}',
                    if (mc != null) 'Minecraft $mc',
                  ].join(' · '),
                  style: theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground),
                ),
              ),
            ],
          ),
        ),
        _ConnectRow(port: port),
      ],
    );
  }
}

/// Shows the address other devices connect to; tap to copy.
class _ConnectRow extends ConsumerWidget {
  const _ConnectRow({required this.port});

  final int port;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final addresses = ref.watch(networkAddressesProvider);
    final muted = theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground);

    Future<void> copy(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        showFToast(context: context, title: Text('Copied $text'));
      }
    }

    Widget row({
      required IconData icon,
      required Widget content,
      VoidCallback? onTap,
      Widget? trailing,
    }) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: FTappable(
          onPress: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: theme.colors.mutedForeground),
                  const SizedBox(width: 10),
                  Expanded(child: content),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      );
    }

    return addresses.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) {
          return row(
            icon: FLucideIcons.wifiOff,
            onTap: () => ref.invalidate(networkAddressesProvider),
            content: Text('Not on a network · Port $port', style: muted),
            trailing: Icon(FLucideIcons.refreshCw, size: 16, color: theme.colors.mutedForeground),
          );
        }
        final best = list.first;
        final address = '${best.ip}:$port';
        return row(
          icon: FLucideIcons.wifi,
          onTap: list.length == 1
              ? () => copy(address)
              : () => showActionSheet(
                    context,
                    title: 'Connect using',
                    actions: [
                      for (final a in list)
                        SheetAction(
                          '${a.ip}:$port  ·  ${a.label}',
                          FLucideIcons.copy,
                          () => copy('${a.ip}:$port'),
                        ),
                    ],
                  ),
          content: Row(
            children: [
              Text(
                address,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              const SizedBox(width: 8),
              Text(best.label, style: muted),
            ],
          ),
          trailing: Icon(
            list.length == 1 ? FLucideIcons.copy : FLucideIcons.chevronDown,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
        );
      },
    );
  }
}
