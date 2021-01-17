import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/providers/dates.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/screens/details_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ListWidget extends StatefulWidget {
  ListWidget({
    this.data1,
  });
  List<DateEntry> data1;

  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  List<DataPoint> sleepData;
  String title = '';

  final DateFormat formatter = DateFormat('dd.MM.yyyy');

  final DateFormat formatDay = DateFormat('EE');

  final List<DateEntry> data = [
    DateEntry(
      date: DateTime(2021, 12, 21),
    ),
    DateEntry(
      date: DateTime(2021, 12, 22),
    ),
    DateEntry(
      date: DateTime(2021, 12, 23),
    ),
    DateEntry(
      date: DateTime(2021, 12, 24),
    ),
  ];

  List<Color> colorList = [
    Color(0xFF141F9C),
    Color(0xFF141F9C),
    Color(0xFF0C135C),
    Color(0xFF1D2DDC),
    Color(0xFF1E2FE8),
    Color(0xFF1927C2),
    Color(0xFF502EE8),
    Color(0xFF4327C2),
  ];

  _getColor(DateTime date) {
    var color;
    color = colorList[date.weekday];
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: widget.data1.map((d) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () async {
                final sleepData =
                    await Provider.of<DataStates>(context, listen: false)
                        .getDataForSingleDate(d.date);
                setState(() {
                  this.sleepData = sleepData;
                  this.title = '';
                });

                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => EditDetailsScreen(
                            title: this.title,
                            sleepData: this.sleepData,
                          )),
                );
              },
              child: Card(
                elevation: 8,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10.0),
                  leading: CircleAvatar(
                    child: Text(
                      formatDay.format(d.date).toString(),
                      // _getInitials(user),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    backgroundColor: _getColor(d.date),
                  ),
                  title: Text(
                    formatter.format(d.date).toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          );

          // return Card(
          //   child: Row(
          //     children: <Widget>[
          //       Container(
          //         width: 55,
          //         margin: EdgeInsets.symmetric(
          //           vertical: 10,
          //           horizontal: 15,
          //         ),
          //         decoration: BoxDecoration(
          //           // borderRadius:
          //           //     new BorderRadius.all(new Radius.circular(50.0)),
          //           border: Border.all(
          //             color: Colors.purple,
          //             width: 2,
          //           ),
          //         ),
          //         padding: EdgeInsets.all(10),
          //         child: Text(
          //           formatDay.format(d.date).toString(),
          //           style: TextStyle(
          //             fontWeight: FontWeight.bold,
          //             fontSize: 20,
          //             color: Colors.purple,
          //           ),
          //         ),
          //       ),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: <Widget>[
          //           Text(
          //             formatter.format(d.date).toString(),
          //             style: TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           Text(
          //             'Test',
          //             style: TextStyle(
          //               color: Colors.grey,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // );
        }).toList(),
      ),
    );
  }
}

// Card(
//   child: Row(
//     children: <Widget>[
//       Container(
//         margin: EdgeInsets.symmetric(
//           vertical: 10,
//           horizontal: 15,
//         ),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: Colors.purple,
//             width: 2,
//           ),
//         ),
//         padding: EdgeInsets.all(10),
//         child: Text(
//           'Test',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.purple,
//           ),
//         ),
//       ),
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             '11.01.2020',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             'Test',
//             style: TextStyle(
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     ],
//   ),
// ),
