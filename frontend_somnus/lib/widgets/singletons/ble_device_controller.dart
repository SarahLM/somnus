import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

const String DEVICE_NOT_CONNECTED = "Connect your fitness tracker.";
const String DEVICE_CONNECTED = "Fitness tracker connected.";

var bleDeviceController = BleDeviceController();

class BleDeviceController {
  static BleDeviceController _bleDeviceController = new BleDeviceController._internal();

  factory BleDeviceController() {
    return _bleDeviceController;
  }

  BleDeviceController._internal();

  final Uint8List secretKey = Uint8List.fromList(
      [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 64, 65, 66, 67, 68, 69]);
  final Uint8List setNotifTrueCmd = Uint8List.fromList([1, 0]);
  final Uint8List sendSecretKeyCmd = Uint8List.fromList([1, 0]);
  final Uint8List sendEncrKeyCmd = Uint8List.fromList([3, 0]);
  final Uint8List sendRandCmd = Uint8List.fromList([2, 0]);
  final Uint8List sensorRawDataCmd = Uint8List.fromList([1, 1, 25]);
  final String uuidMiBandService0 = "0000fee0-0000-1000-8000-00805f9b34fb";
  final String uuidMiBandService1 = "0000fee1-0000-1000-8000-00805f9b34fb";
  final String uuidServiceImmediateAlert = "00001802-0000-1000-8000-00805f9b34fb";
  final String uuidCharAuth = "00000009-0000-3512-2118-0009af100700";
  final String uuidCharAuthDesc = "00002902-0000-1000-8000-00805f9b34fb";
  final String uuidCharImmediateAlert = "00002a06-0000-1000-8000-00805f9b34fb";
  final String uuidCharSensor = "00000001-0000-3512-2118-0009af100700";
  final String uuidCharAccelerometer = "00000002-0000-3512-2118-0009af100700";

  BleManager bleManager;
  Peripheral fitnessTracker;

  List<Service> fitnessTrackerServices;
  Service miBandService0;
  Service miBandService1;

  int _rawDataPacketsCounter;
  Characteristic _sensorChar;
  Characteristic _accelerometerChar;
  Timer _accelDataAliveTimer;

  Future<void> startReceivingRawSensorData() async {
    List<Characteristic> miBandSrvChars;

    // get characteristic for sensors
    miBandSrvChars = await fitnessTracker.characteristics(miBandService0.uuid);
    miBandSrvChars.forEach((element) {
      if (element.uuid == uuidCharSensor) {
        _sensorChar = element;
      } else if (element.uuid == uuidCharAccelerometer) {
        _accelerometerChar = element;
      }
    });

    // set raw data output and notifications
    if (_accelerometerChar.isNotifiable) {
      Stopwatch s = new Stopwatch();

      _enableSendingRawSensorData();
      _rawDataPacketsCounter = 0;
      s.start();
      // start listening for accelerometer data
      _accelerometerChar.monitor().listen((data) {
        _handleRawAccelerometerData(data);
        //print("elapsed seconds: ${s.elapsedMilliseconds/1000}");
      });

      // send alive packages so accelerometer data is continiously sent
      _accelDataAliveTimer = Timer.periodic((Duration(seconds:30)), (Timer t) => _enableSendingRawSensorData());
    }
  }

  Future<void> _enableSendingRawSensorData() async {
    // enable sensor raw data
    await _sensorChar.write(sensorRawDataCmd, false);
    await _sensorChar.write(Uint8List.fromList([2]), false);
  }

  Future<void> _stopReceivingRawSensorData() async {
    await _sensorChar.write(Uint8List.fromList([3]), false);
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
}
