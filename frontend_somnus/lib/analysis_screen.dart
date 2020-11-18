import 'package:flutter/material.dart';

class AnalysisWidget extends StatelessWidget {
  final Color color;

  AnalysisWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: color,
      child: Text('Analysis'),
    );
  }
}
