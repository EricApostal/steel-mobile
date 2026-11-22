import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'browser_path.g.dart';

/// The folder the file browser is showing (segments below the instance root),
/// kept while you switch tabs.
@Riverpod(keepAlive: true)
class BrowserPath extends _$BrowserPath {
  @override
  List<String> build(String instanceId) => const [];

  void open(List<String> segments) => state = segments;
}
