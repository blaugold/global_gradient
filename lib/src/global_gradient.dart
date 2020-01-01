import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class _ColorsAndStops {
  _ColorsAndStops(this.colors, this.stops);

  final List<Color> colors;
  final List<double> stops;
}

/// Calculate the color at position [t] of the gradient defined by [colors] and [stops].
Color _sample(List<Color> colors, List<double> stops, double t) {
  assert(colors != null);
  assert(colors.isNotEmpty);
  assert(stops != null);
  assert(stops.isNotEmpty);
  assert(t != null);
  if (t <= stops.first) return colors.first;
  if (t >= stops.last) return colors.last;
  final int index = stops.lastIndexWhere((double s) => s <= t);
  assert(index != -1);
  return Color.lerp(
    colors[index],
    colors[index + 1],
    (t - stops[index]) / (stops[index + 1] - stops[index]),
  );
}

_ColorsAndStops _interpolateColorsAndStops(
  List<Color> aColors,
  List<double> aStops,
  List<Color> bColors,
  List<double> bStops,
  double t,
) {
  assert(aColors.length >= 2);
  assert(bColors.length >= 2);
  assert(aStops.length == aColors.length);
  assert(bStops.length == bColors.length);
  final SplayTreeSet<double> stops = SplayTreeSet<double>()..addAll(aStops)..addAll(bStops);
  final List<double> interpolatedStops = stops.toList(growable: false);
  final List<Color> interpolatedColors = interpolatedStops
      .map<Color>((double stop) =>
          Color.lerp(_sample(aColors, aStops, stop), _sample(bColors, bStops, stop), t))
      .toList(growable: false);
  return _ColorsAndStops(interpolatedColors, interpolatedStops);
}

/// Base for adaptations of [Gradient]s which can be globally positioned.
abstract class GlobalGradient extends Gradient {
  const GlobalGradient({
    List<Color> colors,
    List<double> stops,
    GradientTransform transform,
  }) : super(colors: colors, stops: stops, transform: transform);

  /// Creates a [Shader] which can be used to paint this gradient.
  ///
  /// This method might return `null`, if this [Gradient] does not paint into [rect], and painting
  /// should be skipped. [rect] is the bounding box of the area into which this gradient will be
  /// painted, in local coordinates.
  ///
  /// [globalToLocal] cannot be `null`. It needs to translate the given screen coordinates into
  /// local coordinates of the canvas in which the [Shader] will be used.
  @override
  Shader createShader(
    Rect rect, {
    TextDirection textDirection,
    @required Offset globalToLocal(Offset offset),
  });
}

/// This is an adaption of [RadialGradient], for use as a global gradient.
class GlobalRadialGradient extends GlobalGradient {
  /// Creates a radial gradient.
  ///
  /// The [colors] argument must not be null. If [stops] is non-null, it must
  /// have the same length as [colors].
  const GlobalRadialGradient({
    this.center = Offset.zero,
    @required this.radius,
    @required List<Color> colors,
    List<double> stops,
    this.tileMode = TileMode.clamp,
    this.focal,
    this.focalRadius = 0.0,
    GradientTransform transform,
  })  : assert(center != null),
        assert(radius != null),
        assert(tileMode != null),
        assert(focalRadius != null),
        diameter = radius * 2,
        super(colors: colors, stops: stops, transform: transform);

  /// The center of the gradient in global logical pixels.
  final Offset center;

  /// The radius of the gradient in logical pixels.
  final double radius;

  /// The diameter of the gradient in logical pixels.
  final double diameter;

