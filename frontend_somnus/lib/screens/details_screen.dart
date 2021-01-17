import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/widgets/syncfusion.dart';
import './edit_data_screen.dart';

class EditDetailsScreen extends StatelessWidget {
  final List<DataPoint> sleepData;
  final String title;

  EditDetailsScreen({this.sleepData, this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Sync(
              title: title,
              sleepData: sleepData,
            ),
            SizedBox(
              height: 10,
            ),
            FlatButton(
                child: Text('Daten bearbeiten'),
                onPressed: () {
                  Navigator.of(context).pushNamed(EditDataScreen.routeName);
                })
          ],
        ),
      ),
    );
  }
}
