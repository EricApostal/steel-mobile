import 'package:material_ui/material_ui.dart';

/// Terminal-style log that follows new output unless the user scrolls up.
class LogView extends StatefulWidget {
  const LogView({super.key, required this.lines});

  final List<String> lines;

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final _scroll = ScrollController();
  bool _following = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients) {
        _following = _scroll.position.extentAfter < 48;
      }
    });
    _jumpToEnd();
  }

  @override
  void didUpdateWidget(LogView old) {
    super.didUpdateWidget(old);
    if (_following && old.lines != widget.lines) _jumpToEnd();
  }

  void _jumpToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF111111),
      child: SelectionArea(
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(8),
          itemCount: widget.lines.length,
          itemBuilder: (_, i) => Text(
            widget.lines[i],
            style: const TextStyle(
              color: Color(0xFFDDDDDD),
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
