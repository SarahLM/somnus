import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  final Color color;

  AnalysisScreen(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: color,
      child: Text('Analysis'),
    );
  }
}
