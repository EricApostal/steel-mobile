import 'package:dart_mappable/dart_mappable.dart';
import 'package:steelmc_api/steelmc_api.dart';

part 'instance.mapper.dart';

/// A named server with its own world/config directory, pinned to one build.
@MappableClass()
class Instance with InstanceMappable {
  const Instance({
    required this.id,
    required this.name,
    required this.versionTag,
    required this.port,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// Release tag of the Steel build this instance runs, e.g. `v0.17.1+mc26.3`.
  final String versionTag;

  /// Port applied to the server's config on its first start.
  final int port;
  final DateTime createdAt;

  SteelVersion get version => SteelVersion.parse(versionTag);

  static const fromMap = InstanceMapper.fromMap;
}
