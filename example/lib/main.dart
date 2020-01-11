import 'package:flutter/material.dart';

import 'spotlight_border_demo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Gradient Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SpotlightBorderDemo(),
    );
  }
}
