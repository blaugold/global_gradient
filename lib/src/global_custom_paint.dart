import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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

abstract class GlobalCustomPainter extends CustomPainter {
  GlobalCustomPainter({Listenable repaint}) : super(repaint: repaint);

  RenderBox _renderObject;

  Offset globalToLocal(Offset offset) {
    return _renderObject.globalToLocal(offset);
  }
}
