import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../core/platform/binary_launcher.dart';

/// Starts Steel binaries using the host's [BinaryLauncher].
class SteelRunner {
  const SteelRunner(this._launcher);

  final BinaryLauncher _launcher;

  Future<SteelProcess> start(
    File binary, {
    List<String> args = const [],
    required Directory workingDirectory,
  }) async {
    await workingDirectory.create(recursive: true);
    await _launcher.prepare(binary);
    final command = _launcher.command(binary, args);
    final process = await Process.start(
      command.executable,
      command.arguments,
      workingDirectory: workingDirectory.path,
      environment: {'HOME': workingDirectory.path},
    );
    return SteelProcess(process);
  }
}

class SteelProcess {
  SteelProcess(this._process) : lines = _mergeLines(_process);

  final Process _process;

  /// stdout and stderr, line by line, ANSI colors removed.
  final Stream<String> lines;

  Future<int> get exitCode => _process.exitCode;

  /// Sends a line to the server's console (stdin).
  Future<void> writeLine(String line) async {
    _process.stdin.writeln(line);
    await _process.stdin.flush();
  }

  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) =>
      _process.kill(signal);

  static final _ansi = RegExp(r'\x1B\[[0-9;]*[A-Za-z]');

  static Stream<String> _mergeLines(Process p) {
    final out = StreamController<String>();
    var open = 2;
    void closeOne() {
      if (--open == 0) out.close();
    }

    for (final s in [p.stdout, p.stderr]) {
      s
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter())
          .listen(
            (l) => out.add(l.replaceAll(_ansi, '')),
            onDone: closeOne,
          );
    }
    return out.stream;
  }
}
