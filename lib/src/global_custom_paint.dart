import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Extension of [CustomPainter] which exposes a method to translate global to local coordinates.
abstract class GlobalCustomPainter extends CustomPainter {
  GlobalCustomPainter({Listenable repaint}) : super(repaint: repaint);

  RenderBox _renderObject;

  /// Translates the screen coordinates in [offset] into coordinates which are local to the [Canvas]
  /// passed to [GlobalCustomPainter.paint].
  Offset globalToLocal(Offset offset) {
    return _renderObject.globalToLocal(offset);
  }

  @override
  @mustCallSuper
  void paint(Canvas canvas, Size size) {
    assert(
    _renderObject != null,
    'Please make sure this painter ($runtimeType) is used in an instance of GlobalCustomPaint.',
    );
  }
}

/// Use this [Widget] to paint a [GlobalCustomPaint].
class GlobalCustomPaint extends CustomPaint {
  const GlobalCustomPaint({
    Key key,
    this.painter,
    this.foregroundPainter,
    Size size = Size.zero,
    bool isComplex = false,
    bool willChange = false,
    Widget child,
  }) : super(
            key: key,
            child: child,
            painter: painter,
            foregroundPainter: foregroundPainter,
            size: size,
            isComplex: isComplex,
            willChange: willChange);

  final GlobalCustomPainter painter;

  final GlobalCustomPainter foregroundPainter;

  @override
  RenderCustomPaint createRenderObject(BuildContext context) {
    final renderObject = RenderCustomPaint(
      painter: painter,
      foregroundPainter: foregroundPainter,
      preferredSize: size,
      isComplex: isComplex,
      willChange: willChange,
    );

    painter?._renderObject = renderObject;
    foregroundPainter?._renderObject = renderObject;

    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomPaint renderObject) {
    renderObject
      ..painter = painter
      ..foregroundPainter = foregroundPainter
      ..preferredSize = size
      ..isComplex = isComplex
      ..willChange = willChange;

    painter?._renderObject = renderObject;
    foregroundPainter?._renderObject = renderObject;
  }

  @override
  void didUnmountRenderObject(RenderCustomPaint renderObject) {
    renderObject
      ..painter = null
      ..foregroundPainter = null;

    painter?._renderObject = null;
    foregroundPainter?._renderObject = null;
  }
}
