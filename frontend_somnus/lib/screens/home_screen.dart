import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/database_helper.dart';
import 'package:loading_overlay/loading_overlay.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper.instance;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somnus',
      debugShowCheckedModeBanner: false,
      home: LoadingOverlay(
        child: Scaffold(
          body: Center(
            /*child: RaisedButton(
              onPressed: bleDeviceController.reset,
              child: Text("Reset BLE Connection"),
            ),
            child: RaisedButton(
              onPressed: _writeData,
              child: Text("write data to file"),
            ),*/
          ),
        ),
        isLoading: _isLoading,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}
