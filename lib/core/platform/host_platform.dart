import 'dart:ffi' show Abi;

import 'package:steelmc_api/steelmc_api.dart';

import 'binary_launcher.dart';

/// What this host needs to run Steel: which release asset to download and how
/// to launch it.
///
/// Supporting another platform is one row in [detect] (plus a
/// [BinaryLauncher] if it can't use an existing one). A CPU with no published
/// Steel build simply isn't listed, and the app reports it as unsupported.
class HostPlatform {
  const HostPlatform({required this.target, required this.launcher});

  final SteelTarget target;
  final BinaryLauncher launcher;

  static HostPlatform? detect() => switch (Abi.current()) {
        Abi.androidArm64 => const HostPlatform(
            target: SteelTarget.androidAarch64,
            launcher: LinkerLauncher(),
          ),
        Abi.androidX64 => const HostPlatform(
            target: SteelTarget.androidX86_64,
            launcher: LinkerLauncher(),
          ),
        // `steel-macos` is an arm64 Mach-O, so Intel Macs aren't covered.
        Abi.macosArm64 => const HostPlatform(
            target: SteelTarget.macos,
            launcher: DirectLauncher(clearQuarantine: true),
          ),
        // Wired up but not yet exercised: no Linux/Windows runner project yet.
        Abi.linuxX64 => const HostPlatform(
            target: SteelTarget.linux,
            launcher: DirectLauncher(),
          ),
        Abi.windowsX64 => const HostPlatform(
            target: SteelTarget.windows,
            launcher: DirectLauncher(makeExecutable: false),
          ),
        _ => null,
      };
}
