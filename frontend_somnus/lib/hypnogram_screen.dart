import 'package:flutter/material.dart';

class HypnogramWidget extends StatelessWidget {
  final Color color;

  HypnogramWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: color,
      child: Text('Hypnogramm'),
    );
  }
}
