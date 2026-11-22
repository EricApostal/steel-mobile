import 'dart:async';
import 'dart:io';

import 'steel_runner.dart';

/// Gives each instance its own port.
///
/// Steel needs a complete `config/config.toml` (a partial one is rejected), so
/// on an instance's first start we let Steel generate its defaults, stop it
/// as soon as they exist, then patch `server_port`.
class ConfigBootstrap {
  const ConfigBootstrap(this._runner);

  final SteelRunner _runner;

  static const _generated = ['config.toml', 'worlds.toml', 'groups.toml'];

  Future<void> ensurePort({
    required File binary,
    required Directory dir,
    required int port,
  }) async {
    final config = File('${dir.path}/config/config.toml');
    if (!await config.exists()) await _generateDefaults(binary, dir);
    if (!await config.exists()) {
      throw StateError('Steel did not generate config/config.toml');
    }

    final text = await config.readAsString();
    final patched = text.replaceFirst(
      RegExp(r'^server_port\s*=\s*\d+', multiLine: true),
      'server_port = $port',
    );
    if (patched != text) await config.writeAsString(patched, flush: true);
  }

  Future<void> _generateDefaults(File binary, Directory dir) async {
    final process = await _runner.start(binary, workingDirectory: dir);
    process.lines.listen((_) {}); // drain so the pipes don't fill

    var exited = false;
    unawaited(process.exitCode.then((_) => exited = true));

    bool ready() =>
        _generated.every((f) => File('${dir.path}/config/$f').existsSync());

    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (!ready() && !exited && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    // Let Steel finish writing before we kill it.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    process.kill(ProcessSignal.sigkill);
    await process.exitCode;
  }
}
