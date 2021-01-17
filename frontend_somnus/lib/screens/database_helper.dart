import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabasenew.db";
  static final _databaseVersion = 1;

  static final table = 'my_table';
  static final results = 'results_table';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnAge = 'age';
  static final columnDate = 'date';
  static final columnTime = 'time';
  static final columnX = 'accx';
  static final columnY = 'accy';
  static final columnZ = 'accz';
  static final columnLUX = 'lux';
  static final columnT = 'acct';
  static final columnSleepwake = 'sleepwake';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    //print('db location : ' + path);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnDate TEXT NOT NULL,
            $columnTime TEXT NOT NULL,
            $columnX REAL NOT NULL,
            $columnY REAL NOT NULL,
            $columnZ REAL NOT NULL,
            $columnLUX INTEGER NOT NULL,
            $columnT REAL NOT NULL
          )
          ''');
    await db.execute('''
       create table $results (
        $columnId INTEGER PRIMARY KEY,
        $columnDate TEXT NOT NULL,
        $columnTime TEXT NOT NULL,
        $columnSleepwake DOUBLE NOT NULL
       )''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> insertsleepwake(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(results, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryAllRowsSleep() async {
    Database db = await instance.database;
    return await db.query(results);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> doubleValues(date, time) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM $results WHERE $columnDate='$date' AND $columnTime='$time'"));
  }

  Future<int> queryRowCountResults() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $results'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateDataPerRange(
      Map<String, dynamic> row, time1, time2, date) async {
    Database db = await instance.database;
    print(time1);
    print(time2);
    print(date);
    return await db.update(results, row,
        where:
            "$columnDate='$date' AND $columnTime BETWEEN '$time1' AND '$time2'");
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryResultsSingleDay(name) async {
    Database db = await instance.database;
    return await db.query(results, where: "$columnDate LIKE '%$name%'");
  }

  Future<List<Map<String, dynamic>>> queryResultsDayRange(date1, date2) async {
    print('Date in helper ' + date1);
    print('Date in helper ' + date2);
    Database db = await instance.database;
    return await db.query(results,
        where: "$columnDate BETWEEN '$date1' AND '$date2'");
  }

  Future<List<Map<String, dynamic>>> queryDatesDayRange(date1, date2) async {
    print('Date in helper ' + date1);
    print('Date in helper ' + date2);
    Database db = await instance.database;
    return await db.query(results,
        where: "$columnDate BETWEEN '$date1' AND '$date2'",
        distinct: true,
        columns: ['$columnDate'],
        groupBy: '$columnDate');
  }

  checkValue(date, time) async {
    final val = await doubleValues(date, time);
    //print('count');
    //print(val);
    return val;
  }

  resultsToDb() async {
    final myData = await rootBundle.loadString("assets/result.csv");
    String result = myData.replaceAll(RegExp(' '), ',');
    result = result.substring(0, 5) +
        "clock_time," +
        result.substring(5, result.length);
    List<dynamic> test = result.split('\n');
    print('Start');
    for (int i = 1; i < test.length - 1; i++) {
      var insertArray = test[i].split(',');
      Map<String, dynamic> row = {
        DatabaseHelper.columnDate: insertArray[0],
        DatabaseHelper.columnTime: insertArray[1],
        DatabaseHelper.columnSleepwake: insertArray[2],
      };
      int count = await checkValue(insertArray[0], insertArray[1]);
      if (count == 0) {
        //  print('Insert');
        insertsleepwake(row);
      } else {
        // print('No insert');
      }
    }
    print('Done');
  }

  Future<void> cleanDatabase() async {
    try {
      Database db = await instance.database;
      await db.transaction((txn) async {
        var batch = txn.batch();
        batch.delete(results);
        await batch.commit();
      });
    } catch (error) {
      throw Exception('DbBase.cleanDatabase: ' + error.toString());
    }
  }
}
