import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/glass_theme.dart';
import 'glass.dart';

class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom padding for scrollable content so it can scroll fully clear of
/// the floating nav bar (and anything stacked on it, like the active-workout
/// banner). The shell Scaffold uses `extendBody`, which reports the bar's
/// height as bottom padding.
double navBarClearance(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + 16;

/// Floating pill-shaped tab bar. The selected tab sits in a volt "liquid"
/// bubble that springs between tabs.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.header,
  });

  final List<GlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Optional widget stacked above the bar (e.g. an active-workout banner).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final g = GlassTheme.of(context);
    // Scroll-edge fade: content dissolves into the background as it slides
    // under the floating bar instead of showing through below it.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            g.backgroundBase.withValues(alpha: 0),
            g.backgroundBase.withValues(alpha: 0.85),
            g.backgroundBase,
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?header,
            Glass(
              blur: true,
              radius: 34,
              tint: scheme.surface,
              tintStrength: 0.35,
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                height: 60,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slot = constraints.maxWidth / items.length;
                    return Stack(
                      children: [
                        // The liquid bubble.
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutBack,
                          left: slot * selectedIndex,
                          top: 0,
                          bottom: 0,
                          width: slot,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.lerp(
                                    scheme.primary,
                                    Colors.white,
                                    0.25,
                                  )!,
                                  scheme.primary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.45),
                                  blurRadius: 18,
                                  spreadRadius: -4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (final (i, item) in items.indexed)
                              Expanded(
                                child: _NavButton(
                                  item: item,
                                  selected: i == selectedIndex,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    onSelected(i);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
