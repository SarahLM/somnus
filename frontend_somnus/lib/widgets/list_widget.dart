import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/providers/dates.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/screens/details_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ListWidget extends StatefulWidget {
  ListWidget({
    this.data,
  });
  List<DateEntry> data;

  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  List<DataPoint> sleepData;
  String title = '';
  DateTime date;

  final DateFormat formatter = DateFormat('dd.MM.yyyy');

  final DateFormat formatDay = DateFormat('EE');

  List<Color> colorList = [
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
    color = colorList[date.weekday - 1];
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: widget.data.map((d) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () async {
                final sleepData =
                    await Provider.of<DataStates>(context, listen: false)
                        .getDataForSingleDate(d.date);
                title = formatter.format(d.date);
                setState(() {
                  this.sleepData = sleepData;
                  this.title = title;
                });

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditDetailsScreen(
                      title: this.title,
                      sleepData: this.sleepData,
                      date: d.date,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 8,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10.0),
                  leading: CircleAvatar(
                    child: Text(
                      formatDay.format(d.date),
                      style: TextStyle(color: Color(0xFFEDF2F7), fontSize: 18),
                    ),
                    backgroundColor: _getColor(d.date),
                  ),
                  title: Text(
                    formatter.format(d.date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFEDF2F7),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFEDF2F7),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
