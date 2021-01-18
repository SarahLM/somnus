import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/widgets/syncfusion.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './edit_data_screen.dart';
import 'database_helper.dart';

class EditDetailsScreen extends StatefulWidget {
  List<DataPoint> sleepData;
  final String title;
  final DateTime date;

  EditDetailsScreen({this.sleepData, this.title, this.date});

  @override
  _EditDetailsScreenState createState() => _EditDetailsScreenState();
}

class _EditDetailsScreenState extends State<EditDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TimeOfDay startTime;
  TimeOfDay endTime;

  final dbHelper = DatabaseHelper.instance;

  States _site = States.schlaf;
  int rowsAffected;

  String twoDigits(int n) => n.toString().padLeft(2, "0");
  var singleDay = new DateFormat('kk:mm');

  @override
  void initState() {
    super.initState();
    startTime = TimeOfDay.now();
    endTime = TimeOfDay.now();
    print(widget.date);
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
        startTime = t;
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
        endTime = t;
      });
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
    String startTimeNew = formatTimeOfDay(startTime);
    String endTimeNew = formatTimeOfDay(endTime);

    print('this date');
    print(widget.date);
    print(startTimeNew);
    print(endTimeNew);
    this.rowsAffected = await dbHelper.updateDataPerRange(
        row, startTimeNew, endTimeNew, widget.date);
    print('updated $rowsAffected row(s)');

    final dataPoints = await Provider.of<DataStates>(context, listen: false)
        .getDataForSingleDate(widget.date);
    setState(() {
      widget.sleepData = dataPoints;
      this.rowsAffected = this.rowsAffected;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Sync(
              title: widget.title,
              sleepData: widget.sleepData,
              interval: 1,
              dateFormat: singleDay,
            ),
            SizedBox(
              height: 10,
            ),
            FlatButton(
                child: Text('Daten bearbeiten'),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setModalState) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ListView(
                            children: [
                              SizedBox(height: 10),
                              ListTile(
                                leading: Icon(Icons.schedule),
                                title: Text(
                                    "Startzeit: ${twoDigits(startTime.hour)}:${twoDigits(startTime.minute)}"),
                                trailing: Icon(Icons.keyboard_arrow_down),
                                onTap: _pickStartTime,
                              ),
                              ListTile(
                                leading: Icon(Icons.schedule),
                                title: Text(
                                    "Endzeit: ${twoDigits(endTime.hour)}:${twoDigits(endTime.minute)}"),
                                trailing: Icon(Icons.keyboard_arrow_down),
                                onTap: _pickEndTime,
                              ),
                              ListTile(
                                title: const Text('Schlaf'),
                                leading: Radio(
                                  value: States.schlaf,
                                  groupValue: _site,
                                  onChanged: (States value) {
                                    setModalState(() {
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
                                    setModalState(() {
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

                                  final snackBar = SnackBar(
                                    content: this.rowsAffected > 0
                                        ? Text(
                                            "$rowsAffected Datensätze wurden bearbeitet")
                                        : Text(
                                            'Für den ausgewählten Zetraum liegen keine Datensätze vor'),
                                  );

                                  // Find the Scaffold in the widget tree and use
                                  // it to show a SnackBar.
                                  _scaffoldKey.currentState
                                      .showSnackBar(snackBar);
                                },
                                child: Text('Daten ändern'),
                              )
                            ],
                          ),
                        );
                      });
                    },
                  );

                  // Navigator.of(context).pushNamed(EditDataScreen.routeName);
                })
          ],
        ),
      ),
    );
  }
}
