import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/format.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../core/ui/empty_state.dart';
import '../../../core/ui/action_menu.dart';
import '../../../core/ui/popups.dart';
import '../application/browser_path.dart';
import '../application/files_providers.dart';
import '../data/file_service.dart';

/// Browse and manage one instance's directory: fixed breadcrumbs above a
/// scrolling list.
class FileBrowser extends ConsumerStatefulWidget {
  const FileBrowser({super.key, required this.instanceId});

  final String instanceId;

  @override
  ConsumerState<FileBrowser> createState() => _FileBrowserState();
}

class _FileBrowserState extends ConsumerState<FileBrowser> {
  List<String> get _segments => ref.read(browserPathProvider(widget.instanceId));
  String get _path => _segments.join('/');
  FileService get _service => ref.read(fileServiceProvider(widget.instanceId));

  void _open(List<String> segments) =>
      ref.read(browserPathProvider(widget.instanceId).notifier).open(segments);

  void _refresh() => ref.invalidate(directoryListingProvider(widget.instanceId, _path));

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      _refresh();
    } catch (e) {
      if (mounted) {
        showFToast(
          context: context,
          variant: FToastVariant.destructive,
          title: Text('$e'.replaceFirst(RegExp(r'^\w*Exception: |^Invalid argument\(s\): '), '')),
        );
      }
    }
  }

  Future<void> _create({required bool directory}) async {
    final name = await showPromptDialog(
      context,
      title: directory ? 'New folder' : 'New file',
      label: 'Name',
      confirmLabel: 'Create',
      validate: FileService.validateName,
    );
    if (name == null) return;
    await _run(() => directory
        ? _service.createDirectory(_path, name)
        : _service.createFile(_path, name));
  }

  List<MenuAction> _actionsFor(FileEntry entry) => [
        MenuAction('Rename', FLucideIcons.pencil, () async {
          final name = await showPromptDialog(
            context,
            title: 'Rename',
            label: 'Name',
            confirmLabel: 'Rename',
            initial: entry.name,
            validate: FileService.validateName,
          );
          if (name != null && name != entry.name) {
            await _run(() => _service.rename(entry, name));
          }
        }),
        MenuAction('Delete', FLucideIcons.trash2, () async {
          final ok = await showConfirmDialog(
            context,
            title: 'Delete "${entry.name}"?',
            message: entry.isDirectory
                ? 'The folder and everything in it will be deleted.'
                : 'This file will be deleted.',
            confirmLabel: 'Delete',
            destructive: true,
          );
          if (ok) await _run(() => _service.delete(entry));
        }, destructive: true),
      ];

  Future<void> _openEntry(FileEntry entry) async {
    if (entry.isDirectory) {
      _open(entry.path.split('/'));
    } else {
      await context.push(AppRoutes.file(widget.instanceId, entry.path));
      _refresh(); // size/modified may have changed
    }
  }

  @override
  Widget build(BuildContext context) {
    final segments = ref.watch(browserPathProvider(widget.instanceId));
    final listing = ref.watch(directoryListingProvider(widget.instanceId, segments.join('/')));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Breadcrumbs(
          segments: segments,
          onNavigate: _open,
          addActions: [
            MenuAction('New file', FLucideIcons.filePlus, () => _create(directory: false)),
            MenuAction('New folder', FLucideIcons.folderPlus, () => _create(directory: true)),
          ],
        ),
        Expanded(
          child: listing.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (e, _) => EmptyState(icon: FLucideIcons.triangleAlert, message: '$e'),
            data: (entries) => ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              children: [
                if (segments.isNotEmpty)
                  _Row(
                    icon: FLucideIcons.cornerLeftUp,
                    title: '..',
                    subtitle: 'Up one level',
                    onPress: () => _open(segments.sublist(0, segments.length - 1)),
                  ),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: EmptyState(
                      icon: FLucideIcons.folderOpen,
                      message: segments.isEmpty
                          ? 'Nothing here yet.\nStart the server once to generate its files.'
                          : 'This folder is empty.',
                    ),
                  ),
                for (final e in entries)
                  _Row(
                    icon: e.isDirectory ? FLucideIcons.folder : _iconFor(e),
                    title: e.name,
                    subtitle: e.isDirectory
                        ? formatDate(e.modified)
                        : '${formatBytes(e.size)} · ${formatDate(e.modified)}',
                    onPress: () => _openEntry(e),
                    actions: _actionsFor(e),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconFor(FileEntry e) => switch (e.extension) {
        'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' => FLucideIcons.image,
        'toml' || 'json' || 'json5' || 'yml' || 'yaml' || 'properties' => FLucideIcons.fileCog,
        'log' || 'txt' || 'md' => FLucideIcons.fileText,
        _ => FLucideIcons.file,
      };
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPress,
    this.actions,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPress;
  final List<MenuAction>? actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FTile(
        prefix: Icon(icon),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
        suffix: actions == null
            ? null
            : ActionMenu(
                actions: actions!,
                builder: (context, toggle) => FButton.icon(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  onPress: toggle,
                  child: const Icon(FLucideIcons.ellipsisVertical),
                ),
              ),
        onPress: onPress,
      ),
    );
  }
}

class _Breadcrumbs extends StatefulWidget {
  const _Breadcrumbs({required this.segments, required this.onNavigate, required this.addActions});

  final List<String> segments;
  final ValueChanged<List<String>> onNavigate;
  final List<MenuAction> addActions;

  @override
  State<_Breadcrumbs> createState() => _BreadcrumbsState();
}

class _BreadcrumbsState extends State<_Breadcrumbs> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(_Breadcrumbs old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.theme.colors.mutedForeground;
    final segments = widget.segments;

    Widget crumb(String label, int depth) {
      final last = depth == segments.length;
      return FButton(
        size: FButtonSizeVariant.xs,
        variant: last ? FButtonVariant.secondary : FButtonVariant.ghost,
        mainAxisSize: MainAxisSize.min,
        onPress: last ? null : () => widget.onNavigate(segments.sublist(0, depth)),
        child: Text(label),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  crumb('Files', 0),
                  for (var i = 0; i < segments.length; i++) ...[
                    Icon(FLucideIcons.chevronRight, size: 14, color: muted),
                    crumb(segments[i], i + 1),
                  ],
                ],
              ),
            ),
          ),
          ActionMenu(
            actions: widget.addActions,
            builder: (context, toggle) => FButton.icon(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              onPress: toggle,
              child: const Icon(FLucideIcons.plus),
            ),
          ),
        ],
      ),
    );
  }
}
