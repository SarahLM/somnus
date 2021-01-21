import 'package:flutter/material.dart';
import 'package:frontend_somnus/widgets/singletons/db_to_csv.dart';
import 'package:frontend_somnus/screens/database_helper.dart';
import 'package:loading_overlay/loading_overlay.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper.instance;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somnus',
      debugShowCheckedModeBanner: false,
      home: LoadingOverlay(
        child: Scaffold(
          body: Center(
            /*child: RaisedButton(
              onPressed: bleDeviceController.reset,
              child: Text("Reset BLE Connection"),
            ),*/
            child: RaisedButton(
              onPressed: _writeData,
              child: Text("write data to file"),
            ),
          ),
        ),
        isLoading: _isLoading,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  void _writeData() async {
    setState(() {
      _isLoading = true;
    });

    final allRows = await dbHelper.queryDataOfDay("2021-01-20");
    String fileContentStr = "";

    // construct a big string for CSV file
    allRows.forEach((row) => fileContentStr += db2csv.constructLine(
            row[DatabaseHelper.columnDate],
            row[DatabaseHelper.columnTime],
            row[DatabaseHelper.columnX].toString(),
            row[DatabaseHelper.columnY].toString(),
            row[DatabaseHelper.columnZ].toString()));

    print("Prepared Data: $fileContentStr");

    // write one line to file
    await db2csv.writeLine(fileContentStr);
    final fileContent = await db2csv.readFile();

    fileContent.forEach((line) => print(line));
    setState(() {
      _isLoading = false;
    });
  }
}
