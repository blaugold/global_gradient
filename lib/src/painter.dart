import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import 'global_custom_paint.dart';
import 'global_gradient.dart';

class GlobalGradientBorderPainter extends GlobalCustomPainter {
  GlobalGradientBorderPainter({
    @required this.gradient,
    @required this.width,
  }) : super(repaint: gradient);

  final ValueListenable<GlobalGradient> gradient;

  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final _gradient = gradient.value;
    if (_gradient == null) return;

    final bottomRight = size.bottomRight(Offset.zero);
    final rect = Rect.fromPoints(Offset.zero, bottomRight);

    if (_gradient is GlobalRadialGradient) {
      final gradientRect = Rect.fromCenter(
        center: globalToLocal(_gradient.center),
        width: _gradient.radius * 2,
        height: _gradient.radius * 2,
      );

      if (!rect.overlaps(gradientRect)) return;
    }

    final strokeInset = EdgeInsets.all(width / 2);
    final borderRect = strokeInset.deflateRect(rect);
    final shader = _gradient.createShader(rect, globalToLocal: globalToLocal);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..shader = shader
      ..strokeWidth = width;

    canvas.drawRect(borderRect, paint);
  }

  @override
  bool shouldRepaint(GlobalGradientBorderPainter oldDelegate) {
    return width != oldDelegate.width ||
        gradient != oldDelegate.gradient ||
        gradient.value != oldDelegate.gradient.value;
  }
}
