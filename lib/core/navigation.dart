import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show MaterialPageRoute;

/// Pushes a page with the platform's native transition (and predictive back).
Future<T?> pushPage<T>(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context).push(MaterialPageRoute<T>(builder: builder));
