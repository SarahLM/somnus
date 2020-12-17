import 'package:flutter/material.dart';
//import '../widgets/syncfusion.dart';
import 'datapoint.dart';

class DataStates with ChangeNotifier {
  List<DataPoint> _items = [
    // Bind data source
    DataPoint(
      DateTime(2020, 12, 6, 03, 32),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 6, 03, 31),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 6, 03, 33),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 6, 03, 34),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 6, 20, 35),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 7, 20, 31),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 7, 20, 32),
      0.0,
    ),
    DataPoint(
      DateTime(2020, 12, 7, 20, 33),
      0.0,
    ),
    DataPoint(
      DateTime(2020, 12, 7, 20, 34),
      0.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 35),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 36),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 37),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 38),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 39),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 40),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 41),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 42),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 43),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 44),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 45),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 46),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 47),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 48),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 49),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 50),
      0.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 51),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 52),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 53),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 54),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 55),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 3, 20, 56),
      1.0,
    ),

    DataPoint(
      DateTime(2020, 12, 4, 20, 35),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 36),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 37),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 38),
      0.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 39),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 40),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 41),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 42),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 43),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 44),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 45),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 46),
      0.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 47),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 48),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 49),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 50),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 51),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 52),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 53),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 54),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 55),
      1.0,
    ),
    DataPoint(
      DateTime(2020, 12, 4, 20, 56),
      0.0,
    ),
    DataPoint(
      DateTime(2020, 12, 9, 20, 57),
      0.0,
    ),
    DataPoint(
      DateTime(2020, 12, 9, 20, 58),
      0.0,
    ),
  ];

  List<DataPoint> get items {
    return [..._items];
  }

  void getSalesData() {
    //_items.add(value);
    notifyListeners();
  }

  List<DataPoint> findByDate(DateTime dateOne, DateTime dateTwo) {
    notifyListeners();
    print('Date one and two');
    print(dateOne);
    print(dateTwo);
    return _items
        .where((dataPoint) => (dataPoint.date.isAfter(dateOne) &&
            dataPoint.date.isBefore(dateTwo)))
        .toList();
  }
}
