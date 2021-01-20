import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somnus',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          /*child: RaisedButton(
            onPressed: bleDeviceController.reset,
            child: Text("Reset BLE Connection"),
          ),*/
        ),
      ),
    );
  }
}
