import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A compact, left-aligned header title: the name, then a line of secondary
/// info under it. Use with `FHeader.nested(titleAlignment: Alignment.centerLeft)`.
class HeaderTitle extends StatelessWidget {
  const HeaderTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.body.lg.copyWith(fontWeight: FontWeight.w600, height: 1.2),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body.xs.copyWith(color: theme.colors.mutedForeground, height: 1.3),
          ),
      ],
    );
  }
}
