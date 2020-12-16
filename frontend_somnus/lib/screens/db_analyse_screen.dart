import 'package:flutter/material.dart';

class DbScreen extends StatelessWidget {
  final Color color;

  DbScreen(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: color,
      child: Text('DbScreen'),
    );
  }
}
