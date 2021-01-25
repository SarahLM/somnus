import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/database_helper.dart';
import 'package:intl/intl.dart';
import 'datapoint.dart';
import 'dates.dart';

class DataStates with ChangeNotifier {
  List<DataPoint> dataFromDB = [];
  List<DateEntry> dataDatesFromDB = [];
  final dbHelper = DatabaseHelper.instance;

  Future<List<DataPoint>> getDataForSingleDate(date) async {
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    dataFromDB = [];
    final allRows =
        await dbHelper.queryResultsSingleDay(serverFormater.format(date));
    allRows.forEach((row) async {
      var parsedDate = DateTime.parse(row['date']);

      dataFromDB.add(
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
    });
    return dataFromDB;
  }

  Future<List<DataPoint>> getDataForDateRange(date1, date2) async {
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    dataFromDB = [];
    final allRows = await dbHelper.queryResultsDayRange(
        serverFormater.format(date2), serverFormater.format(date1));
    allRows.forEach((row) {
      var parsedDate = DateTime.parse(row['date']);
      dataFromDB.add(
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
    });
    return dataFromDB;
  }

  Future<List<DateEntry>> getEditDataForDateRange(date1, date2) async {
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    dataDatesFromDB = [];
    final allRows = await dbHelper.queryDatesDayRange(
        serverFormater.format(date2), serverFormater.format(date1));
    allRows.forEach((row) {
      var parsedDate = DateTime.parse(row['date']);
      dataDatesFromDB.add(
        DateEntry(
          date: DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
          ),
        ),
      );
    });
    return dataDatesFromDB;
  }
}
