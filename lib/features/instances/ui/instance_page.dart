import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../core/ui/header_title.dart';
import '../../../core/ui/layout.dart';
import '../../files/ui/file_browser.dart';
import '../../server/application/server_controller.dart';
import '../../server/ui/console_view.dart';
import '../application/instances_controller.dart';
import 'instance_bottom_bar.dart';
import 'instance_header_actions.dart';

/// One instance. On a phone: tabs (Console | Files) under a header with
/// Start/Stop. On desktop: the console and the files side by side.
class InstancePage extends ConsumerStatefulWidget {
  const InstancePage({super.key, required this.instanceId});

  final String instanceId;

  @override
  ConsumerState<InstancePage> createState() => _InstancePageState();
}

class _InstancePageState extends ConsumerState<InstancePage> {
  /// Width of the files pane in the desktop layout.
  static const _filesPaneWidth = 380.0;

  var _tab = 0;

  String get _id => widget.instanceId;

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(instanceProvider(_id).select((i) => i?.name));
    if (name == null) {
      return const FScaffold(child: SizedBox.shrink()); // deleted
    }

    final desktop = isDesktopWidth(context);

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        titleAlignment: Alignment.centerLeft,
        title: _InstanceTitle(instanceId: _id),
        // On desktop the sidebar is the way back.
        prefixes: [
          if (!desktop) FHeaderAction.back(onPress: () => context.go(AppRoutes.instances)),
        ],
        suffixes: [
          StartStopButton(instanceId: _id),
          const SizedBox(width: 4),
          InstanceMenu(instanceId: _id),
        ],
      ),
      child: desktop ? _desktopBody(context) : _phoneBody(),
    );
  }

  Widget _phoneBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: FTabs(
            style: .delta(spacing: 0),
            control: FTabControl.lifted(index: _tab, onChange: (i) => setState(() => _tab = i)),
            children: const [
              FTabEntry(label: Text('Console'), child: SizedBox.shrink()),
              FTabEntry(label: Text('Files'), child: SizedBox.shrink()),
            ],
          ),
        ),
        Expanded(
          child: _tab == 0 ? ConsoleView(instanceId: _id) : FileBrowser(instanceId: _id),
        ),
        InstanceBottomBar(instanceId: _id, showCommands: _tab == 0),
      ],
    );
  }

  Widget _desktopBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: ConsoleView(instanceId: _id)),
              InstanceBottomBar(instanceId: _id, showCommands: true),
            ],
          ),
        ),
        ColoredBox(
          color: context.theme.colors.border,
          child: const SizedBox(width: 1),
        ),
        SizedBox(width: _filesPaneWidth, child: FileBrowser(instanceId: _id)),
      ],
    );
  }
}

/// Name, with status and versions as the secondary line.
class _InstanceTitle extends ConsumerWidget {
  const _InstanceTitle({required this.instanceId});

  final String instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instance = ref.watch(instanceProvider(instanceId));
    final status = ref.watch(serverControllerProvider(instanceId).select((s) => s.status));
    if (instance == null) return const SizedBox.shrink();

    final mc = instance.version.minecraft;
    return HeaderTitle(
      title: instance.name,
      subtitle: [
        switch (status) {
          ServerStatus.idle => 'Stopped',
          ServerStatus.starting => 'Starting…',
          ServerStatus.running => 'Running',
          ServerStatus.stopping => 'Stopping…',
        },
        instance.version.steel,
        if (mc != null) 'MC $mc',
      ].join(' · '),
    );
  }
}
