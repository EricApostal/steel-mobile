import 'dart:io';

/// The process to spawn in order to run a binary.
class LaunchCommand {
  const LaunchCommand(this.executable, this.arguments);

  final String executable;
  final List<String> arguments;
}

/// How to run a downloaded Steel binary on this host. Each platform that
/// can't just `exec` the file supplies its own strategy.
abstract interface class BinaryLauncher {
  /// Makes [binary] runnable. Idempotent; called before every launch.
  Future<void> prepare(File binary);

  /// What to spawn to run [binary] with [args].
  LaunchCommand command(File binary, List<String> args);
}

/// Android: app storage is mounted so `execve()` on files there is denied, but
/// the system linker is executable and maps any readable PIE, so we run
/// `linker64 /abs/path/to/binary` (the approach termux-exec takes). The
/// binary needs no exec bit.
class LinkerLauncher implements BinaryLauncher {
  const LinkerLauncher({this.linker = '/system/bin/linker64'});

  final String linker;

  @override
  Future<void> prepare(File binary) async {}

  @override
  LaunchCommand command(File binary, List<String> args) =>
      LaunchCommand(linker, [binary.absolute.path, ...args]); // must be absolute
}

/// Desktop: run the file itself, after giving it the exec bit.
class DirectLauncher implements BinaryLauncher {
  const DirectLauncher({this.makeExecutable = true, this.clearQuarantine = false});

  /// `chmod u+x` first. Not needed on Windows.
  final bool makeExecutable;

  /// Drop macOS's quarantine flag so Gatekeeper doesn't block the binary.
  final bool clearQuarantine;

  @override
  Future<void> prepare(File binary) async {
    if (makeExecutable) {
      final result = await Process.run('chmod', ['u+x', binary.path]);
      if (result.exitCode != 0) {
        throw FileSystemException('chmod failed: ${result.stderr}', binary.path);
      }
    }
    if (clearQuarantine) {
      // Fails harmlessly when the attribute isn't there.
      await Process.run('xattr', ['-d', 'com.apple.quarantine', binary.path]);
    }
  }

  @override
  LaunchCommand command(File binary, List<String> args) =>
      LaunchCommand(binary.absolute.path, args);
}
