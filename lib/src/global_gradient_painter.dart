import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import 'global_custom_paint.dart';
import 'global_gradient.dart';

/// Paints a rectangular border with [width], and filled with a [GlobalGradient].
///
/// When used with a [GlobalRadialGradient], a spotlight effect can be created at the center of
/// [gradient]. Tracking a pointer and setting its location to [gradient]s center, highlights the
/// pointer's position. This works especially well, when the same gradient is used by multiple UI
/// elements, which all have the same border configuration.
class GlobalGradientBorderPainter extends GlobalCustomPainter {
  /// Creates a new [GlobalGradientBorderPainter], whose [gradient] changes often.
  ///
  /// Using a [ValueListenable] to provide the [gradient] allows the build and layout phases of the
  /// pipeline to be skipped when the gradient changes.
  GlobalGradientBorderPainter({
    @required this.gradient,
    @required this.width,
  }) : super(repaint: gradient);

  /// Creates a new [GlobalGradientBorderPainter] whose [gradient] does not change.
  GlobalGradientBorderPainter.static({
    GlobalGradient gradient,
    @required this.width,
  })  : gradient = ValueNotifier(gradient),
        super();

  /// The [GlobalGradient] to use for the border fill, wrapped in a [ValueListenable].
  ///
  /// Whenever the [ValueListenable] notifies, the border is repainted.
  ///
  /// It is allowed to set [gradient.value] to `null`, to disable painting of the border.
  final ValueListenable<GlobalGradient> gradient;

  /// The width of the border.
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    final gradient = this.gradient.value;
    if (gradient == null) return;

    final bottomRight = size.bottomRight(Offset.zero);
    final rect = Rect.fromPoints(Offset.zero, bottomRight);
    final shader = gradient.createShader(rect, globalToLocal: globalToLocal);
    if (shader == null) return;

    final strokeInset = EdgeInsets.all(width / 2);
    final borderRect = strokeInset.deflateRect(rect);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..shader = shader
      ..strokeWidth = width;

    canvas.drawRect(borderRect, paint);
  }

  @override
  bool shouldRepaint(GlobalGradientBorderPainter oldDelegate) {
    return width != oldDelegate.width ||
        gradient != oldDelegate.gradient;
  }
}
