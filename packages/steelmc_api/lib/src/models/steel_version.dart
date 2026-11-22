/// A parsed release tag such as `v0.17.1+mc26.3`.
class SteelVersion {
  const SteelVersion(this.steel, this.minecraft);

  /// Steel's own version, e.g. `0.17.1`.
  final String steel;

  /// The Minecraft version this build targets, e.g. `26.3`.
  final String? minecraft;

  static final _tag = RegExp(r'^v?([^+]+)(?:\+mc(.+))?$');

  factory SteelVersion.parse(String tag) {
    final m = _tag.firstMatch(tag);
    return SteelVersion(m?.group(1) ?? tag, m?.group(2));
  }
}