  /// How this gradient should tile the plane beyond the outer ring at [radius]
  /// pixels from the [center].
  ///
  /// For details, see [TileMode].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_radial.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_radial.png)
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_radialWithFocal.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_radialWithFocal.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_radialWithFocal.png)
  final TileMode tileMode;

  /// The focal point of the gradient.  If specified, the gradient will appear
  /// to be focused along the vector from [center] to focal.
  ///
  /// If this value is specified and [focalRadius] > 0.0, care should be taken
  /// to ensure that either this value or [center] are not both
  /// [Offset.zero], which would fail to create a valid gradient.
  final Offset focal;

  /// The radius of the focal point of gradient, in logical pixels.
  ///
  /// If this value is specified and is greater than 0.0, either [focal] or
  /// [center] must not be [Offset.zero], which would fail to create
  /// a valid gradient.
  final double focalRadius;

  @override
  Shader createShader(
    Rect rect, {
    TextDirection textDirection,
    Offset globalToLocal(Offset offset),
  }) {
    assert(globalToLocal != null);

    final localCenter = globalToLocal(center);

    if (rect != null) {
      // This optimization only works for simple gradients without a focal point and with
      // TileMode.clamp, because it works by assuming the gradient only paints in a circle centered
      // at localCenter with the gradient's radius.
      if (tileMode == TileMode.clamp && focal == null) {
        // TODO use more specific check, which checks for collisions of a circle and rect.
        final gradientRect = Rect.fromCenter(
          center: localCenter,
          width: diameter,
          height: diameter,
        );

        if (!gradientRect.overlaps(rect)) return null;
      }
    }

    return ui.Gradient.radial(
      localCenter,
      radius,
      colors,
      _impliedStops(),
      tileMode,
      transform?.transform(rect, textDirection: textDirection)?.storage,
      focal,
      focalRadius,
    );
  }

  /// Returns a new [GlobalRadialGradient] with its colors scaled by the given factor.
  ///
  /// Since the alpha component of the Color is what is scaled, a factor
  /// of 0.0 or less results in a gradient that is fully transparent.
  @override
  Gradient scale(double factor) {
    return GlobalRadialGradient(
      center: center,
      radius: radius,
      colors: colors.map<Color>((Color color) => Color.lerp(null, color, factor)).toList(),
      stops: stops,
      tileMode: tileMode,
      focal: focal,
      focalRadius: focalRadius,
    );
  }

  @override
  Gradient lerpFrom(Gradient a, double t) {
    if (a == null || (a is GlobalRadialGradient)) return GlobalRadialGradient.lerp(a, this, t);
    return super.lerpFrom(a, t);
  }

  @override
  Gradient lerpTo(Gradient b, double t) {
    if (b == null || (b is GlobalRadialGradient)) return GlobalRadialGradient.lerp(this, b, t);
    return super.lerpTo(b, t);
  }

  /// Linearly interpolate between two [GlobalRadialGradient]s.
  ///
  /// If either gradient is null, this function linearly interpolates from a
  /// a gradient that matches the other gradient in [center], [radius], [stops] and
  /// [tileMode] and with the same [colors] but transparent (using [scale]).
  ///
  /// If neither gradient is null, they must have the same number of [colors].
  ///
  /// The `t` argument represents a position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid (and can
  /// easily be generated by curves such as [Curves.elasticInOut]).
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  static GlobalRadialGradient lerp(GlobalRadialGradient a, GlobalRadialGradient b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    if (a == null) return b.scale(t);
    if (b == null) return a.scale(1.0 - t);
    final _ColorsAndStops interpolated = _interpolateColorsAndStops(
      a.colors,
      a._impliedStops(),
      b.colors,
      b._impliedStops(),
      t,
    );
    return GlobalRadialGradient(
      center: Offset.lerp(a.center, b.center, t),
      radius: math.max(0.0, ui.lerpDouble(a.radius, b.radius, t)),
      colors: interpolated.colors,
      stops: interpolated.stops,
      tileMode: t < 0.5 ? a.tileMode : b.tileMode,
      // TODO(): interpolate tile mode
      focal: Offset.lerp(a.focal, b.focal, t),
      focalRadius: math.max(0.0, ui.lerpDouble(a.focalRadius, b.focalRadius, t)),
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final GlobalRadialGradient typedOther = other;
    if (center != typedOther.center ||
        radius != typedOther.radius ||
        tileMode != typedOther.tileMode ||
        colors?.length != typedOther.colors?.length ||
        stops?.length != typedOther.stops?.length ||
        focal != typedOther.focal ||
        focalRadius != typedOther.focalRadius) return false;
    if (colors != null) {
      assert(typedOther.colors != null);
      assert(colors.length == typedOther.colors.length);
      for (int i = 0; i < colors.length; i += 1) {
        if (colors[i] != typedOther.colors[i]) return false;
      }
    }
    if (stops != null) {
      assert(typedOther.stops != null);
      assert(stops.length == typedOther.stops.length);
      for (int i = 0; i < stops.length; i += 1) {
        if (stops[i] != typedOther.stops[i]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode =>
      hashValues(center, radius, tileMode, hashList(colors), hashList(stops), focal, focalRadius);

  @override
  String toString() {
    return '$runtimeType($center, $radius, $colors, $stops, $tileMode, $focal, $focalRadius)';
  }

  List<double> _impliedStops() {
    if (stops != null) return stops;
    assert(colors.length >= 2, 'colors list must have at least two colors');
    final double separation = 1.0 / (colors.length - 1);
    return List<double>.generate(
      colors.length,
      (int index) => index * separation,
      growable: false,
    );
  }
}
