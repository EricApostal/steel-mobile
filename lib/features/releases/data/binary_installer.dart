import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:steelmc_api/steelmc_api.dart';

import 'binary_store.dart';
import 'steel_build.dart';

class InstallException implements Exception {
  const InstallException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Downloads a build into the [BinaryStore], verifying GitHub's sha256.
class BinaryInstaller {
  const BinaryInstaller(this._client, this._store);

  final SteelMcClient _client;
  final BinaryStore _store;

  Future<File> install(
    SteelBuild build, {
    void Function(int received, int total)? onProgress,
    void Function()? onVerifying,
    CancelToken? cancelToken,
  }) async {
    final part = _store.partFileFor(build);
    await part.parent.create(recursive: true);
    try {
      await _client.downloadAsset(
        build.asset,
        part.path,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );

      final expected = build.asset.sha256;
      if (expected != null) {
        onVerifying?.call();
        final actual = (await sha256.bind(part.openRead()).first).toString();
        if (actual != expected) {
          throw const InstallException('Checksum mismatch, download discarded.');
        }
      }

      return await part.rename(_store.fileFor(build).path);
    } catch (_) {
      if (await part.exists()) await part.delete();
      rethrow;
    }
  }
}
