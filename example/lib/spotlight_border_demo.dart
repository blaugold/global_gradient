import 'dart:async';

import 'package:flutter/material.dart';
import 'package:global_gradient/global_gradient.dart';

final items = const [
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

class Item {
  final IconData icon;
  final String label;

  const Item({this.icon, this.label});
}

class SpotlightBorderDemo extends StatefulWidget {
  @override
  _SpotlightBorderDemoState createState() => _SpotlightBorderDemoState();
}

class _SpotlightBorderDemoState extends State<SpotlightBorderDemo> {
  ValueNotifier<GlobalRadialGradient> _spotlight = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: MouseRegion(
        onEnter: (event) {
          _updateSpotlight(event.position);
        },
        onHover: (event) {
          _updateSpotlight(event.position);
        },
        onExit: (event) {
          _updateSpotlight(null);
        },
        child: Align(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: items.map(_buildItem).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _updateSpotlight(Offset center) {
    scheduleMicrotask(() {
      _spotlight.value = _spotlightGradient(center);
    });
  }

  GlobalRadialGradient _spotlightGradient(Offset center) {
    if (center == null) return null;

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

  Widget _buildItem(Item item) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlobalCustomPaint(
        foregroundPainter: GlobalGradientBorderPainter(
          gradient: _spotlight,
          width: 4,
        ),
        child: Container(
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
        ),
      ),
    );
  }
}
