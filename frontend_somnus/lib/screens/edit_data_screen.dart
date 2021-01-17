import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';

class EditDataScreen extends StatefulWidget {
  static const routeName = '/edit-data';

  @override
  _EditDataScreenState createState() => _EditDataScreenState();
}

enum States { schlaf, wach }

class _EditDataScreenState extends State<EditDataScreen> {
  TimeOfDay start_time;
  TimeOfDay end_time;
  final dbHelper = DatabaseHelper.instance;

  States _site = States.schlaf;

  String twoDigits(int n) => n.toString().padLeft(2, "0");

  @override
  void initState() {
    super.initState();

    start_time = TimeOfDay.now();
    end_time = TimeOfDay.now();
  }

  _pickStartTime() async {
    TimeOfDay t = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay(hour: 00, minute: 00),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child,
        );
      },
    );
    if (t != null)
      setState(() {
        start_time = t;
      });
  }

  _pickEndTime() async {
    TimeOfDay t = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay(hour: 00, minute: 00),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child,
        );
      },
    );
    if (t != null)
      setState(() {
        end_time = t;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daten bearbeiten'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text(
                  "Startzeit: ${twoDigits(start_time.hour)}:${twoDigits(start_time.minute)}"),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: _pickStartTime,
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text(
                  "Endzeit: ${twoDigits(end_time.hour)}:${twoDigits(end_time.minute)}"),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: _pickEndTime,
            ),
            ListTile(
              title: const Text('Schlaf'),
              leading: Radio(
                value: States.schlaf,
                groupValue: _site,
                onChanged: (States value) {
                  setState(() {
                    _site = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Wach'),
              leading: Radio(
                value: States.wach,
                groupValue: _site,
                onChanged: (States value) {
                  setState(() {
                    _site = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            FlatButton(
              onPressed: () async {
                _updateRows();
              },
              child: Text('Daten ändern'),
            )
          ],
        ),
      ),
    );
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  void _updateRows() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnSleepwake: _site == States.schlaf ? 0.0 : 1.0
    };
    String startTimeNew = formatTimeOfDay(start_time);
    String endTimeNew = formatTimeOfDay(end_time);
    print(startTimeNew);
    print(endTimeNew);
    final rowsAffected = await dbHelper.updateDataPerRange(
        row, startTimeNew, endTimeNew, '2021-01-17');
    print('updated $rowsAffected row(s)');
  }
}
