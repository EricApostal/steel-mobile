import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../instances/application/instances_controller.dart';
import '../../releases/application/releases_providers.dart';
import '../data/config_bootstrap.dart';
import '../data/log_entry.dart';
import '../data/steel_runner.dart';

part 'server_controller.g.dart';

enum ServerStatus { idle, starting, running, stopping }

class ServerState {
  const ServerState({
    this.status = ServerStatus.idle,
    this.entries = const [],
  });

  final ServerStatus status;
  final List<LogEntry> entries;

  bool get isActive => status != ServerStatus.idle;

  ServerState copyWith({ServerStatus? status, List<LogEntry>? entries}) =>
      ServerState(
        status: status ?? this.status,
        entries: entries ?? this.entries,
      );
}

/// Owns one instance's server process and its parsed log.
@Riverpod(keepAlive: true)
class ServerController extends _$ServerController {
  static const _maxEntries = 1500;
  static const _runner = SteelRunner();

  SteelProcess? _process;
  var _stopRequested = false;
  var _nextId = 0;
  final _entries = <LogEntry>[];
  Timer? _flushTimer;

  @override
  ServerState build(String instanceId) {
    ref.onDispose(() {
      _flushTimer?.cancel();
      _process?.kill(ProcessSignal.sigkill);
    });
    return const ServerState();
  }

  Future<void> start() async {
    if (state.isActive) return;
    final instance = ref.read(instanceProvider(instanceId));
    if (instance == null) return;

    final binary = ref.read(binaryStoreProvider).fileForTag(instance.versionTag);
    final dir = ref.read(instanceStoreProvider).dirFor(instanceId);

    _stopRequested = false;
    _entries.clear();
    state = const ServerState(status: ServerStatus.starting);
    _system('Starting Steel ${instance.version.steel}…');

    if (!binary.existsSync()) {
      _system('This version is not downloaded.', LogLevel.error);
      _finish();
      return;
    }

    try {
      await const ConfigBootstrap(_runner).ensurePort(
        binary: binary,
        dir: dir,
        port: instance.port,
      );
      _process = await _runner.start(binary, workingDirectory: dir);
    } catch (e) {
      _system('Failed to start: $e', LogLevel.error);
      _finish();
      return;
    }

    state = state.copyWith(status: ServerStatus.running);
    unawaited(_pump(_process!));
  }

  Future<void> _pump(SteelProcess process) async {
    await for (final line in process.lines) {
      _ingest(line);
    }
    final code = await process.exitCode;
    _process = null;
    if (_stopRequested) {
      _system('Server stopped');
    } else {
      _system('Server exited (code $code)', code == 0 ? LogLevel.system : LogLevel.error);
    }
    _finish();
  }

  /// SIGTERM first (Steel saves the world), then SIGKILL if it lingers.
  void stop() {
    final process = _process;
    if (process == null || state.status != ServerStatus.running) return;
    _stopRequested = true;
    state = state.copyWith(status: ServerStatus.stopping);
    process.kill();
    Timer(const Duration(seconds: 3), () {
      if (_process == process) process.kill(ProcessSignal.sigkill);
    });
  }

  void clearLog() {
    _entries.clear();
    state = state.copyWith(entries: const []);
  }

  void _finish() {
    _flush();
    state = state.copyWith(status: ServerStatus.idle);
  }

  void _system(String message, [LogLevel level = LogLevel.system]) {
    _entries.add(LogEntry(id: _nextId++, level: level, message: message));
    _scheduleFlush();
  }

  void _ingest(String line) {
    if (line.trim().isEmpty) return;
    final parsed = LogEntry.parse(line, _nextId);
    if (parsed != null) {
      _nextId++;
      _entries.add(parsed);
    } else if (_entries.isNotEmpty && _entries.last.level != LogLevel.system) {
      // Continuation of a multi-line message.
      final last = _entries.removeLast();
      _entries.add(last.withMessage('${last.message}\n${line.trim()}'));
    } else {
      _entries.add(LogEntry(id: _nextId++, level: LogLevel.info, message: line.trim()));
    }
    _scheduleFlush();
  }

  // Coalesce bursts of output into one state update per 100ms.
  void _scheduleFlush() => _flushTimer ??= Timer(const Duration(milliseconds: 100), _flush);

  void _flush() {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_entries.length > _maxEntries) {
      _entries.removeRange(0, _entries.length - _maxEntries);
    }
    state = state.copyWith(entries: List.of(_entries));
  }
}
