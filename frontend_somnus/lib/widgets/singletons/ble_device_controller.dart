import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/ecb.dart';

import 'accelerometer_data_handler.dart';

const String DEVICE_NOT_CONNECTED = "Connect your fitness tracker.";
const String DEVICE_CONNECTED = "Fitness tracker connected.";

const double ACCEL_MAX_DECIMAL_VALUE = 2;
const double ACCEL_RAW_VALUE_FOR_DECIMAL_ONE = 128;

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
  final Uint8List setNotifFalseCmd = Uint8List.fromList([0, 0]);
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
  Characteristic _authChar;
  Characteristic _sensorChar;
  Characteristic _accelerometerChar;
  Timer _accelDataAliveTimer;
  Timer _accelDataToDBTimer;
  List<double> accelDataSinceLastDBAccess = new List();
  List<double> latestAccelData = new List(3);
  Function(bool) authenticatedCallback;

  Future<void> reset() async {
    if (_accelDataAliveTimer != null) {
      _accelDataAliveTimer.cancel();
    }
    if (_accelDataToDBTimer != null) {
      _accelDataToDBTimer.cancel();
    }
    if (accelDataHandler.isDataToCSVTimerActive()) {
      accelDataHandler.isDataToCSVTimerActive();
    }
    if (accelDataHandler.isDataToBackendTimerActive()) {
      accelDataHandler.cancelDataToBackendTimer();
    }
    if (fitnessTracker != null) {
      if (await fitnessTracker.isConnected()) {
        print("Stopping notifications");
        await _stopReceivingRawSensorData();

        try {
          await bleManager.cancelTransaction("HandleAccelerometerData");
          print("Stopped acceleromater characteristic");
        } catch (e) {
          print("Cancel transaction error");
          print(e);
        }

        try {
          await fitnessTracker.disconnectOrCancelConnection();
          print("Disconnected");
        } catch (e) {
          print("Disconnect error");
          print(e);
          print("Connection state: " + fitnessTracker.isConnected().toString());
        }
      }
    }
    if (bleManager != null) {
      print("BleManager != null");
      print(bleManager);
      try {
        await bleManager.destroyClient();
      } catch (e) {
        print("Error on BLE manager destroy client.");
        print(e);
      }
    }

    bleManager = null;
    fitnessTracker = null;
    fitnessTrackerServices = null;
    miBandService0 = null;
    miBandService1 = null;
    _rawDataPacketsCounter = null;
    _sensorChar = null;
    _accelerometerChar = null;
    accelDataSinceLastDBAccess = new List();
    latestAccelData = new List(3);
  }

  Future<bool> bleDeviceIsMiBand() async {
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

  Future<void> _getAllServices() async {
    await fitnessTracker.discoverAllServicesAndCharacteristics();
    fitnessTrackerServices = await fitnessTracker.services(); //getting all services
    fitnessTrackerServices.forEach((element) {
      print(element.uuid);
    });
  }

  Future<void> authenticateMiBand(Function(bool) callback) async {
    List<Characteristic> miBandSrvChars;

    authenticatedCallback = callback;

    // get authentication characteristic
    miBandSrvChars = await fitnessTracker.characteristics(miBandService1.uuid);
    miBandSrvChars.forEach((element) {
      if (element.uuid == uuidCharAuth) {
        _authChar = element;
      }
    });

    // set notifications on authentication char
    if (_authChar.isNotifiable) {
      await _authChar.write(setNotifTrueCmd, false);
      _authChar.monitor(transactionId: "HandleAuthenticationNotification").listen((data) {
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
      _authenticationProcessFinish(false);
    } else if (data[0] == 16 && data[1] == 2 && data[2] == 1) {
      await _sendEncrRand(data.sublist(3));
    } else if (data[0] == 16 && data[1] == 2 && data[2] == 4) {
      print("Error - Request random number failed.");
      _authenticationProcessFinish(false);
    } else if (data[0] == 16 && data[1] == 3 && data[2] == 1) {
      print("AUTHENTICATED!!!");
      ForegroundService.notification.setText(DEVICE_CONNECTED);
      _authenticationProcessFinish(true);
      startReceivingRawSensorData();
    } else if (data[0] == 16 && data[1] == 3 && data[2] == 4) {
      print("Error - Encryption failed.");
      _authenticationProcessFinish(false);
    } else {
      print("Error - Authentication failed for unknown reason.");
      _authenticationProcessFinish(false);
    }
  }

  void _authenticationProcessFinish(bool authenticated) async {
    // commenting out, because throwing error
    //await _authChar.write(setNotifFalseCmd, false);
    //await bleManager.cancelTransaction("HandleAuthenticationNotification");
    authenticatedCallback(authenticated);
  }

  Future<void> _sendSecretKeyToBand() async {
    Uint8List buffer = Uint8List.fromList(
        [...sendSecretKeyCmd.toList(), ...secretKey.toList()]);
    await _authChar.write(buffer, false);
  }

  Future<void> _requestRand() async {
    await _authChar.write(sendRandCmd, false);
  }

  Future<void> _sendEncrRand(Uint8List randomNumber) async {
    Uint8List encryptedRandomNumber = _encrypt(randomNumber);
    Uint8List buffer =
    Uint8List.fromList([...sendEncrKeyCmd, ...encryptedRandomNumber]);
    await _authChar.write(buffer, false);
  }

  Uint8List _encrypt(Uint8List plainText) {
    BlockCipher cipher = ECBBlockCipher(AESFastEngine());
    cipher.init(true, KeyParameter(secretKey));
    Uint8List cipherText = cipher.process(plainText);
    return cipherText;
  }

  Future<void> startReceivingRawSensorData() async {
    List<Characteristic> miBandSrvChars;

    /* ---- DEBUG ----
     * For testing purposes whether the app has written data to the database.
     *
    //final allRows = await dbHelper.queryFirstNRowsOfDay(3000, "2021-01-19");
    final allRows = await dbHelper.queryLastNRows(500);
    print('queried rows:');
    allRows.forEach((row) => print(row));
     */

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

      await _enableSendingRawSensorData();
      _rawDataPacketsCounter = 0;
      s.start();
      // start listening for accelerometer data
      _accelerometerChar.monitor(transactionId: "HandleAccelerometerData").listen((data) {
        _handleRawAccelerometerData(data);
        //print("elapsed seconds: ${s.elapsedMilliseconds/1000}");
      });
    }

    // send alive packages so accelerometer data is continiously sent
    _accelDataAliveTimer = Timer.periodic((Duration(seconds:30)), (Timer t) => _enableSendingRawSensorData());
    _accelDataToDBTimer = Timer.periodic((Duration(seconds: 1)), (Timer t) => _writeAccelDataToDB());
    accelDataHandler.startDataToCSVTimer();
    accelDataHandler.startDataToBackendTimer();
  }



  Future<void> _enableSendingRawSensorData() async {
    // enable sensor raw data
    await _sensorChar.write(sensorRawDataCmd, false);
    await _sensorChar.write(Uint8List.fromList([2]), false);
  }

  Future<void> _stopReceivingRawSensorData() async {
    await _sensorChar.write(Uint8List.fromList([3]), false);
  }

  Future<void> _handleRawAccelerometerData(Uint8List data) async {
    // first byte is always one
    if (data[0] == 1) {
      // second byte is a counter
      // if counter is expected value, take the accelerometer data, else ignore
      if (data[1] == _rawDataPacketsCounter) {
        int counter = 0;
        List<double> accelData = new List(3);

        _rawDataPacketsCounter = (_rawDataPacketsCounter == 255) ? 0 : ++_rawDataPacketsCounter;

        // the next 3 x 2 bytes are the accelerometer data
        // 2 bytes: first byte is the value, second is the sign (0=+, 255=-)
        // first 2 bytes = x, second 2 bytes = y, third 2 bytes = z
        // there can be 1, 2 or 3 XYZ values
        for (int i=2; i<data.length; i++) {
          // if even
          if (i % 2 == 0) {

            if (counter == 0) {
              accelData[0] = _calculateDecimalValue(data[i], data[i+1]);
            } else if (counter == 1) {
              accelData[1] = _calculateDecimalValue(data[i], data[i+1]);
            } else if (counter == 2) {
              accelData[2] = _calculateDecimalValue(data[i], data[i+1]);

              accelDataSinceLastDBAccess = new List.from(accelDataSinceLastDBAccess)..addAll(accelData);
              latestAccelData = new List.from(accelData);
            }

            counter = (counter == 2) ? 0 : ++counter;
          }
        }
      }
    }
  }

  double _calculateDecimalValue(int firstValue, int secondValue) {
    double value = firstValue.toDouble() / ACCEL_RAW_VALUE_FOR_DECIMAL_ONE;

    if (secondValue == 255) {
      value = value - ACCEL_MAX_DECIMAL_VALUE;
    }

    return value;
  }

  Future<void> _writeAccelDataToDB() async {
    //print(latestAccelData[0].toString() + latestAccelData[1].toString() + latestAccelData[2].toString());
    //print("Connection state: " + (await fitnessTracker.isConnected()).toString());

    // don't write an entry to database when no data was received
    if (latestAccelData[0] != null && latestAccelData[1] != null && latestAccelData[2] != null) {
      await accelDataHandler.writeAccelDataToDB(latestAccelData[0], latestAccelData[1], latestAccelData[2]);
      ForegroundService.sendToPort(Status.accelDataWrittenToDB);
      accelDataSinceLastDBAccess = new List();
      latestAccelData = new List(3);
    } else {
      // send to port, so that user gets notified that no real data was written to database
      ForegroundService.sendToPort(Status.accelDataNotWrittenToDB);

      // for now write fake data in database, so the backend is not confused why there is no data
      await accelDataHandler.writeAccelDataToDB(1, 0, 0);

      if (!(await fitnessTracker.isConnected())){
        fitnessTracker.connect();
      } else {

      }
    }
  }
}
