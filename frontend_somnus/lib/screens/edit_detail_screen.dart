import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/widgets/syncfusion.dart';

class EditDetailsScreen extends StatelessWidget {
  final List<DataPoint> sleepData;
  final String title;
  EditDetailsScreen({this.sleepData, this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Sync(
          title: title,
          sleepData: sleepData,
        ),
      ),
    );
  }
}
