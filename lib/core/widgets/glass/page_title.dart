import 'package:flutter/material.dart';

/// Large in-content page title (iOS "large title" style) with optional
/// subtitle and trailing action.
class PageTitle extends StatelessWidget {
  const PageTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 8),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500),
                  ),
                Text(title, style: theme.textTheme.displaySmall),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
