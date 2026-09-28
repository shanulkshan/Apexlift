import 'package:flutter/material.dart';

import 'glass.dart';

/// Shows [builder] in a floating frosted bottom sheet.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool scrollControlled = false,
}) =>
    showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: scrollControlled,
      useSafeArea: true,
      builder: (context) => GlassSheet(child: builder(context)),
    );

/// Floating frosted sheet with a drag handle.
class GlassSheet extends StatelessWidget {
  const GlassSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      // Lift above the keyboard when a field inside is focused.
      padding: EdgeInsets.fromLTRB(
          10, 0, 10, 10 + MediaQuery.viewInsetsOf(context).bottom),
      child: Glass(
        blur: true,
        radius: 30,
        // Extra opacity so text stays readable over busy content.
        tint: scheme.surface,
        tintStrength: 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// Frosted confirmation dialog. Returns true when [confirmLabel] is tapped.
Future<bool> showGlassConfirm({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierColor: Colors.black54,
    builder: (context) {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Glass(
          blur: true,
          radius: 28,
          tint: scheme.surface,
          tintStrength: 0.6,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cancelLabel != null)
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(cancelLabel,
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    ),
                  const SizedBox(width: 4),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      backgroundColor: destructive ? scheme.error : null,
                      foregroundColor: destructive ? scheme.onError : null,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
