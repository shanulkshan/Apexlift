import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass.dart';

/// Pill chip: glass when idle, solid volt when selected.
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: theme.textTheme.labelLarge?.copyWith(color: fg)),
        ],
      ),
    );

    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: selected
            ? GestureDetector(
                key: const ValueKey(true),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: content,
                ),
              )
            : Glass(
                key: const ValueKey(false),
                radius: 100,
                shadow: false,
                onTap: onTap,
                child: content,
              ),
      ),
    );
  }
}

/// Glass segmented control with a sliding volt thumb.
class GlassSegmented<T> extends StatelessWidget {
  const GlassSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<(T value, String label)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final index = segments.indexWhere((s) => s.$1 == selected);

    return Glass(
      radius: 18,
      shadow: false,
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 44,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = constraints.maxWidth / segments.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  left: slot * index,
                  width: slot,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final (value, label) in segments)
                      Expanded(
                        child: Semantics(
                          selected: value == selected,
                          button: true,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onChanged(value);
                            },
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: theme.textTheme.labelLarge!.copyWith(
                                  color: value == selected
                                      ? scheme.onPrimary
                                      : scheme.onSurfaceVariant,
                                ),
                                child: Text(label),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Glass text field used for search.
class GlassSearchField extends StatelessWidget {
  const GlassSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Glass(
      radius: 18,
      shadow: false,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

/// Small uppercase label above a group of content.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
