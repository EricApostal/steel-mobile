import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:steelmc_api/steelmc_api.dart';

import '../data/binary_installer.dart';
import '../data/steel_build.dart';
import 'releases_providers.dart';

part 'install_controller.g.dart';

sealed class InstallState {
  const InstallState();
}

class NotInstalled extends InstallState {
  const NotInstalled();
}

class Installing extends InstallState {
  const Installing({this.progress, this.verifying = false});

  /// 0..1, null when unknown.
  final double? progress;
  final bool verifying;
}

class Installed extends InstallState {
  const Installed();
}

class InstallFailed extends InstallState {
  const InstallFailed(this.message);
  final String message;
}

/// Download/verify/delete lifecycle of one build. Kept alive so a download
/// continues while its card is scrolled off screen.
@Riverpod(keepAlive: true)
class InstallController extends _$InstallController {
  CancelToken? _cancel;

  @override
  InstallState build(SteelBuild release) =>
      ref.read(binaryStoreProvider).isInstalled(release)
          ? const Installed()
          : const NotInstalled();

  Future<void> install() async {
    if (state is Installing) return;
    final cancel = _cancel = CancelToken();
    state = const Installing();

    var lastPercent = -1;
    try {
      await ref.read(binaryInstallerProvider).install(
        release,
        cancelToken: cancel,
        onProgress: (received, total) {
          final size = total > 0 ? total : release.size;
          final percent = received * 100 ~/ size;
          if (percent == lastPercent) return; // don't rebuild per chunk
          lastPercent = percent;
          state = Installing(progress: received / size);
        },
        onVerifying: () => state = const Installing(verifying: true),
      );
      state = const Installed();
    } on SteelMcApiException catch (e) {
      state = e.cancelled ? const NotInstalled() : InstallFailed(e.message);
    } on InstallException catch (e) {
      state = InstallFailed(e.message);
    } catch (e) {
      state = InstallFailed('$e');
    } finally {
      _cancel = null;
    }
  }

  void cancel() => _cancel?.cancel();

  Future<void> uninstall() async {
    await ref.read(binaryStoreProvider).delete(release);
    state = const NotInstalled();
  }
}
