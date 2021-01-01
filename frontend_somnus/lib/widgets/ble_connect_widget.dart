import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/ecb.dart';

class BleConnect extends StatefulWidget {
  @override
  _BleConnectState createState() => _BleConnectState();
}

class _BleConnectState extends State<BleConnect> {
  Uint8List secretKey = Uint8List.fromList(
      [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 64, 65, 66, 67, 68, 69]);
  Uint8List setNotifTrueCmd = Uint8List.fromList([1, 0]);
  Uint8List sendSecretKeyCmd = Uint8List.fromList([1, 0]);
  Uint8List sendEncrKeyCmd = Uint8List.fromList([3, 0]);
  Uint8List sendRandCmd = Uint8List.fromList([2, 0]);
  Uint8List sensorRawDataCmd = Uint8List.fromList([1, 1, 25]);
  String uuidMiBandService0 = "0000fee0-0000-1000-8000-00805f9b34fb";
  String uuidMiBandService1 = "0000fee1-0000-1000-8000-00805f9b34fb";
  String uuidServiceImmediateAlert = "00001802-0000-1000-8000-00805f9b34fb";
  String uuidCharAuth = "00000009-0000-3512-2118-0009af100700";
  String uuidCharAuthDesc = "00002902-0000-1000-8000-00805f9b34fb";
  String uuidCharImmediateAlert = "00002a06-0000-1000-8000-00805f9b34fb";
  String uuidCharSensor = "00000001-0000-3512-2118-0009af100700";
  String uuidCharAccelerometer = "00000002-0000-3512-2118-0009af100700";

  BleManager bleManager;
  Peripheral fitnessTracker;
  List<Service> fitnessTrackerServices;
  Service miBandService0;
  Service miBandService1;
  Service immediateAlertService;
  Characteristic authChar;
  Characteristic immediateAlertChar;
  Characteristic sensorChar;
  Characteristic accelerometerChar;

  bool _authenticated = false;
  bool _highAlerted = false;
  bool _receivingRawSensorData = false;
  bool _bleManagerScanning = false;
  int _rawDataPacketsCounter;
  Future _bleConnectFuture;
  Timer accelDataAliveTimer;
  List<Peripheral> bleDevices = new List<Peripheral>();

  @override
  void initState() {
    super.initState();
    _localInitStateAsync();
    //_bleConnectFuture = _bleTest();
  }

  void _localInitStateAsync () async {
    // TODO: if bluetooth is on
    if (await _checkPermissions()) {
      bleManager = BleManager();
      await bleManager.createClient();
      _scanForBleDevices();
    } else {
      print("Permissions not accepted. Closing app.");
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  @override
  Widget build(BuildContext context) {
    var _alertMildBtnOnPressed;
    var _alertHighBtnOnPressed;
    var _startRawDataOnPressed;
    var _stopRawDataOnPressed;
    var _scanForBleDevicesOnPressed;

    if (_bleManagerScanning) {
      _scanForBleDevicesOnPressed = null;
    } else {
      _scanForBleDevicesOnPressed = _scanForBleDevices;
    }

    if (_authenticated) {
      _alertMildBtnOnPressed = _alertMildMiBand;
      _alertHighBtnOnPressed = _alertHighMiBand;

      if (_receivingRawSensorData) {
        _startRawDataOnPressed = null;
        _stopRawDataOnPressed = _stopReceivingRawSensorData;
      } else {
        _startRawDataOnPressed = _startReceivingRawSensorData;
        _stopRawDataOnPressed = null;
      }
    }

    return Container(
        alignment: Alignment.topCenter,
        child: Column(
            children: <Widget>[
              /*FutureBuilder<Widget>(
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
              ),*/
              RaisedButton(
                onPressed: _alertMildBtnOnPressed,
                child: Text("Alert MiBand (Mild)"),
              ),
              RaisedButton(
                onPressed: _alertHighBtnOnPressed,
                child: Text("Alert MiBand (High)"),
              ),
              RaisedButton(
                onPressed: _startRawDataOnPressed,
                child: Text("Get Accelerometer Raw Data"),
              ),
              RaisedButton(
                onPressed: _stopRawDataOnPressed,
                child: Text("Stop Accelerometer Raw Data"),
              ),
              RaisedButton(
                onPressed: _scanForBleDevicesOnPressed,
                child: Text("Scan for BLE devices"),
              ),
              new Expanded(
                child: ListView.builder(
                  itemCount: bleDevices.length,
                  padding: EdgeInsets.all(1),
                  itemBuilder: (context, index){
                    return Card(
                      child: ListTile(
                        onTap: () async {
                          _selectBleDevice(bleDevices[index]);
                          },
                        title: Text(bleDevices[index].name),
                        subtitle: Text("ID: " + bleDevices[index].identifier),
                      ),
                    );
                  },
                ),
              ),
            ]
        )
    );
  }

  Future<bool> _selectBleDevice(Peripheral selectedDevice) async {
    fitnessTracker = selectedDevice;

    if (await _connectToBleDevice()) {
      print("Connected to BLE device.");
      
      if (await _bleDeviceIsMiBand()) {
        await _authenticateMiBand();
        await _printServicesAndChars();
        return true;
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Device not compatible"),
                content: Text("The selected device is not compatible with this"
                      "app. Choose another device or check the manual for "
                      "compatible devices."),
                actions: [new FlatButton(
                  child: Text("Okay"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )],
              );
            },
        );
        fitnessTracker.disconnectOrCancelConnection();
        print("Disconnected from BLE device.");
      }
    }

    return false;
  }
  
