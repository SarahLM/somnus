import 'package:flutter/material.dart';

class HypnogramScreen extends StatelessWidget {
  final Color color;

  HypnogramScreen(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: color,
      child: Text('Hypnogramm'),
    );
  }
}
