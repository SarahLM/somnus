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
        title: Text(
          "Connect Device",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.normal),
        ),
      ),
      body:  Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E1164), Color(0xFF2752E4)]),
        ),
        child: Center(
          child: BleConnect(),
        ),
      )
    );
  }
}
