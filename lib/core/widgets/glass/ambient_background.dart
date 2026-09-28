import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/glass_theme.dart';

/// Owns the slow "drift" clock for the ambient colour field and paints it
/// behind the whole app (see `OxliftApp`). Freezes under reduced motion.
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 28),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AmbientScope(
        drift: _drift,
        child: AmbientBackdrop(child: widget.child),
      );
}

class _AmbientScope extends InheritedWidget {
  const _AmbientScope({required this.drift, required super.child});

  final Animation<double> drift;

  @override
  bool updateShouldNotify(_AmbientScope old) => old.drift != drift;
}

/// Paints the ambient colour field (opaque) under [child].
///
/// Pushed full-screen routes wrap themselves in this so they are opaque
/// during transitions, yet look continuous with the root background because
/// they share its drift clock.
class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final g = GlassTheme.of(context);
    final drift = context
            .dependOnInheritedWidgetOfExactType<_AmbientScope>()
            ?.drift ??
        const AlwaysStoppedAnimation(0.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: g.backgroundBase),
        RepaintBoundary(
          child: CustomPaint(painter: _OrbPainter(g.orbs, drift)),
        ),
        child,
      ],
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter(this.colors, this.drift) : super(repaint: drift);

  final List<Color> colors;
  final Animation<double> drift;

  // Anchor x/y (fraction of screen), orbit (fraction), size (fraction of
  // the shorter side), phase.
  static const _orbs = [
    (0.12, 0.10, 0.08, 1.05, 0.0),
    (0.92, 0.32, 0.10, 0.95, 0.25),
    (0.18, 0.72, 0.09, 0.90, 0.5),
    (0.85, 0.95, 0.07, 0.80, 0.75),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = drift.value;
    final shortest = size.shortestSide;
    for (var i = 0; i < _orbs.length && i < colors.length; i++) {
      final (ax, ay, orbit, scale, phase) = _orbs[i];
      final angle = (t + phase) * 2 * math.pi;
      final center = Offset(
        size.width * ax + math.cos(angle) * size.width * orbit,
        size.height * ay + math.sin(angle) * size.height * orbit * 0.6,
      );
      final radius = shortest * scale;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [colors[i], colors[i].withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.colors != colors || old.drift != drift;
}
