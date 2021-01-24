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

  Future<String> getFilePath() async {
    final path = await _localPath;
    return '$path/accelerometerData.csv';
  }

  Future<File> writeLine(String line) async {
    final file = File(await getFilePath());
    return await file.writeAsString(line, mode: FileMode.append);
  }

  Future<List<String>> readFile() async {
    try {
      final file = File(await getFilePath());
      return await file.readAsLines();
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteFile() async {
    try {
      final file = File(await getFilePath());
      await file.delete();
    } catch (e) {
      return false;
    }

    return true;
  }
}
