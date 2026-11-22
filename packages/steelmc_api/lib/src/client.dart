import 'package:dio/dio.dart';

import 'exception.dart';
import 'models/release.dart';
import 'models/release_asset.dart';

typedef ProgressCallback = void Function(int received, int total);

class SteelMcClient {
  SteelMcClient({
    Dio? dio,
    this.owner = 'Steel-Foundation',
    this.repo = 'SteelMC',
  }) : _dio = dio ?? Dio(BaseOptions(headers: {'User-Agent': 'steelmc_api'}));

  final Dio _dio;
  final String owner;
  final String repo;

  /// All published (non-draft) releases, newest first.
  Future<List<Release>> listReleases({
    int perPage = 100,
    int maxPages = 5,
    CancelToken? cancelToken,
  }) async {
    final releases = <Release>[];
    for (var page = 1; page <= maxPages; page++) {
      final data = await _guard(
        () => _dio.get<List<dynamic>>(
          'https://api.github.com/repos/$owner/$repo/releases',
          queryParameters: {'per_page': perPage, 'page': page},
          options: Options(headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          }),
          cancelToken: cancelToken,
        ),
      );
      final batch = (data.data ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Release.fromMap)
          .where((r) => !r.draft);
      releases.addAll(batch);
      if ((data.data ?? const []).length < perPage) break;
    }
    return releases;
  }

  /// Downloads [asset] to [savePath].
  Future<void> downloadAsset(
    ReleaseAsset asset,
    String savePath, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    await _guard(
      () => _dio.download(
        asset.browserDownloadUrl,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
        options: Options(headers: {'Accept': 'application/octet-stream'}),
      ),
    );
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        throw const SteelMcApiException('Cancelled', cancelled: true);
      }
      final status = e.response?.statusCode;
      final rateLimited = (status == 403 || status == 429) &&
          e.response?.headers.value('x-ratelimit-remaining') == '0';
      throw SteelMcApiException(
        rateLimited
            ? 'GitHub rate limit reached, try again later.'
            : status != null
                ? 'GitHub returned HTTP $status.'
                : 'Network error: ${e.message ?? e.type.name}',
        statusCode: status,
      );
    }
  }
}
