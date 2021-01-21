

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

var db2csv = DBtoCSVConverter();

class DBtoCSVConverter {
  static DBtoCSVConverter _db2csv = new DBtoCSVConverter
      ._internal();

  factory DBtoCSVConverter() {
    return _db2csv;
  }

  DBtoCSVConverter._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory(); // directory not visible to user
    //final directory = await getExternalStorageDirectory(); // directory visible to user

    return directory.path;
  }

  Future<File> get _csvFile async {
    final path = await _localPath;
    final date = DateTime.now();
    final DateFormat serverFormaterDate = DateFormat('yyyy-MM-dd');
    final currentDate = serverFormaterDate.format(date);

    return File('$path/accelerometerData_$currentDate.csv');
  }

  Future<File> writeLine(String line) async {
    final file = await _csvFile;
    print("Writing");
    return await file.writeAsString(line);
  }

  Future<List<String>> readFile() async {
    try {
      final file = await _csvFile;
      return await file.readAsLines();
    } catch (e) {
      return null;
    }
  }

  String constructLine(String date, String time, String accX, String accY, String accZ) {
    final String line = date + " " + time + "," + accX + "," + accY + "," + accZ + "\r\n";
    return line;
  }
}
