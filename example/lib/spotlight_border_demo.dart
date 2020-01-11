import 'package:flutter/material.dart';
import 'package:global_gradient/global_gradient.dart';

/// An item in the grid the demo displays.
class Item {
  final IconData icon;
  final String label;

  const Item({this.icon, this.label});
}

/// Some demo [Item]s.
const items = [
  Item(icon: Icons.attach_money, label: 'Money'),
  Item(icon: Icons.favorite, label: 'Favorite'),
  Item(icon: Icons.home, label: 'Account'),
  Item(icon: Icons.fingerprint, label: 'Fingerprint'),
  Item(icon: Icons.all_inclusive, label: 'All inclusive'),
  Item(icon: Icons.beenhere, label: 'Beenhere'),
  Item(icon: Icons.location_on, label: 'Location on'),
  Item(icon: Icons.camera, label: 'Camera'),
  Item(icon: Icons.spellcheck, label: 'Spellcheck'),
];

/// Creates the [GlobalRadialGradient] which determines the look of the
/// spotlight. [center] is the center of the gradient in global logical pixels.
GlobalRadialGradient _spotlightGradient(Offset center) {
  assert(center != null);

  return GlobalRadialGradient(
    center: center,
    radius: 100,
    colors: const [
      Color(0xFFFFFFFF),
      Color(0xA0FFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: const [
      0.0,
      0.6,
      1.0,
    ],
  );
}

class SpotlightBorderDemo extends StatefulWidget {
  @override
  _SpotlightBorderDemoState createState() => _SpotlightBorderDemoState();
}

class _SpotlightBorderDemoState extends State<SpotlightBorderDemo> {
  /// Instead of using [setState], a [ValueNotifier] is used to update the
  /// spotlight gradient. This means the widget tree won't be rebuilt every
  /// time the spotlight changes position, which could be very frequently, if
  /// the spotlight tracks the mouse, as in this demo.
  ValueNotifier<GlobalRadialGradient> _spotlight = ValueNotifier(null);

  void _updateSpotlight(Offset center) =>
      _spotlight.value = _spotlightGradient(center);

  void _disableSpotlight() => _spotlight.value = null;

  Widget _buildSpotlitBox(Widget child) {
    // Here the spotlight gradient is painted in the border around the child.
    // The global gradient creates a different ui.Gradient for each location
    // at which it is painted. This ui.Gradient is positioned in the local
    // canvas to appear at the position of the global gradient.
    // GlobalGradientBorderPainter needs to be used with GlobalCustomPaint.
    return GlobalCustomPaint(
      foregroundPainter: GlobalGradientBorderPainter(
        gradient: _spotlight,
        width: 4,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemWidgets =
        items.map(_buildItem).map(_buildSpotlitBox).toList();

    return Scaffold(
      backgroundColor: Colors.blue,
      // Update the spotlight to track the mouse.
      body: MouseRegion(
        onEnter: (event) => _updateSpotlight(event.position),
        onHover: (event) => _updateSpotlight(event.position),
        onExit: (event) => _disableSpotlight(),
        // Layout the items in centered 3 column grid.
        child: _buildItemLayout(itemWidgets),
      ),
    );
  }

  Align _buildItemLayout(List<Widget> items) {
    return Align(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          children: items
              .map((item) => Container(
                    child: item,
                    padding: EdgeInsets.all(16),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Container _buildItem(Item item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              item.icon,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              item.label,
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
