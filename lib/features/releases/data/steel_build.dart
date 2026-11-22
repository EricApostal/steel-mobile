import 'package:steelmc_api/steelmc_api.dart';

/// A release together with the asset that is compatible with this device.
class SteelBuild {
  const SteelBuild(this.release, this.asset);

  final Release release;
  final ReleaseAsset asset;

  String get tag => release.tagName;
  String get version => release.steelVersion;
  String? get minecraftVersion => release.minecraftVersion;
  DateTime? get publishedAt => release.publishedAt;
  int get size => asset.size;

  @override
  bool operator ==(Object other) =>
      other is SteelBuild && other.tag == tag && other.asset.id == asset.id;

  @override
  int get hashCode => Object.hash(tag, asset.id);
}
