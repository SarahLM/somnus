import 'package:flutter/material.dart';

class EditScreen extends StatelessWidget {
  final Color color;

  EditScreen(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: color,
      child: Text('Edit'),
    );
  }
}
