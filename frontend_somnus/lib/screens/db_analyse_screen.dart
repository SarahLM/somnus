import 'dart:math';

import 'package:flutter/material.dart';
// change `flutter_database` to whatever your project name is
import 'package:frontend_somnus/screens/database_helper.dart';

class DbScreen extends StatelessWidget {
  final Color color;

  DbScreen(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: color,
      child: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  // homepage layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sqflite'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text(
                'insert',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _insert();
              },
            ),
            RaisedButton(
              child: Text(
                'insertResults',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _insertresults();
              },
            ),
            RaisedButton(
              child: Text(
                'query',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _query();
              },
            ),
            RaisedButton(
              child: Text(
                'queryresults',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _queryresults();
              },
            ),
            RaisedButton(
              child: Text(
                'update',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _update();
              },
            ),
            RaisedButton(
              child: Text(
                'delete',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _deleteAll();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Button onPressed methods
  Random random = new Random();

  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnDate: '2019-03-21',
      DatabaseHelper.columnTime: '14:58:00:500',
      DatabaseHelper.columnX: 0.1577,
      DatabaseHelper.columnY: -0.9023,
      DatabaseHelper.columnZ: -0.4280,
      DatabaseHelper.columnLUX: 0,
      DatabaseHelper.columnT: 0
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _insertresults() async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnDate:
          '2021-01-' + (random.nextInt(1) + 10).toString(),
      DatabaseHelper.columnTime: (random.nextInt(14) + 10).toString() +
          ':' +
          (random.nextInt(50) + 10).toString() +
          ':00:500',
      DatabaseHelper.columnSleepwake: random.nextInt(2)
    };
    final id = await dbHelper.insertsleepwake(row);
    print('inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));
  }

  void _queryresults() async {
    final allRows = await dbHelper.queryAllRowsSleep();
    print('query all rows:');
    allRows.forEach((row) => print(row));
  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnDate: '2019-03-21',
      DatabaseHelper.columnTime: '14:58:00:500',
      DatabaseHelper.columnX: 0.1577,
      DatabaseHelper.columnY: -0.9023,
      DatabaseHelper.columnZ: -0.4280,
      DatabaseHelper.columnLUX: 0,
      DatabaseHelper.columnT: 0
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }

  void _deleteAll() async {
    // Assuming that the number of rows is the id for the last row.
    await dbHelper.cleanDatabase();

    print('all results deleted');
  }
}
