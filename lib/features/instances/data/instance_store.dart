import 'dart:convert';
import 'dart:io';

import 'instance.dart';

/// Persists the instance list (`instances.json`) and owns each instance's
/// data directory (`instances/<id>/`).
class InstanceStore {
  const InstanceStore(this._root);

  final Directory _root;

  File get _index => File('${_root.path}/instances.json');

  Directory dirFor(String id) => Directory('${_root.path}/instances/$id');

  List<Instance> load() {
    if (!_index.existsSync()) return const [];
    try {
      final list = jsonDecode(_index.readAsStringSync()) as List<dynamic>;
      return [for (final m in list) Instance.fromMap(m as Map<String, dynamic>)];
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<Instance> instances) async {
    await _root.create(recursive: true);
    final tmp = File('${_index.path}.tmp');
    await tmp.writeAsString(
      jsonEncode([for (final i in instances) i.toMap()]),
      flush: true,
    );
    await tmp.rename(_index.path);
  }

  Future<void> createDir(String id) => dirFor(id).create(recursive: true);

  Future<void> deleteData(String id) async {
    final dir = dirFor(id);
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
