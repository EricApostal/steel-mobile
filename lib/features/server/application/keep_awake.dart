import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../instances/application/instances_controller.dart';
import 'server_controller.dart';

part 'keep_awake.g.dart';

/// Keeps the screen on while any server is running, since the app can't yet
/// keep a server alive in the background. Returns whether the lock is held.
@Riverpod(keepAlive: true)
bool keepAwake(Ref ref) {
  final instances = ref.watch(instancesControllerProvider);
  final active = instances.any(
    (i) => ref.watch(serverControllerProvider(i.id).select((s) => s.isActive)),
  );

  unawaited(_apply(active));
  ref.onDispose(() => unawaited(_apply(false)));
  return active;
}

Future<void> _apply(bool enable) async {
  try {
    await WakelockPlus.toggle(enable: enable);
  } catch (e) {
    debugPrint('Wakelock unavailable: $e');
  }
}