  Future<bool> _bleDeviceIsMiBand() async {
    bool service0Present = false;
    bool service1Present = false;

    await _getAllServices();

    fitnessTrackerServices.forEach((element) {
      if (element.uuid == uuidMiBandService0) {
        service0Present = true;
        miBandService0 = element;
      } else if (element.uuid == uuidMiBandService1) {
        service1Present = true;
        miBandService1 = element;
      }
    });

    return (service0Present && service1Present);
  }

  Future<void> _alertMildMiBand() async {
    immediateAlertService = fitnessTrackerServices.firstWhere((e) => e.uuid == uuidServiceImmediateAlert);
    immediateAlertChar = (await immediateAlertService.characteristics())
        .firstWhere((e) => e.uuid == uuidCharImmediateAlert);
    immediateAlertChar.write(Uint8List.fromList([1]), false);
  }

  Future<void> _alertHighMiBand() async {
    immediateAlertService = fitnessTrackerServices.firstWhere((e) => e.uuid == uuidServiceImmediateAlert);
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

  Future<void> _startReceivingRawSensorData() async {
    List<Characteristic> miBandSrvChars;

    // get characteristic for sensors
    miBandSrvChars = await fitnessTracker.characteristics(miBandService0.uuid);
    miBandSrvChars.forEach((element) {
      if (element.uuid == uuidCharSensor) {
        sensorChar = element;
      } else if (element.uuid == uuidCharAccelerometer) {
        accelerometerChar = element;
      }
    });

    // set raw data output and notifications
    if (accelerometerChar.isNotifiable) {
      Stopwatch s = new Stopwatch();

      _enableSendingRawSensorData();
      _rawDataPacketsCounter = 0;
      s.start();
      // start listening for accelerometer data
      accelerometerChar.monitor().listen((data) {
        _handleRawAccelerometerData(data);
        //print("elapsed seconds: ${s.elapsedMilliseconds/1000}");
      });

      // send alive packages so accelerometer data is continiously sent
      accelDataAliveTimer = Timer.periodic((Duration(seconds:30)), (Timer t) => _enableSendingRawSensorData());
      setState(() {
        _receivingRawSensorData = true;
      });
    }
  }

  Future<void> _enableSendingRawSensorData() async {
    // enable sensor raw data
    await sensorChar.write(sensorRawDataCmd, false);
    await sensorChar.write(Uint8List.fromList([2]), false);
  }

  Future<void> _stopReceivingRawSensorData() async {
    await sensorChar.write(Uint8List.fromList([3]), false);
    setState(() {
      _receivingRawSensorData = false;
    });
  }

  void _handleRawAccelerometerData(Uint8List data) {
    String accelData = "";
    // first byte is always one
    if (data[0] == 1) {
      // second byte is a counter
      // if counter is expected value, take the accelerometer data, else ignore
      if (data[1] == _rawDataPacketsCounter) {
        int counter = 0;

        _rawDataPacketsCounter = (_rawDataPacketsCounter == 255) ? 0 : ++_rawDataPacketsCounter;

        // the next 3 x 2 bytes are the accelerometer data
        // 2 bytes: first byte is the value, second is the sign (0=+, 255=-)
        // first 2 bytes = x, second 2 bytes = y, third 2 bytes = z
        // there can be 1, 2 or 3 XYZ values
        for (int i=2; i<data.length; i++) {
          // if even
          if (i % 2 == 0) {
            accelData += (counter == 0) ? "x:" : "";
            accelData += (counter == 1) ? "y:" : "";
            accelData += (counter == 2) ? "z:" : "";
            counter = (counter == 2) ? 0 : ++counter;

            accelData += (data[i+1] == 0) ? "+" : "-";
            accelData += (data[i].toDouble() / 255.toDouble()).toString() + " ";

            /*
            if (counter == 0) {
              accelData = "x: ";
              accelData += (data[i+1] == 0) ? "+" : "-";

              accelData += (data[i].toDouble() / 255.toDouble()).toString() + "\n";
              print(accelData);
            } else if (counter == 1) {
              accelData = "y: ";
              accelData += (data[i+1] == 0) ? "+" : "-";

              accelData += (data[i].toDouble() / 255.toDouble()).toString() + "\n";
              print(accelData);
            } else if (counter == 2) {
              accelData = "z: ";
              accelData += (data[i+1] == 0) ? "+" : "-";

              accelData += (data[i].toDouble() / 255.toDouble()).toString() + "\n";
              print(accelData);
            }

            counter = (counter == 2) ? 0 : ++counter;*/
          }
        }

        //print("data packet nr. ${data[1]}");
        print(accelData);
        print("${data[2]}, ${data[3]}, ${data[4]}, ${data[5]}, ${data[6]}, ${data[7]}");
      }
    }
  }

  @override
  void dispose() {
    accelDataAliveTimer?.cancel();
    super.dispose();
  }

  Future<void> _authenticateMiBand() async {
    List<Characteristic> miBandSrvChars;

    // get authentication characteristic
    miBandSrvChars = await fitnessTracker.characteristics(miBandService1.uuid);
    miBandSrvChars.forEach((element) {
      if (element.uuid == uuidCharAuth) {
        authChar = element;
      }
    });

    // set notifications on authentication char
    if (authChar.isNotifiable) {
      await authChar.write(setNotifTrueCmd, false);
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
    String serviceWithChars;
    print("Printing all services");

    for (Service service in fitnessTrackerServices) {
      serviceWithChars = "";
      serviceWithChars += "- ${service.uuid}\n";
      chars = await fitnessTracker.characteristics(service.uuid);
      chars.forEach((characteristic) {
        serviceWithChars += "--- ${characteristic.uuid}\n";
      });

      print(serviceWithChars);
    }
  }

  Future<void> _sendSecretKeyToBand() async {
    Uint8List buffer = Uint8List.fromList(
        [...sendSecretKeyCmd.toList(), ...secretKey.toList()]);
    await authChar.write(buffer, false);
  }

  Future<void> _requestRand() async {
    await authChar.write(sendRandCmd, false);
  }

  Future<void> _sendEncrRand(Uint8List randomNumber) async {
    Uint8List encryptedRandomNumber = _encrypt(randomNumber);
    Uint8List buffer =
    Uint8List.fromList([...sendEncrKeyCmd, ...encryptedRandomNumber]);
    await authChar.write(buffer, false);
  }

  Uint8List _encrypt(Uint8List plainText) {
    BlockCipher cipher = ECBBlockCipher(AESFastEngine());
    cipher.init(true, KeyParameter(secretKey));
    Uint8List cipherText = cipher.process(plainText);
    return cipherText;
  }

  Future<void> _getAllServices() async {
    await fitnessTracker.discoverAllServicesAndCharacteristics();
    fitnessTrackerServices = await fitnessTracker.services(); //getting all services
    fitnessTrackerServices.forEach((element) {
      print(element.uuid);
    });
  }

  Future<void> _scanForBleDevices() async {
    setState(() {
      bleDevices = new List<Peripheral>();
      _bleManagerScanning = true;
    });
    BluetoothState currentState = await bleManager.bluetoothState();

    if (fitnessTracker != null) {
      if (await fitnessTracker.isConnected()) {
        fitnessTracker.disconnectOrCancelConnection();
      }
    }

    if (currentState == BluetoothState.POWERED_ON) {
      Stopwatch s = new Stopwatch();
      s.start();
      await for (ScanResult scanResult in bleManager.startPeripheralScan()) {
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
          bleManager.stopPeripheralScan();
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
      bleManager.stopPeripheralScan();
      setState(() {
        _bleManagerScanning = false;
      });
    }

    print("Connecting to peripheral { id: ${fitnessTracker.identifier}, name: ${fitnessTracker.name}");
    fitnessTracker.observeConnectionState(
        emitCurrentValue: true, completeOnDisconnect: true)
        .listen((connectionState) {
          print("Peripheral ${fitnessTracker.identifier} connection state is $connectionState.");
    });

    try {
      await fitnessTracker.connect();
    } catch (e) {
      return false;
    }

    return await fitnessTracker.isConnected();
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