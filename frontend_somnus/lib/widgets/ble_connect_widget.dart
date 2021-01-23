import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'singletons/ble_device_controller.dart';

const String CONNECTION_TIP_SELECT_DEVICE = "Select your device from the list.";
const String CONNECTION_TIP_PRESS_BUTTON = "Press the button on the MiBand when it vibrates.";

class BleConnect extends StatefulWidget {
  @override
  _BleConnectState createState() => _BleConnectState();
}

class _BleConnectState extends State<BleConnect> {
  Service immediateAlertService;
  Characteristic immediateAlertChar;

  bool _bleManagerScanning = false;
  bool _isLoading = false;
  bool _connectedToMiBand = false;
  List<Peripheral> bleDevices = new List<Peripheral>();
  List<TextSpan> _connectionTip = new List();

  @override
  void initState() {
    super.initState();
    _localInitStateAsync();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  void _localInitStateAsync () async {
    // TODO: automatically reconnect, when device was out of range and then returns
    await bleDeviceController.reset();
    _connectedToMiBand = false;
    _connectionTip.add(new TextSpan(text: CONNECTION_TIP_SELECT_DEVICE));

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
        home: LoadingOverlay(
            child: Column(
                children: <Widget>[
                  Container(
                    child: RichText(
                      key: Key("ConnectionTipRichText"),
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                        children: _connectionTip,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    padding: EdgeInsets.fromLTRB(40, 40, 40, 20),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child:FlatButton(
                      key: Key("RefreshButton"),
                      onPressed: _scanForBleDevicesOnPressed,
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Image.asset('assets/images/refresh_black.png', width: 48.0),
                      disabledColor: Colors.grey,
                      minWidth: 55,
                      height: 55,
                    ),
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
          ),
    );
  }

  Future<void> _selectBleDevice(Peripheral selectedDevice, BuildContext localContext) async {
    if (bleDeviceController.fitnessTracker != null) {
      if (await bleDeviceController.fitnessTracker.isConnected()) {
        bleDeviceController.fitnessTracker.disconnectOrCancelConnection();
      }
    }

    bleDeviceController.fitnessTracker = selectedDevice;

    setState(() { _isLoading = true; });

    if (await _connectToBleDevice()) {
      print("Connected to BLE device.");
      
      if (await bleDeviceController.bleDeviceIsMiBand()) {
        setState(() {
          _connectionTip = new List();
          _connectionTip.add(new TextSpan(text: CONNECTION_TIP_PRESS_BUTTON));
        });
        await bleDeviceController.authenticateMiBand(_authenticationFinish);
      } else {
        if (await bleDeviceController.fitnessTracker.isConnected()) {
          bleDeviceController.fitnessTracker.disconnectOrCancelConnection();
        }

        setState(() {
          _isLoading = false;
          _connectionTip = new List();
          _connectionTip.add(new TextSpan(text: CONNECTION_TIP_SELECT_DEVICE));
        });
        _showDialog("Device not compatible", "The selected device is not "
            "compatible with this app. Choose another device or check the "
            "manual for compatible devices.");
        print("Disconnected from BLE device.");
      }
    } else {
      setState(() {
        _isLoading = false;
        _connectionTip = new List();
        _connectionTip.add(new TextSpan(text: CONNECTION_TIP_SELECT_DEVICE));
      });
      _showDialog("Device not compatible", "The selected device is not "
          "compatible with this app. Choose another device or check the "
          "manual for compatible devices.");
      print("Disconnected from BLE device.");
    }
  }

  void _authenticationFinish(bool authenticationSuccess) async {
    if (authenticationSuccess) {
      setState(() { _isLoading = false;});
      _connectedToMiBand = true;
      _showDialog("Connection success", "Your device is connected.");
      await _printServicesAndChars();
    } else {
      if (await bleDeviceController.fitnessTracker.isConnected()) {
        bleDeviceController.fitnessTracker.disconnectOrCancelConnection();
      }
      setState(() {
        _isLoading = false;
        _connectionTip = new List();
        _connectionTip.add(new TextSpan(text: CONNECTION_TIP_SELECT_DEVICE));
      });
      _showDialog("Connection error", "The authentication process failed. " +
          "Make sure the device is near and Bluetooth is enabled. Then try " +
          "again.\n\nIf the error remains, make sure the device is compatible " +
          "(For more information see the manual).");
    }
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
              if (_connectedToMiBand) {
                Navigator.pop(context);
              }
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

  Future<void> _scanForBleDevices() async {
    if (bleDeviceController.fitnessTracker != null) {
      if (await bleDeviceController.fitnessTracker.isConnected()) {
        bleDeviceController.fitnessTracker.disconnectOrCancelConnection();
      }
    }

    setState(() {
      _connectionTip = new List();
      _connectionTip.add(new TextSpan(text: CONNECTION_TIP_SELECT_DEVICE));
    });

    BluetoothState currentState = await bleDeviceController.bleManager.bluetoothState();

    if (currentState != BluetoothState.POWERED_ON) {
      await bleDeviceController.bleManager.enableRadio();
      currentState = await bleDeviceController.bleManager.bluetoothState();
    }

    if (currentState == BluetoothState.POWERED_ON) {
      setState(() {
        bleDevices = new List<Peripheral>();
        _bleManagerScanning = true;
      });

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