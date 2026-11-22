import 'dart:io';

import 'steel_build.dart';

/// Where downloaded binaries and the server's working data live.
///
/// Binaries are plain data files: they never get the executable bit and are
/// launched through the system linker (see `SteelRunner`).
class BinaryStore {
  const BinaryStore(this._root);

  final Directory _root;

  /// Shared by every version so worlds/config survive upgrades.
  Directory get serverDir => Directory('${_root.path}/server');

  Directory _dirFor(SteelBuild b) => Directory(
        '${_root.path}/binaries/${b.tag.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')}',
      );

  File fileFor(SteelBuild b) => File('${_dirFor(b).path}/${b.asset.name}');

  File partFileFor(SteelBuild b) =>
      File('${_dirFor(b).path}/${b.asset.name}.part');

  bool isInstalled(SteelBuild b) => fileFor(b).existsSync();

  Future<void> delete(SteelBuild b) async {
    final dir = _dirFor(b);
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
