import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../releases/application/releases_providers.dart';
import '../../releases/data/steel_build.dart';
import '../data/steel_runner.dart';

part 'server_controller.g.dart';

enum ServerStatus { idle, running, stopping }

class ServerState {
  const ServerState({
    this.status = ServerStatus.idle,
    this.build,
    this.lines = const [],
  });

  final ServerStatus status;

  /// The build that is running, or last ran.
  final SteelBuild? build;
  final List<String> lines;

  bool get isActive => status != ServerStatus.idle;

  ServerState copyWith({ServerStatus? status, List<String>? lines}) =>
      ServerState(
        status: status ?? this.status,
        build: build,
        lines: lines ?? this.lines,
      );
}

/// Owns the single running server process and its log.
@Riverpod(keepAlive: true)
class ServerController extends _$ServerController {
  static const _maxLines = 2000;

  SteelProcess? _process;
  final _pending = <String>[];
  Timer? _flushTimer;

  @override
  ServerState build() {
    ref.onDispose(() {
      _flushTimer?.cancel();
      _process?.kill(ProcessSignal.sigkill);
    });
    return const ServerState();
  }

  Future<void> start(SteelBuild release) async {
    if (state.isActive) return;
    final store = ref.read(binaryStoreProvider);
    final binary = store.fileFor(release);

    state = ServerState(
      status: ServerStatus.running,
      build: release,
      lines: [
        '\$ ${SteelRunner.linker} ${binary.path}',
      ],
    );

    final SteelProcess process;
    try {
      process = await const SteelRunner().start(
        binary,
        workingDirectory: store.serverDir,
      );
    } catch (e) {
      _append(['[failed to start] $e']);
      _flush();
      state = state.copyWith(status: ServerStatus.idle);
      return;
    }
    _process = process;
    unawaited(_pump(process));
  }

  Future<void> _pump(SteelProcess process) async {
    await for (final line in process.lines) {
      _append([line]);
    }
    final code = await process.exitCode;
    _append(['[exited with code $code]']);
    _flush();
    _process = null;
    state = state.copyWith(status: ServerStatus.idle);
  }

  /// SIGTERM first, then SIGKILL if it hasn't gone away.
  void stop() {
    final process = _process;
    if (process == null || state.status != ServerStatus.running) return;
    state = state.copyWith(status: ServerStatus.stopping);
    process.kill();
    Timer(const Duration(seconds: 3), () {
      if (_process == process) process.kill(ProcessSignal.sigkill);
    });
  }

  // Coalesce bursts of output into one state update per 100ms.
  void _append(List<String> lines) {
    _pending.addAll(lines);
    _flushTimer ??= Timer(const Duration(milliseconds: 100), _flush);
  }

  void _flush() {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_pending.isEmpty) return;
    final all = [...state.lines, ..._pending];
    _pending.clear();
    state = state.copyWith(
      lines: all.length > _maxLines ? all.sublist(all.length - _maxLines) : all,
    );
  }
}
