import 'package:flutter/widgets.dart';

/// Window width at which the app switches from the phone layout (bottom tabs,
/// stacked pages) to the desktop layout (sidebar, side-by-side panes).
const desktopBreakpoint = 900.0;

bool isDesktopWidth(BuildContext context) => MediaQuery.sizeOf(context).width >= desktopBreakpoint;
