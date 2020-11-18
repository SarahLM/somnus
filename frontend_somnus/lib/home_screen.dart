import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import './widgets/main_drawer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/ecb.dart';

import 'hypnogram_screen.dart';
import 'analysis_screen.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    BleDevices(),
    HypnogramWidget(Colors.green),
    AnalysisWidget(Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somnus',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Somnus'),
          //title: Image.asset('assets/title.png', fit: BoxFit.cover),
          actions: <Widget>[
            // IconButton(
            //   icon: Icon(
            //     Icons.more_vert,
            //     color: Colors.white,
            //   ),
            //   onPressed: () {
            //     // do something
            //   },
            // )
          ],
          backgroundColor: Colors.purple,
        ),
        drawer: MainDrawer(),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped, // new
          currentIndex: _currentIndex,
          backgroundColor: Colors.purple,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.lightBlue,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.favorite),
              label: 'Hypnogramm',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.analytics), label: 'Analyse')
          ],
        ),
        body: //Center(
            //child: BleDevices(),
            _children[_currentIndex],

        //),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class BleDevices extends StatefulWidget {
  @override
  _BleDevicesState createState() => _BleDevicesState();
}

class _BleDevicesState extends State<BleDevices> {
  Uint8List secretKey = Uint8List.fromList(
      [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 64, 65, 66, 67, 68, 69]);
  Uint8List cmdSetNotifTrue = Uint8List.fromList([1, 0]);
  Uint8List cmdSendSecretKeyCmd = Uint8List.fromList([1, 0]);
  Uint8List cmdSendEncrKeyCmd = Uint8List.fromList([3, 0]);
  Uint8List cmdSendRandCmd = Uint8List.fromList([2, 0]);
  String uuidServiceMiBand = "0000fee1-0000-1000-8000-00805f9b34fb";
  String uuidServiceImmediateAlert = "00001802-0000-1000-8000-00805f9b34fb";
  String uuidCharAuth = "00000009-0000-3512-2118-0009af100700";
  String uuidCharAuthDesc = "00002902-0000-1000-8000-00805f9b34fb";
  String uuidCharImmediateAlert = "00002a06-0000-1000-8000-00805f9b34fb";

  BleManager bleManager;
  Peripheral peripheral;
  List<Service> services;
  List<Characteristic> miBandSrvChars;
  Service miBandService;
  Service immediateAlertService;
  Characteristic authChar;
  Characteristic immediateAlertChar;

  bool _authenticated = false;
  bool _highAlerted = false;
  Future _bleConnectFuture;

  @override
  void initState() {
    super.initState();
    _bleConnectFuture = _bleTest();
  }

  @override
  Widget build(BuildContext context) {
    var _alertMildBtnOnPressed;
    var _alertHighBtnOnPressed;

    if (_authenticated) {
      _alertMildBtnOnPressed = _alertMildMiBand;
      _alertHighBtnOnPressed = _alertHighMiBand;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("BLE Tests"),
      ),
      body: Center(
          child: Column(
              children: <Widget>[
                FutureBuilder<Widget>(
                    future: _bleConnectFuture,
                    builder: (context, snapshot) {
                      var msg = "Connecting to MiBand";

                      if (snapshot.connectionState == ConnectionState.done) {
                        msg = "MiBand connected!";
                        if (_authenticated) {
                          msg = "MiBand connected and authenticated!";
                        }
                      }

                      return Text(msg);
                    }
                ),
                RaisedButton(
                  onPressed: _alertMildBtnOnPressed,
                  child: Text("Alert MiBand (Mild)"),
                ),
                RaisedButton(
                  onPressed: _alertHighBtnOnPressed,
                  child: Text("Alert MiBand (High)"),
                ),
              ]
          )
      ),
    );
  }

  Future<Widget> _bleTest() async {
    if (await _checkPermissions()) {
      if (await _connectToMiBand()) {
        print("connected to mi band");
        await _getAllServices();
        await _authenticateMiBand();
        await _printServicesAndChars();
      }
    }

    return Text("MiBand connected!");
  }

  Future<void> _alertMildMiBand() async {
    immediateAlertService = services.firstWhere((e) => e.uuid == uuidServiceImmediateAlert);
    immediateAlertChar = (await immediateAlertService.characteristics())
        .firstWhere((e) => e.uuid == uuidCharImmediateAlert);
    immediateAlertChar.write(Uint8List.fromList([1]), false);
  }

  Future<void> _alertHighMiBand() async {
    immediateAlertService = services.firstWhere((e) => e.uuid == uuidServiceImmediateAlert);
    immediateAlertChar = (await immediateAlertService.characteristics())
        .firstWhere((e) => e.uuid == uuidCharImmediateAlert);

    if (_highAlerted){
      immediateAlertChar.write(Uint8List.fromList([0]), false);
      _highAlerted = false;
    } else {
      immediateAlertChar.write(Uint8List.fromList([2]), false);
      _highAlerted = true;
    }
  }

  Future<void> _authenticateMiBand() async {
    services.forEach((element) {
      if (element.uuid == uuidServiceMiBand) {
        miBandService = element;
      }
    });

    miBandSrvChars = await peripheral.characteristics(miBandService.uuid);
    miBandSrvChars.forEach((element) {
      if (element.uuid == uuidCharAuth) {
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
      setState(() {
        _authenticated = true;
      });
      print("AUTHENTICATED!!!");
    } else if (data[0] == 16 && data[1] == 3 && data[2] == 4) {
      print("Error - Encryption failed.");
    } else {
      print("Error - Authentication failed for unknown reason.");
    }
  }

  Future<void> _printServicesAndChars() async {
    List<Characteristic> chars;
    String allServicesAndChars = "";

    for (Service service in services) {
      allServicesAndChars += "- ${service.uuid}\n";
      chars = await peripheral.characteristics(service.uuid);
      chars.forEach((characteristic) {
        allServicesAndChars += "--- ${characteristic.uuid}\n";
      });
    }

    print("Printing all services");
    print(allServicesAndChars);
  }

  Future<void> _sendSecretKeyToBand() async {
    Uint8List buffer = Uint8List.fromList(
        [...cmdSendSecretKeyCmd.toList(), ...secretKey.toList()]);
    await authChar.write(buffer, false);
  }

  Future<void> _requestRand() async {
    await authChar.write(cmdSendRandCmd, false);
  }

  Future<void> _sendEncrRand(Uint8List randomNumber) async {
    Uint8List encryptedRandomNumber = _encrypt(randomNumber);
    Uint8List buffer =
        Uint8List.fromList([...cmdSendEncrKeyCmd, ...encryptedRandomNumber]);
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
    services.forEach((element) {
      print(element.uuid);
    });
  }

  Future<bool> _connectToMiBand() async {
    bleManager = BleManager();
    await bleManager.createClient();
    BluetoothState currentState = await bleManager.bluetoothState();

    if (currentState == BluetoothState.POWERED_ON) {
      await for (ScanResult scanResult in bleManager.startPeripheralScan()) {
        if (scanResult.peripheral.name == "MI Band 2") {
          print(
              "Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult.rssi}");
          peripheral = scanResult.peripheral;
          bleManager.stopPeripheralScan();
        }
      }

      peripheral
          .observeConnectionState(
              emitCurrentValue: true, completeOnDisconnect: true)
          .listen((connectionState) {
        print(
            "Peripheral ${peripheral.identifier} connection state is $connectionState");
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
