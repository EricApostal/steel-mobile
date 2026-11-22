import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MainApp());

const _assetName = 'steel-android-aarch64';

// The termux-exec trick: Android (10+) forbids execve() on files in the app's
// data dir (SELinux W^X), but the system dynamic linker is a normal executable
// and mmap()s PROT_EXEC from app data just fine. So instead of exec'ing the
// binary directly, we exec `linker64 /path/to/binary args...`. The binary does
// not need the +x bit.
const _linker = '/system/bin/linker64';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: RunnerPage());
}

class RunnerPage extends StatefulWidget {
  const RunnerPage({super.key});

  @override
  State<RunnerPage> createState() => _RunnerPageState();
}

class _RunnerPageState extends State<RunnerPage> {
  final _args = TextEditingController(text: '--version');
  final _scroll = ScrollController();
  final _log = StringBuffer();
  bool _running = false;
  Process? _proc;

  void _add(String s) {
    setState(() => _log.writeln(s));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  /// Copies the bundled asset to app storage (no exec bit set) once.
  Future<File> _extract() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/$_assetName');
    if (!await file.exists()) {
      _add('extracting asset -> ${file.path}');
      final data = await rootBundle.load('assets/$_assetName');
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
    return file;
  }

  Future<void> _run() async {
    setState(() => _running = true);
    try {
      final file = await _extract();
      final args = _args.text.trim().isEmpty
          ? <String>[]
          : _args.text.trim().split(RegExp(r'\s+'));
      _add('\$ $_linker ${file.path} ${args.join(' ')}');

      final proc = await Process.start(
        _linker,
        [file.path, ...args],
        workingDirectory: file.parent.path,
        environment: {'HOME': file.parent.path},
      );
      _proc = proc;
      final ansi = RegExp(r'\x1B\[[0-9;]*m');
      proc.stdout
          .transform(utf8.decoder)
          .listen((s) => _add(s.replaceAll(ansi, '').trimRight()));
      proc.stderr
          .transform(utf8.decoder)
          .listen((s) => _add('[err] ${s.replaceAll(ansi, '').trimRight()}'));
      _add('[exit ${await proc.exitCode}]');
    } catch (e) {
      _add('[error] $e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('steel runner')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _args,
                  decoration: const InputDecoration(labelText: 'args'),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _running ? null : _run,
                child: const Text('Run'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _running ? () => _proc?.kill(ProcessSignal.sigkill) : null,
                child: const Text('Stop'),
              ),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: const Color(0xFF111111),
                child: SingleChildScrollView(
                  controller: _scroll,
                  child: SelectableText(
                    _log.toString(),
                    style: const TextStyle(
                      color: Color(0xFFDDDDDD),
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
