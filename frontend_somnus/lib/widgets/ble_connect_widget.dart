import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/ecb.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'singletons/ble_device_controller.dart';

class BleConnect extends StatefulWidget {
  @override
  _BleConnectState createState() => _BleConnectState();
}

class _BleConnectState extends State<BleConnect> {
  Service immediateAlertService;
  Characteristic authChar;
  Characteristic immediateAlertChar;

  bool _bleManagerScanning = false;
  bool _isLoading = false;
  List<Peripheral> bleDevices = new List<Peripheral>();

  @override
  void initState() {
    super.initState();
    _localInitStateAsync();
    //_bleConnectFuture = _bleTest();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  void _localInitStateAsync () async {
    // TODO: if bluetooth is on
    // TODO: after connect, close screen automatically
    // TODO: automatically reconnect, when device was out of range and then returns
    await bleDeviceController.reset();

    if (await _checkPermissions()) {
      bleDeviceController.bleManager = BleManager();
      await bleDeviceController.bleManager.createClient();
      _scanForBleDevices();
    } else {
      print("Permissions not accepted. Closing app.");
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  @override
  Widget build(BuildContext context) {
    var _scanForBleDevicesOnPressed;

    if (_bleManagerScanning) {
      _scanForBleDevicesOnPressed = null;
    } else {
      _scanForBleDevicesOnPressed = _scanForBleDevices;
    }

    return MaterialApp(
      title: "test",
        home: LoadingOverlay(
            child: Column(
                children: <Widget>[
                RaisedButton(
                  onPressed: _scanForBleDevicesOnPressed,
                  child: Text("Scan for BLE devices"),
                ),
                Container(
                  child: new Expanded(
                    child: ListView.builder(
                      itemCount: bleDevices.length,
                      padding: EdgeInsets.all(1),
                      itemBuilder: (context, index){
                        return Card(
                          child: ListTile(
                            onTap: () async {
                              // TODO: Add loading circle when connecting
                              _selectBleDevice(bleDevices[index], context);
                              },
                            title: Text(bleDevices[index].name),
                            subtitle: Text("ID: " + bleDevices[index].identifier),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ]
          ),
          isLoading: _isLoading,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
      )
    );
  }

  Future<void> _selectBleDevice(Peripheral selectedDevice, BuildContext localContext) async {
    if (bleDeviceController.fitnessTracker != null) {
      if (await bleDeviceController.fitnessTracker.isConnected()) {
        bleDeviceController.fitnessTracker.disconnectOrCancelConnection();
      }
    }

    bleDeviceController.fitnessTracker = selectedDevice;

    setState(() { _isLoading = true;});

    if (await _connectToBleDevice()) {
      print("Connected to BLE device.");
      
      if (await _bleDeviceIsMiBand()) {
        await _authenticateMiBand();
      } else {
        if (await bleDeviceController.fitnessTracker.isConnected()) {
          bleDeviceController.fitnessTracker.disconnectOrCancelConnection();
        }

        setState(() { _isLoading = false;});
        _showDialog("Device not compatible", "The selected device is not "
            "compatible with this app. Choose another device or check the "
            "manual for compatible devices.");
        print("Disconnected from BLE device.");
      }
    }
  }
  
  Future<bool> _bleDeviceIsMiBand() async {
    bool service0Present = false;
    bool service1Present = false;

    await _getAllServices();

    bleDeviceController.fitnessTrackerServices.forEach((element) {
      if (element.uuid == bleDeviceController.uuidMiBandService0) {
        service0Present = true;
        bleDeviceController.miBandService0 = element;
      } else if (element.uuid == bleDeviceController.uuidMiBandService1) {
        service1Present = true;
        bleDeviceController.miBandService1 = element;
      }
    });

    return (service0Present && service1Present);
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [new FlatButton(
            child: Text("Okay"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )],
        );
      },
    );
  }

  @override
  void dispose() {
    //accelDataAliveTimer?.cancel();
    super.dispose();
  }

  Future<void> _authenticateMiBand() async {
    List<Characteristic> miBandSrvChars;

    // get authentication characteristic
    miBandSrvChars = await bleDeviceController.fitnessTracker.characteristics(bleDeviceController.miBandService1.uuid);
    miBandSrvChars.forEach((element) {
      if (element.uuid == bleDeviceController.uuidCharAuth) {
        authChar = element;
      }
    });

    // set notifications on authentication char
    if (authChar.isNotifiable) {
      await authChar.write(bleDeviceController.setNotifTrueCmd, false);
      authChar.monitor().listen((data) {
        _handleAuthNotification(data);
      });

      await _sendSecretKeyToBand();
    }
  }

  Future<void> _handleAuthNotification(Uint8List data) async {
    bool authenticationFailed = false;

    if (data[0] == 16 && data[1] == 1 && data[2] == 1) {
      await _requestRand();
    } else if (data[0] == 16 && data[1] == 1 && data[2] == 4) {
      print("Error - Key sending failed.");
      authenticationFailed = true;
    } else if (data[0] == 16 && data[1] == 2 && data[2] == 1) {
      await _sendEncrRand(data.sublist(3));
    } else if (data[0] == 16 && data[1] == 2 && data[2] == 4) {
      print("Error - Request random number failed.");
      authenticationFailed = true;
    } else if (data[0] == 16 && data[1] == 3 && data[2] == 1) {
      print("AUTHENTICATED!!!");
      setState(() { _isLoading = false;});
      ForegroundService.notification.setText(DEVICE_CONNECTED);
      _showDialog("Connection success", "Your device is connected.");
      await _printServicesAndChars();
      bleDeviceController.startReceivingRawSensorData();
    } else if (data[0] == 16 && data[1] == 3 && data[2] == 4) {
      print("Error - Encryption failed.");
      authenticationFailed = true;
    } else {
      print("Error - Authentication failed for unknown reason.");
      authenticationFailed = true;
    }

    if (authenticationFailed) {
      if (await bleDeviceController.fitnessTracker.isConnected()) {
        bleDeviceController.fitnessTracker.disconnectOrCancelConnection();
      }
      setState(() { _isLoading = false;});
      _showDialog("Connection error", "The authentication process failed. " +
          "Make sure the device is near and Bluetooth is enabled. Then try " +
          "again.\n\nIf the error remains, make sure the device is compatible " +
          "(For more information see the manual).");
    }
  }

  Future<void> _printServicesAndChars() async {
    List<Characteristic> chars;
    String serviceWithChars;
    print("Printing all services");

    for (Service service in bleDeviceController.fitnessTrackerServices) {
      serviceWithChars = "";
      serviceWithChars += "- ${service.uuid}\n";
      chars = await bleDeviceController.fitnessTracker.characteristics(service.uuid);
      chars.forEach((characteristic) {
        serviceWithChars += "--- ${characteristic.uuid}\n";
      });

      print(serviceWithChars);
    }
  }

  Future<void> _sendSecretKeyToBand() async {
    Uint8List buffer = Uint8List.fromList(
        [...bleDeviceController.sendSecretKeyCmd.toList(), ...bleDeviceController.secretKey.toList()]);
    await authChar.write(buffer, false);
  }

  Future<void> _requestRand() async {
    await authChar.write(bleDeviceController.sendRandCmd, false);
  }

  Future<void> _sendEncrRand(Uint8List randomNumber) async {
    Uint8List encryptedRandomNumber = _encrypt(randomNumber);
    Uint8List buffer =
    Uint8List.fromList([...bleDeviceController.sendEncrKeyCmd, ...encryptedRandomNumber]);
    await authChar.write(buffer, false);
  }

  Uint8List _encrypt(Uint8List plainText) {
    BlockCipher cipher = ECBBlockCipher(AESFastEngine());
    cipher.init(true, KeyParameter(bleDeviceController.secretKey));
    Uint8List cipherText = cipher.process(plainText);
    return cipherText;
  }

  Future<void> _getAllServices() async {
    await bleDeviceController.fitnessTracker.discoverAllServicesAndCharacteristics();
    bleDeviceController.fitnessTrackerServices = await bleDeviceController.fitnessTracker.services(); //getting all services
    bleDeviceController.fitnessTrackerServices.forEach((element) {
      print(element.uuid);
    });
  }

  Future<void> _scanForBleDevices() async {
    if (bleDeviceController.fitnessTracker != null) {
      if (await bleDeviceController.fitnessTracker.isConnected()) {
        bleDeviceController.fitnessTracker.disconnectOrCancelConnection();
      }
    }

    setState(() {
      bleDevices = new List<Peripheral>();
      _bleManagerScanning = true;
    });
    BluetoothState currentState = await bleDeviceController.bleManager.bluetoothState();

    if (currentState == BluetoothState.POWERED_ON) {
      Stopwatch s = new Stopwatch();
      s.start();
      await for (ScanResult scanResult in bleDeviceController.bleManager.startPeripheralScan()) {
        if (scanResult.peripheral.name != null) {
          if (!_deviceInList(bleDevices, scanResult.peripheral.identifier)) {
            print("Peripheral { id: ${scanResult.peripheral.identifier}, name: ${scanResult.peripheral.name}, rssi: ${scanResult.peripheral.rssi}}");
            setState(() {
              bleDevices.add(scanResult.peripheral);
            });
          }
        }

        // after 10 seconds stop scan
        if (s.elapsedMilliseconds >= 10000) {
          bleDeviceController.bleManager.stopPeripheralScan();
          print("Stopped BLE Scan");
          setState(() {
            _bleManagerScanning = false;
          });
        }

        if (!_bleManagerScanning) {
          return;
        }
      }
    }
  }

  bool _deviceInList (List<Peripheral> devices, String id) {
    bool devicePresent = false;

    devices.forEach ((element) {
      if (element.identifier == id) {
        devicePresent = true;
        return;
      }
    });

    return devicePresent;
  }

  Future<bool> _connectToBleDevice () async {
    if (_bleManagerScanning) {
      bleDeviceController.bleManager.stopPeripheralScan();
      setState(() {
        _bleManagerScanning = false;
      });
    }

    print("Connecting to peripheral { id: ${bleDeviceController.fitnessTracker.identifier}, name: ${bleDeviceController.fitnessTracker.name}");
    bleDeviceController.fitnessTracker.observeConnectionState(
        emitCurrentValue: true, completeOnDisconnect: true)
        .listen((connectionState) {
          print("Peripheral ${bleDeviceController.fitnessTracker.identifier} connection state is $connectionState.");
    });

    try {
      await bleDeviceController.fitnessTracker.connect();
    } catch (e) {
      return false;
    }

    return await bleDeviceController.fitnessTracker.isConnected();
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