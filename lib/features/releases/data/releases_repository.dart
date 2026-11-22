import 'package:steelmc_api/steelmc_api.dart';

import 'steel_build.dart';

class ReleasesRepository {
  const ReleasesRepository(this._client);

  final SteelMcClient _client;

  /// Releases that ship a binary for [target], newest first.
  Future<List<SteelBuild>> compatibleBuilds(SteelTarget target) async {
    final releases = await _client.listReleases();
    return [
      for (final r in releases)
        if (r.assetFor(target) case final asset?) SteelBuild(r, asset),
    ];
  }
}
