import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Center(
          child: BleDevices(),
        ),
      ),
    );
  }
}

class BleDevices extends StatefulWidget {
  @override
  _BleDevicesState createState() => _BleDevicesState();
}

class _BleDevicesState extends State<BleDevices> {
  BleManager bleManager;
  Peripheral peripheral;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2,
      textAlign: TextAlign.center,
      child: FutureBuilder<Widget>(
        future: _authenticateToMiBand(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          List<Widget> children = <Widget>[Text("Ble scanning")];
          return Center(
            child: Column(
              children: children,
            )
          );
        })
      );
  }

  Future<Widget> _authenticateToMiBand() async {
    if (await _checkPermissions()){
      if (await _connectToMiBand()) {
        print("connected to mi band");
        await _showCharacteristics();
      }
    }
  }

  Future<void> _showCharacteristics() async {
    print("discovering services");
    await peripheral.discoverAllServicesAndCharacteristics();
    print("service discovery finished");
    List<Service> services = await peripheral.services(); //getting all services

    services.forEach((element) {print(element.uuid);});
  }

  Future<bool> _connectToMiBand() async {
    bleManager = BleManager();
    await bleManager.createClient();
    BluetoothState currentState = await bleManager.bluetoothState();

    if (currentState == BluetoothState.POWERED_ON){
      await for (ScanResult scanResult in bleManager.startPeripheralScan()) {
        if (scanResult.peripheral.name == "MI Band 2") {
          print("Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult.rssi}");
          peripheral = scanResult.peripheral;
          bleManager.stopPeripheralScan();
        }
      };

      peripheral.observeConnectionState(emitCurrentValue: true, completeOnDisconnect: true)
          .listen((connectionState) {
        print("Peripheral ${peripheral.identifier} connection state is $connectionState");
      });
      await peripheral.connect();
      return await peripheral.isConnected();
    }

    return false;
  }

  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.location.request().isGranted) {
        print("Location permission granted");
        return true;
      }

      print("Location permission not granted");
    }

    return false;
  }
}