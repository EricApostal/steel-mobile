import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../server/data/network_addresses.dart';
import 'instances_controller.dart';

part 'network_providers.g.dart';

/// Addresses other devices can connect to. Re-read by invalidating.
@riverpod
Future<List<NetworkAddress>> networkAddresses(Ref ref) => loadNetworkAddresses();

/// The port the instance actually listens on: `server_port` from its
/// `config/config.toml` once that exists, else the port assigned at creation.
/// Invalidate after the config changes.
@riverpod
int instancePort(Ref ref, String instanceId) {
  final instance = ref.watch(instanceProvider(instanceId));
  final fallback = instance?.port ?? 25565;
  final file = ref.watch(instanceStoreProvider).dirFor(instanceId).uri.resolve('config/config.toml');
  try {
    final text = File.fromUri(file).readAsStringSync();
    final match = RegExp(r'^server_port\s*=\s*(\d+)', multiLine: true).firstMatch(text);
    return int.tryParse(match?.group(1) ?? '') ?? fallback;
  } catch (_) {
    return fallback;
  }
}
