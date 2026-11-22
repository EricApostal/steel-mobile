import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Runs a binary that is NOT executable, using the same approach as
/// termux-exec: Android forbids `execve()` on files in app data, but the system
/// dynamic linker is executable and can map any readable ELF, so we run
/// `linker64 /abs/path/to/binary` instead. The binary must be a PIE.
class SteelRunner {
  const SteelRunner();

  static const linker = '/system/bin/linker64';

  Future<SteelProcess> start(
    File binary, {
    List<String> args = const [],
    required Directory workingDirectory,
  }) async {
    await workingDirectory.create(recursive: true);
    final process = await Process.start(
      linker,
      [binary.absolute.path, ...args], // linker64 requires an absolute path
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
