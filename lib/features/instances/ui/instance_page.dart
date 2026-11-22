import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../files/ui/file_browser.dart';
import '../../server/ui/console_view.dart';
import '../application/instances_controller.dart';
import 'instance_bottom_bar.dart';
import 'instance_header_actions.dart';

/// One instance. Fixed chrome (header with Start/Stop, tabs, command bar)
/// around a single scrolling area: the log, or the file list.
class InstancePage extends ConsumerStatefulWidget {
  const InstancePage({super.key, required this.instanceId});

  final String instanceId;

  @override
  ConsumerState<InstancePage> createState() => _InstancePageState();
}

class _InstancePageState extends ConsumerState<InstancePage> {
  var _tab = 0;

  String get _id => widget.instanceId;

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(instanceProvider(_id).select((i) => i?.name));
    if (name == null) {
      return const FScaffold(child: SizedBox.shrink()); // deleted
    }

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(name, overflow: TextOverflow.ellipsis),
        prefixes: [FHeaderAction.back(onPress: () => Navigator.of(context).pop())],
        suffixes: [
          StartStopButton(instanceId: _id),
          const SizedBox(width: 4),
          InstanceMenu(instanceId: _id),
        ],
      ),
      child: Column(
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
            child: _tab == 0
                ? ConsoleView(instanceId: _id)
                : FileBrowser(instanceId: _id),
          ),
          InstanceBottomBar(instanceId: _id, showCommands: _tab == 0),
        ],
      ),
    );
  }
}
