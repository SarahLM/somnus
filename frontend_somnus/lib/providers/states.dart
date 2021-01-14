import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_somnus/screens/database_helper.dart';
import 'package:frontend_somnus/screens/db_analyse_screen.dart';
import 'package:intl/intl.dart';
//import '../widgets/syncfusion.dart';
import 'datapoint.dart';

class DataStates with ChangeNotifier {
  List<DataPoint> dataToDB = [];
  // List<DataPoint> _items = [
  //   // Bind data source
  //   DataPoint(
  //     DateTime(2020, 12, 6, 03, 32),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 6, 03, 31),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 6, 03, 33),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 6, 03, 34),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 6, 20, 35),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 7, 20, 31),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 7, 20, 32),
  //     0.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 7, 20, 33),
  //     0.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 7, 20, 34),
  //     0.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 35),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 36),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 37),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 38),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 39),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 40),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 41),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 42),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 43),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 44),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 45),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 46),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 47),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 48),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 49),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 50),
  //     0.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 51),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 52),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 53),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 54),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 55),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 3, 20, 56),
  //     1.0,
  //   ),

  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 35),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 36),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 37),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 38),
  //     0.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 39),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 40),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 41),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 42),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 43),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 44),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 45),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 46),
  //     0.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 47),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 48),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 49),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 50),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 51),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 52),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 53),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 54),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 55),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 4, 20, 56),
  //     0.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 9, 20, 57),
  //     0.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 9, 20, 58),
  //     0.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 15, 03, 32),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 15, 03, 33),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 15, 15, 34),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 15, 15, 35),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 15, 15, 36),
  //     1.0,
  //   ),
  //   DataPoint(
  //     DateTime(2020, 12, 15, 15, 37),
  //     1.0,
  //   ),
  // ];

  final db = DbScreen(Colors.blue);
  final dbHelper = DatabaseHelper.instance;

  // List<DataPoint> get items {
  //   return [..._items];
  // }

  void getSalesData() {
    //_items.add(value);
    notifyListeners();
  }

  // List<DataPoint> findByDate(DateTime dateOne, DateTime dateTwo) {
  //   notifyListeners();
  //   print('Date one and two');
  //   print(dateOne);
  //   print(dateTwo);
  //   return _items
  //       .where((dataPoint) => (dataPoint.date.isAfter(dateOne) &&
  //           dataPoint.date.isBefore(dateTwo)))
  //       .toList();
  // }

  Future<List<DataPoint>> getDataForSingleDate(date) async {
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    print('Single Date in states: ' + serverFormater.format(date));
    dataToDB = [];
    final allRows =
        await dbHelper.queryResultsSingleDay(serverFormater.format(date));
    allRows.forEach((row) async {
      var parsedDate = DateTime.parse(row['date']);
      print(row);

      dataToDB.add(
        DataPoint(
          DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
            int.parse(row['time'].substring(0, 2)),
            int.parse(row['time'].substring(3, 5)),
            int.parse(row['time'].substring(6, 8)),
          ),
          row['sleepwake'],
        ),
      );
      print(row['time'].substring(0, 2));
      print(row['time'].substring(3, 5));
      print(row['time'].substring(6, 8));
    });
    return dataToDB;
  }

  Future<List<DataPoint>> getDataForDateRange(date1, date2) async {
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    print('Date in states: ' + serverFormater.format(date2));
    print('Date in states: ' + serverFormater.format(date1));
    dataToDB = [];
    final allRows = await dbHelper.queryResultsDayRange(
        serverFormater.format(date2), serverFormater.format(date1));
    allRows.forEach((row) {
      var parsedDate = DateTime.parse(row['date']);
      print(row);
      dataToDB.add(
        DataPoint(
          DateTime(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
              int.parse(row['time'].substring(0, 2)),
              int.parse(row['time'].substring(3, 5)),
              int.parse(row['time'].substring(6, 8))),
          row['sleepwake'],
        ),
      );
      print(row['time'].substring(0, 2));
      print(row['time'].substring(3, 5));
    });
    return dataToDB;
  }
}
