import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/ecb.dart';

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
  Uint8List secretKey = Uint8List.fromList([48,49,50,51,52,53,54,55,56,57,64,65,66,67,68,69]);
  Uint8List cmdSetNotifTrue = Uint8List.fromList([1,0]);
  Uint8List cmdSendSecretKeyCmd = Uint8List.fromList([1, 0]);
  Uint8List cmdSendEncrKeyCmd = Uint8List.fromList([3,0]);
  Uint8List cmdSendRandCmd = Uint8List.fromList([2,0]);
  String uuidServiceMiBand = "0000fee1-0000-1000-8000-00805f9b34fb";
  String uuidCharAuth = "00000009-0000-3512-2118-0009af100700";
  String uuidCharAuthDesc = "00002902-0000-1000-8000-00805f9b34fb";

  BleManager bleManager;
  Peripheral peripheral;
  List<Service> services;
  Service miBandService;
  List<Characteristic> miBandSrvChars;
  Characteristic authChar;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2,
      textAlign: TextAlign.center,
      child: FutureBuilder<Widget>(
        future: _bleTest(),
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

  Future<Widget> _bleTest() async {
    if (await _checkPermissions()){
      if (await _connectToMiBand()) {
        print("connected to mi band");
        await _getAllServices();
        await _authenticateMiBand();
      }
    }
  }

  Future<void> _authenticateMiBand() async {
    services.forEach((element) {
      if (element.uuid == uuidServiceMiBand){
        miBandService = element;
      }
    });

    miBandSrvChars = await peripheral.characteristics(miBandService.uuid);
    miBandSrvChars.forEach((element) {
      if (element.uuid == uuidCharAuth){
        authChar = element;
      }
    });

    if (authChar.isNotifiable) {
      await authChar.write(cmdSetNotifTrue, false);
      authChar.monitor().listen((data) {
        _handleAuthNotification(data);
      });

      await _sendSecretKeyToBand();
    }
  }
  
  Future<void> _handleAuthNotification(Uint8List data) async {
    if (data[0] == 16 && data[1] == 1 && data[2] == 1) {
      await _requestRand();
    } else if (data[0] == 16 && data[1] == 1 && data[2] == 4) {
      print("Error - Key sending failed.");
    } else if (data[0] == 16 && data[1] == 2 && data[2] == 1) {
      await _sendEncrRand(data.sublist(3));
    } else if (data[0] == 16 && data[1] == 2 && data[2] == 4) {
      print("Error - Request random number failed.");
    } else if (data[0] == 16 && data[1] == 3 && data[2] == 1) {
      print("AUTHENTICATED!!!");
    } else if (data[0] == 16 && data[1] == 3 && data[2] == 4) {
      print("Error - Encryption failed.");
    } else {
      print("Error - Authentication failed for unknown reason.");
    }
  }

  Future<void> _sendSecretKeyToBand() async {
    Uint8List buffer = Uint8List.fromList([...cmdSendSecretKeyCmd.toList(), ...secretKey.toList()]);
    await authChar.write(buffer, false);
}

  Future<void> _requestRand() async {
    await authChar.write(cmdSendRandCmd, false);
  }

  Future<void> _sendEncrRand(Uint8List randomNumber) async {
    Uint8List encryptedRandomNumber = _encrypt(randomNumber);
    Uint8List buffer = Uint8List.fromList([...cmdSendEncrKeyCmd, ...encryptedRandomNumber]);
    await authChar.write(buffer, false);
  }

  Uint8List _encrypt(Uint8List plainText) {
    BlockCipher cipher = ECBBlockCipher(AESFastEngine());
    cipher.init(true, KeyParameter(secretKey));
    Uint8List cipherText = cipher.process(plainText);
    return cipherText;
  }

  Future<void> _getAllServices() async {
    await peripheral.discoverAllServicesAndCharacteristics();
    services = await peripheral.services(); //getting all services
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
        return true;
      }
    }

    return false;
  }
}