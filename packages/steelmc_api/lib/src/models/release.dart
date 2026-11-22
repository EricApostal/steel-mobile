import 'package:dart_mappable/dart_mappable.dart';

import 'release_asset.dart';
import 'steel_target.dart';
import 'steel_version.dart';

part 'release.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Release with ReleaseMappable {
  const Release({
    required this.id,
    required this.tagName,
    required this.htmlUrl,
    this.name,
    this.body,
    this.draft = false,
    this.prerelease = false,
    this.publishedAt,
    this.assets = const [],
  });

  final int id;

  /// e.g. `v0.17.1+mc26.3`
  final String tagName;
  final String? name;
  final String? body;
  final String htmlUrl;
  final bool draft;
  final bool prerelease;
  final DateTime? publishedAt;
  final List<ReleaseAsset> assets;

  SteelVersion get version => SteelVersion.parse(tagName);

  /// Steel's own version, e.g. `0.17.1`.
  String get steelVersion => version.steel;

  /// The Minecraft version this build targets, e.g. `26.3`.
  String? get minecraftVersion => version.minecraft;

  /// The asset built for [target], or null if this release has none.
  ReleaseAsset? assetFor(SteelTarget target) {
    for (final a in assets) {
      if (a.name == target.assetName) return a;
    }
    return null;
  }

  static const fromMap = ReleaseMapper.fromMap;
}
