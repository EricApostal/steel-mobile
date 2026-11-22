import 'package:dart_mappable/dart_mappable.dart';

part 'release_asset.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class ReleaseAsset with ReleaseAssetMappable {
  const ReleaseAsset({
    required this.id,
    required this.name,
    required this.size,
    required this.browserDownloadUrl,
    this.digest,
    this.downloadCount = 0,
  });

  final int id;
  final String name;

  /// Size in bytes.
  final int size;
  final String browserDownloadUrl;

  /// Checksum as reported by GitHub, formatted `sha256:<hex>`.
  final String? digest;
  final int downloadCount;

  /// The hex sha256 from [digest], if GitHub provided one.
  String? get sha256 {
    final d = digest;
    if (d == null || !d.startsWith('sha256:')) return null;
    return d.substring('sha256:'.length);
  }

  static const fromMap = ReleaseAssetMapper.fromMap;
}
