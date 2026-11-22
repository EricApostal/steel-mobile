/// A platform/arch SteelMC publishes a binary for. [assetName] is the name of
/// the release asset for that target.
enum SteelTarget {
  androidAarch64('steel-android-aarch64'),
  androidX86_64('steel-android-x86_64'),
  linux('steel-linux'),
  linuxMusl('steel-linux-musl'),
  macos('steel-macos'),
  windows('steel-windows.exe');

  const SteelTarget(this.assetName);

  final String assetName;

  /// Human readable label, e.g. for showing which build will be used.
  String get label => switch (this) {
        androidAarch64 => 'Android · ARM64',
        androidX86_64 => 'Android · x86_64',
        linux => 'Linux',
        linuxMusl => 'Linux (musl)',
        macos => 'macOS',
        windows => 'Windows',
      };
}
