import 'dart:io';

import 'steel_build.dart';

/// Where downloaded Steel binaries live.
///
/// Binaries are plain data files: they never get the executable bit and are
/// launched through the system linker (see `SteelRunner`). Layout:
/// `<root>/binaries/<tag>/<asset name>`.
class BinaryStore {
  const BinaryStore(this._root, this._assetName);

  final Directory _root;

  /// Name of the release asset for this device, e.g. `steel-android-aarch64`.
  final String _assetName;

  Directory get _binaries => Directory('${_root.path}/binaries');

  // Tags contain `+`, so the directory name is percent-encoded (reversible).
  Directory _dirForTag(String tag) =>
      Directory('${_binaries.path}/${Uri.encodeComponent(tag)}');

  /// Tags that have a complete binary on disk.
  Set<String> installedTags() {
    if (!_binaries.existsSync()) return {};
    return {
      for (final d in _binaries.listSync().whereType<Directory>())
        if (File('${d.path}/$_assetName').existsSync())
          Uri.decodeComponent(d.uri.pathSegments.lastWhere((s) => s.isNotEmpty)),
    };
  }

  File fileForTag(String tag) => File('${_dirForTag(tag).path}/$_assetName');

  File partFileForTag(String tag) =>
      File('${_dirForTag(tag).path}/$_assetName.part');

  bool isInstalledTag(String tag) => fileForTag(tag).existsSync();

  File fileFor(SteelBuild b) => fileForTag(b.tag);
  File partFileFor(SteelBuild b) => partFileForTag(b.tag);
  bool isInstalled(SteelBuild b) => isInstalledTag(b.tag);

  Future<void> deleteTag(String tag) async {
    final dir = _dirForTag(tag);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  Future<void> delete(SteelBuild b) => deleteTag(b.tag);
}
