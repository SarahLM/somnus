import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

var fileWriter = FileWriter();

class FileWriter {
  static FileWriter _fileWriter = new FileWriter
      ._internal();

  factory FileWriter() {
    return _fileWriter;
  }

  FileWriter._internal();

  Future<String> get _localPath async {
    //final directory = await getApplicationDocumentsDirectory(); // directory not visible to user
    final directory = await getExternalStorageDirectory(); // directory visible to user

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
}
