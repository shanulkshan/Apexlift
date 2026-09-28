import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Oxlift brand mark: a front-on ox head with sweeping horns.
/// Placeholder until a designer delivers the final logo; mirrored in
/// assets/brand/oxlift_mark.svg.
class OxLogo extends StatelessWidget {
  const OxLogo({super.key, this.size = 40, this.showWordmark = false});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(size * 0.26),
        ),
        child: CustomPaint(painter: OxMarkPainter()),
      ),
    );
    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.3),
        Text(
          'OXLIFT',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: size * 0.52,
                fontWeight: FontWeight.w800,
                letterSpacing: size * 0.05,
                height: 1,
              ),
        ),
      ],
    );
  }
}

/// Paints the ox mark into a square canvas. Public so the icon generator
/// (tool/render_icon_test.dart) can reuse it.
class OxMarkPainter extends CustomPainter {
  OxMarkPainter({this.color = AppColors.volt, this.cutout = AppColors.ink});

  final Color color;
  final Color cutout;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final fill = Paint()..color = color;

    // Points are given for the left half; `m` mirrors x for the right half.
    Path horn({required bool mirror}) {
      double x(double v) => s * (mirror ? 1 - v : v);
      double y(double v) => s * v;
      // Tapered crescent: thick at the skull, curving out and up to a point.
      return Path()
        ..moveTo(x(0.38), y(0.47))
        ..cubicTo(x(0.20), y(0.48), x(0.08), y(0.40), x(0.09), y(0.14))
        ..cubicTo(x(0.15), y(0.30), x(0.24), y(0.335), x(0.40), y(0.33))
        ..close();
    }

    canvas.drawPath(horn(mirror: false), fill);
    canvas.drawPath(horn(mirror: true), fill);

    // Head: broad brow tapering to a rounded muzzle.
    final head = Path()
      ..moveTo(s * 0.31, s * 0.33)
      ..quadraticBezierTo(s * 0.50, s * 0.29, s * 0.69, s * 0.33)
      ..lineTo(s * 0.63, s * 0.69)
      ..quadraticBezierTo(s * 0.50, s * 0.86, s * 0.37, s * 0.69)
      ..close();
    canvas.drawPath(head, fill);

    // Nostrils.
    final nostril = Paint()..color = cutout;
    canvas.drawCircle(Offset(s * 0.45, s * 0.70), s * 0.026, nostril);
    canvas.drawCircle(Offset(s * 0.55, s * 0.70), s * 0.026, nostril);
  }

  @override
  bool shouldRepaint(covariant OxMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.cutout != cutout;
}
