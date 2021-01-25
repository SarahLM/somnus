import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/widgets/add_activities_widget.dart';
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

  _pressOK() {
    setState(() {
      _acivity_visible = true;
    });
    Navigator.of(context).pop();
    final snackBar = SnackBar(
        content: Text('Aktivitäten hinzugefügt'),
        duration: const Duration(seconds: 1));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _pressOKMeds() {
    setState(() {
      _meds_visible = true;
    });
    Navigator.of(context).pop();
    final snackBar = SnackBar(
        content: Text('Medikamente hinzugefügt'),
        duration: const Duration(seconds: 1));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  List<String> _texts = [
    "Alkohol getrunken",
    "Koffein",
    "keine Elektronik",
    "seelische Konflikte",
    "Sport getrieben",
    "Entspannungsübungen",
    "andere Umgebung",
    "zu kalt",
    "zu warm",
  ];

  List<String> _meds = [
    "Baldrian",
    "CBD",
    "Johanniskraut",
    "Melatonin",
    "Modafinil",
    "Wakix",
    "Xyrem",
    "Zopiclon",
    "Zolpidem"
  ];

  List<Icon> _icons = [
    Icon(Icons.local_bar_outlined),
    Icon(Icons.free_breakfast_outlined),
    Icon(Icons.no_cell_outlined),
    Icon(Icons.psychology),
    Icon(Icons.directions_run_outlined),
    Icon(Icons.self_improvement_outlined),
    Icon(Icons.find_replace_outlined),
    Icon(Icons.ac_unit),
    Icon(Icons.fireplace_outlined),
  ];

  List<Icon> _iconsMeds = [
    Icon(Icons.spa_outlined),
    Icon(Icons.spa_outlined),
    Icon(Icons.spa_outlined),
    Icon(Icons.spa_outlined),
    Icon(Icons.science_outlined),
    Icon(Icons.science_outlined),
    Icon(Icons.science_outlined),
    Icon(Icons.science_outlined),
    Icon(Icons.science_outlined),
  ];

  List<bool> _isChecked;
  List<bool> _isCheckedMeds;

  bool _acivity_visible;
  bool _meds_visible;

  @override
  void initState() {
    super.initState();
    startTime = TimeOfDay.now();
    endTime = TimeOfDay.now();
    _isChecked = List<bool>.filled(_texts.length, false);
    _isCheckedMeds = List<bool>.filled(_texts.length, false);
    _acivity_visible = false;
    _meds_visible = false;
  }

  _pickStartTime() async {
    TimeOfDay t = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay(hour: 00, minute: 00),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerTheme.of(context).copyWith(
              backgroundColor: Colors.white,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child,
          ),
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
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerTheme.of(context).copyWith(
              backgroundColor: Colors.white,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child,
          ),
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

  Future<int> _updateRows() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnSleepwake: _site == States.schlaf ? 0.0 : 1.0
    };
    String startTimeNew = formatTimeOfDay(startTime);
    String endTimeNew = formatTimeOfDay(endTime);
    this.rowsAffected = await dbHelper.updateDataPerRange(
        row, startTimeNew, endTimeNew, widget.date);

    final dataPoints = await Provider.of<DataStates>(context, listen: false)
        .getDataForSingleDate(widget.date);
    setState(() {
      widget.sleepData = dataPoints;
      this.rowsAffected = this.rowsAffected;
    });

    Navigator.of(context).pop();
    return rowsAffected;
  }

  Future<void> _showDialogActivity(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AddActivities(
            title: 'Aktivitäten',
            texts: _texts,
            icons: _icons,
            isChecked: _isChecked,
            pressOK: _pressOK,
          );
        });
  }

  Future<void> _showDialogMeds(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AddActivities(
            title: 'Medikamente',
            texts: _meds,
            icons: _iconsMeds,
            isChecked: _isCheckedMeds,
            pressOK: _pressOKMeds,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Daten bearbeiten')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E1164), Color(0xFF2752E4)]),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                child: Sync(
                  title: widget.title,
                  sleepData: widget.sleepData,
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _acivity_visible
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aktivitäten:',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.local_bar_outlined),
                                    Icon(Icons.directions_run_outlined),
                                    Icon(Icons.self_improvement_outlined),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                  _meds_visible
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Medikamente:',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.spa_outlined),
                                    Icon(Icons.science_outlined),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              FlatButton(
                  child: Text(
                    'Daten bearbeiten',
                    style: TextStyle(color: Color(0xFFEDF2F7)),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
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
                                    ),
                                    Expanded(
                                      child: ListTile(
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
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                // FlatButton(
                                //     onPressed: () =>
                                //         _showDialogActivity(context),
                                //     child: Text('Aktivät hinzufügen')),
                                // FlatButton(
                                //     onPressed: () => _showDialogMeds(context),
                                //     child: Text('Medikament hinzufügen')),
                                FlatButton(
                                  onPressed: () async {
                                    await _updateRows();

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
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: Icon(
                            Icons.add,
                            color: Color(0xFFEDF2F7),
                          ),
                        ),
                        Text(
                          'Aktivität',
                          style: TextStyle(
                            color: Color(0xFFEDF2F7),
                          ),
                        ),
                      ],
                    ),
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    onPressed: () => _showDialogActivity(context),
                  ),
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: Icon(
                            Icons.add,
                            color: Color(0xFFEDF2F7),
                          ),
                        ),
                        Text(
                          'Medikament',
                          style: TextStyle(color: Color(0xFFEDF2F7)),
                        ),
                      ],
                    ),
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    onPressed: () => _showDialogMeds(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
