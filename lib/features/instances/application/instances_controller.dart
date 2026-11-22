import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../data/instance.dart';
import '../data/instance_store.dart';

part 'instances_controller.g.dart';

@Riverpod(keepAlive: true)
InstanceStore instanceStore(Ref ref) => InstanceStore(ref.watch(appDirProvider));

@Riverpod(keepAlive: true)
class InstancesController extends _$InstancesController {
  static const _firstPort = 25565;

  @override
  List<Instance> build() => ref.read(instanceStoreProvider).load();

  Future<Instance> create({required String name, required String versionTag}) async {
    final taken = {for (final i in state) i.port};
    var port = _firstPort;
    while (taken.contains(port)) {
      port++;
    }

    final instance = Instance(
      id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      name: name.trim(),
      versionTag: versionTag,
      port: port,
      createdAt: DateTime.now(),
    );
    final store = ref.read(instanceStoreProvider);
    await store.createDir(instance.id);
    await _persist([...state, instance]);
    return instance;
  }

  Future<void> update(Instance instance) =>
      _persist([for (final i in state) i.id == instance.id ? instance : i]);

  Future<void> remove(String id) async {
    await _persist([...state.where((i) => i.id != id)]);
    await ref.read(instanceStoreProvider).deleteData(id);
  }

  Future<void> _persist(List<Instance> next) async {
    state = next;
    await ref.read(instanceStoreProvider).save(next);
  }
}

@riverpod
Instance? instance(Ref ref, String id) => ref.watch(
      instancesControllerProvider.select(
        (list) => list.where((i) => i.id == id).firstOrNull,
      ),
    );
