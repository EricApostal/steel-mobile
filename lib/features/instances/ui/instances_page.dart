import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/navigation.dart';
import '../../../core/ui/empty_state.dart';
import '../../server/application/server_controller.dart';
import '../application/instances_controller.dart';
import '../application/network_providers.dart';
import '../data/instance.dart';
import 'instance_form_dialog.dart';
import 'instance_page.dart';

/// Opens the create dialog and, on success, the new instance.
Future<void> createInstance(BuildContext context) async {
  final created = await showInstanceFormDialog(context);
  if (created != null && context.mounted) {
    await pushPage<void>(context, (_) => InstancePage(instanceId: created.id));
  }
}

class InstancesPage extends ConsumerWidget {
  const InstancesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instances = ref.watch(instancesControllerProvider);

    if (instances.isEmpty) {
      return EmptyState(
        icon: FLucideIcons.server,
        message: 'No instances yet.\nCreate one to run your own Steel server.',
        action: FButton(
          onPress: () => createInstance(context),
          prefix: const Icon(FLucideIcons.plus),
          child: const Text('New instance'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: instances.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _InstanceTile(instance: instances[i]),
    );
  }
}

class _InstanceTile extends ConsumerWidget {
  const _InstanceTile({required this.instance});

  final Instance instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      serverControllerProvider(instance.id).select((s) => s.status),
    );
    final mc = instance.version.minecraft;
    final port = ref.watch(instancePortProvider(instance.id));

    return FTile(
      prefix: const Icon(FLucideIcons.server),
      title: Text(instance.name),
      subtitle: Text([
        'Steel ${instance.version.steel}',
        if (mc != null) 'MC $mc',
        ':$port',
      ].join(' · ')),
      details: StatusBadge(status: status),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => pushPage<void>(context, (_) => InstancePage(instanceId: instance.id)),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ServerStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ServerStatus.running => FBadge(child: const Text('Running')),
      ServerStatus.starting => FBadge(variant: FBadgeVariant.secondary, child: const Text('Starting…')),
      ServerStatus.stopping => FBadge(variant: FBadgeVariant.secondary, child: const Text('Stopping…')),
      ServerStatus.idle => FBadge(variant: FBadgeVariant.outline, child: const Text('Stopped')),
    };
  }
}
