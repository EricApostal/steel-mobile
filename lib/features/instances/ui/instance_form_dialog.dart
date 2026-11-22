import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/format.dart';
import '../../../core/ui/popups.dart';
import '../../releases/application/install_controller.dart';
import '../../releases/application/releases_providers.dart';
import '../../releases/data/steel_build.dart';
import '../../server/application/server_controller.dart';
import '../application/instances_controller.dart';
import '../data/instance.dart';

/// Create a new instance, or edit [editing]. Resolves to the saved instance.
Future<Instance?> showInstanceFormDialog(BuildContext context, {Instance? editing}) {
  return showPopup<Instance>(
    context,
    builder: (context, style) => _InstanceForm(style: style, editing: editing),
  );
}

class _InstanceForm extends ConsumerStatefulWidget {
  const _InstanceForm({required this.style, this.editing});

  final FDialogStyle style;
  final Instance? editing;

  @override
  ConsumerState<_InstanceForm> createState() => _InstanceFormState();
}

class _InstanceFormState extends ConsumerState<_InstanceForm> {
  late final _name = TextEditingController(text: widget.editing?.name ?? '');
  late String? _tag = widget.editing?.versionTag;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save(List<SteelBuild> builds) async {
    final tag = _tag;
    if (tag == null) return;
    setState(() => _saving = true);

    final controller = ref.read(instancesControllerProvider.notifier);
    final editing = widget.editing;
    final Instance saved;
    if (editing == null) {
      saved = await controller.create(name: _name.text, versionTag: tag);
    } else {
      saved = editing.copyWith(name: _name.text.trim(), versionTag: tag);
      await controller.update(saved);
    }

    // Start downloading the chosen version if it isn't on the device yet.
    final installed = ref.read(installedTagsProvider);
    if (!installed.contains(tag)) {
      final build = builds.where((b) => b.tag == tag).firstOrNull;
      if (build != null) {
        ref.read(installControllerProvider(build).notifier).install();
      }
    }
    if (mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final builds = ref.watch(buildsProvider);
    final installed = ref.watch(installedTagsProvider);
    final running = widget.editing != null &&
        ref.watch(
          serverControllerProvider(widget.editing!.id).select((s) => s.isActive),
        );

    final canSave = !_saving && _tag != null && _name.text.trim().isNotEmpty;

    return PopupFrame(
      style: widget.style,
      title: widget.editing == null ? 'New instance' : 'Edit instance',
      actions: [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FButton(
          onPress: canSave ? () => _save(builds.value ?? const []) : null,
          child: Text(widget.editing == null ? 'Create' : 'Save'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FTextField(
            control: FTextFieldControl.managed(controller: _name),
            label: const Text('Name'),
            hint: 'My server',
            autofocus: widget.editing == null,
          ),
          const SizedBox(height: 16),
          Text('Steel version', style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          if (running)
            Text(
              'Stop the server to change its version.',
              style: theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground),
            ),
          builds.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: FCircularProgress()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('$e', style: TextStyle(color: theme.colors.destructive)),
            ),
            data: (items) => items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No compatible versions available.'),
                  )
                : FTileGroup(
                    maxHeight: 240,
                    children: [
                      for (final b in items)
                        FTile(
                          enabled: !running,
                          selected: _tag == b.tag,
                          prefix: Icon(
                            _tag == b.tag ? FLucideIcons.circleCheck : FLucideIcons.circle,
                          ),
                          title: Text('Steel ${b.version}'),
                          subtitle: Text([
                            if (b.minecraftVersion != null) 'Minecraft ${b.minecraftVersion}',
                            installed.contains(b.tag) ? 'Downloaded' : formatBytes(b.size),
                          ].join(' · ')),
                          onPress: () => setState(() => _tag = b.tag),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
