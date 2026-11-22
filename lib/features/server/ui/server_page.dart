import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../application/server_controller.dart';
import 'log_view.dart';

class ServerPage extends ConsumerWidget {
  const ServerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverControllerProvider);
    final controller = ref.read(serverControllerProvider.notifier);
    final build = server.build;

    return Scaffold(
      appBar: AppBar(
        title: Text(build == null ? 'Server' : 'Steel ${build.version}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(label: Text(switch (server.status) {
              ServerStatus.idle => 'Stopped',
              ServerStatus.running => 'Running',
              ServerStatus.stopping => 'Stopping…',
            })),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: LogView(lines: server.lines)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: switch (server.status) {
                  ServerStatus.idle => FilledButton.icon(
                      onPressed:
                          build == null ? null : () => controller.start(build),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    ),
                  ServerStatus.running => FilledButton.tonalIcon(
                      onPressed: controller.stop,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                  ServerStatus.stopping => const FilledButton(
                      onPressed: null,
                      child: Text('Stopping…'),
                    ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
