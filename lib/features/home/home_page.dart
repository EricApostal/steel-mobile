import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../instances/ui/instances_page.dart';
import '../releases/ui/versions_page.dart';

/// Root screen: Instances and Versions tabs.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: false,
      header: FHeader(
        title: Text(_index == 0 ? 'Instances' : 'Versions'),
        suffixes: [
          if (_index == 0)
            FHeaderAction(
              icon: const Icon(FLucideIcons.plus),
              onPress: () => createInstance(context),
            ),
        ],
      ),
      footer: FBottomNavigationBar(
        index: _index,
        onChange: (i) => setState(() => _index = i),
        children: const [
          FBottomNavigationBarItem(icon: Icon(FLucideIcons.server), label: Text('Instances')),
          FBottomNavigationBarItem(icon: Icon(FLucideIcons.package), label: Text('Versions')),
        ],
      ),
      child: IndexedStack(
        index: _index,
        children: const [InstancesPage(), VersionsPage()],
      ),
    );
  }
}
