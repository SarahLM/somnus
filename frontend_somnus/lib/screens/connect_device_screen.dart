import 'package:flutter/material.dart';
import '../widgets/ble_connect_widget.dart';

class ConnectDeviceScreen extends StatefulWidget {
  @override
  _ConnectDeviceScreenState createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Connect Device",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.normal),
        ),
      ),
      body: Center(
        child: BleConnect(),
      ),
    );
  }
}
