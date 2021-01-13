import 'package:flutter/material.dart';
import '../widgets/ble_connect_widget.dart';

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
          child: BleConnect(),
        ),
      ),
    );
  }
}
