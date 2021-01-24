import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //title: Text(
        //"Analyse deiner Aktivitäten",
        //style: TextStyle(fontSize: 26, fontWeight: FontWeight.normal),
        //),
      ),
      body: Center(),
    );
  }
}
