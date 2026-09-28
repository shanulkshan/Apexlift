import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/glass_theme.dart';

/// A liquid-glass surface.
///
/// * [blur] adds a real backdrop blur. Only use it for surfaces floating over
///   scrolling content (nav bar, pinned headers, sheets): backdrop blurs are
///   expensive, and over the already-soft ambient background a translucent
///   fill looks the same.
/// * [tint] washes the glass with a colour (e.g. the brand volt for primary
///   actions).
/// * [onTap] makes it pressable: it squishes slightly and gives a haptic tick.
class Glass extends StatefulWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 22,
    this.padding = EdgeInsets.zero,
    this.blur = false,
    this.tint,
    this.tintStrength = 0.22,
    this.onTap,
    this.shadow = true,
    this.shape = BoxShape.rectangle,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool blur;
  final Color? tint;
  final double tintStrength;
  final VoidCallback? onTap;
  final bool shadow;
  final BoxShape shape;

  @override
  State<Glass> createState() => _GlassState();
}

class _GlassState extends State<Glass> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (widget.onTap != null && _pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final g = GlassTheme.of(context);
    final circle = widget.shape == BoxShape.circle;
    final radius = BorderRadius.circular(widget.radius);

    Color over(Color base) => widget.tint == null
        ? base
        : Color.alphaBlend(
            widget.tint!.withValues(alpha: widget.tintStrength), base);

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        shape: widget.shape,
        borderRadius: circle ? null : radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [over(g.fillTop), over(g.fillBottom)],
        ),
      ),
      child: CustomPaint(
        foregroundPainter: _RimPainter(
          radius: widget.radius,
          circle: circle,
          bright: g.rimBright,
          dim: g.rimDim,
        ),
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );

    if (widget.blur) {
      final filter =
          ui.ImageFilter.blur(sigmaX: g.blurSigma, sigmaY: g.blurSigma);
      surface = circle
          ? ClipOval(child: BackdropFilter(filter: filter, child: surface))
          : ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(filter: filter, child: surface),
            );
    }

    if (widget.shadow) {
      surface = DecoratedBox(
        decoration: BoxDecoration(
          shape: widget.shape,
          borderRadius: circle ? null : radius,
          boxShadow: [
            BoxShadow(
              color: g.shadow,
              blurRadius: 24,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: surface,
      );
    }

    if (widget.onTap == null) return surface;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap!();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: surface,
      ),
    );
  }
}

/// The glass "rim": a hairline border lit from the top-left.
class _RimPainter extends CustomPainter {
  _RimPainter({
    required this.radius,
    required this.circle,
    required this.bright,
    required this.dim,
  });

  final double radius;
  final bool circle;
  final Color bright;
  final Color dim;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.6);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bright, dim, dim, bright.withValues(alpha: bright.a * 0.45)],
        stops: const [0, 0.45, 0.7, 1],
      ).createShader(rect);
    if (circle) {
      canvas.drawOval(rect, paint);
    } else {
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(radius)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RimPainter old) =>
      old.radius != radius ||
      old.circle != circle ||
      old.bright != bright ||
      old.dim != dim;
}

/// Full-width frosted bar for pinned headers: backdrop blur, glass fill and
/// a hairline along the bottom edge.
class GlassBar extends StatelessWidget {
  const GlassBar({super.key});

  @override
  Widget build(BuildContext context) {
    final g = GlassTheme.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: g.blurSigma, sigmaY: g.blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [g.fillBottom, g.fillTop],
            ),
            border: Border(bottom: BorderSide(color: g.rimDim)),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// Circular glass icon button (back buttons, header actions).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.tooltip,
    this.blur = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final String? tooltip;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final button = Glass(
      shape: BoxShape.circle,
      blur: blur,
      onTap: onPressed,
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, size: size * 0.48),
      ),
    );
    return Semantics(
      button: true,
      label: tooltip,
      child: tooltip == null ? button : Tooltip(message: tooltip, child: button),
    );
  }
}
