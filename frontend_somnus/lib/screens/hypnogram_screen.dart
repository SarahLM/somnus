import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/widgets/hypnogram_piechart_widget.dart';
import 'package:provider/provider.dart';
//import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import '../widgets/date_range_picker_custom.dart' as DateRagePicker;
import 'package:frontend_somnus/widgets/syncfusion.dart';
import 'package:frontend_somnus/widgets/theme.dart';

class HypnogramScreen extends StatefulWidget {
  final Color color;
  final buttonTextStyle = TextStyle(color: Colors.purple);

  HypnogramScreen(this.color);

  @override
  _HypnogramScreenState createState() => _HypnogramScreenState();
}

class _HypnogramScreenState extends State<HypnogramScreen> {
  bool _pressedButton1 = true;
  bool _pressedButton2 = false;
  bool _pressedButton3 = false;
  bool _pressedButton4 = false;
  var title = 'Letzte Aufnahme';

  List<DataPoint> sleepData;

  @override
  initState() {
    final dataStatesData = Provider.of<DataStates>(context, listen: false);
    final dataPoints = dataStatesData.items;
    setState(() {
      _pressedButton1 = true;
      _pressedButton2 = false;
      _pressedButton3 = false;
      _pressedButton4 = false;
      title = 'Letzte Aufnahme';
      sleepData = dataPoints;
    });
    super.initState();
  }

  Widget buildFlatButton(String title, bool button) {
    return FlatButton(
      child: Text(
        title,
        style: TextStyle(
          color: button ? Colors.white : Colors.purple,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.purple),
      ),
      color: button ? Colors.purple : Colors.white,
      onPressed: () {
        setState(() {
          button = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            color: widget.color,
            child: ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    'Letzte Aufnahme',
                    style: TextStyle(
                      color: _pressedButton1 ? Colors.white : Colors.purple,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.purple),
                  ),
                  color: _pressedButton1 ? Colors.purple : Colors.white,
                  onPressed: () {
                    final dataStatesData =
                        Provider.of<DataStates>(context, listen: false);
                    final dataPoints = dataStatesData.items;
                    setState(() {
                      _pressedButton1 = true;
                      _pressedButton2 = false;
                      _pressedButton3 = false;
                      _pressedButton4 = false;
                      title = 'Letzte Aufnahme';
                      sleepData = dataPoints;
                    });
                  },
                ),
                FlatButton(
                  child: Text(
                    '24 Stunden',
                    style: TextStyle(
                      color: _pressedButton2 ? Colors.white : Colors.purple,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.purple),
                  ),
                  color: _pressedButton2 ? Colors.purple : Colors.white,
                  onPressed: () {
                    final dataPoints = Provider.of<DataStates>(context,
                            listen: false)
                        .findByDate(
                            (new DateTime.now()).add(new Duration(days: -2)),
                            DateTime.now());
                    setState(() {
                      _pressedButton2 = true;
                      _pressedButton1 = false;
                      _pressedButton3 = false;
                      _pressedButton4 = false;
                      title = '24 Stunden';
                      sleepData = dataPoints;
                    });
                  },
                ),
                FlatButton(
                  child: Text(
                    '7 Tage',
                    style: TextStyle(
                      color: _pressedButton3 ? Colors.white : Colors.purple,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.purple),
                  ),
                  color: _pressedButton3 ? Colors.purple : Colors.white,
                  onPressed: () {
                    final dataPoints = Provider.of<DataStates>(context,
                            listen: false)
                        .findByDate(
                            (new DateTime.now()).add(new Duration(days: -7)),
                            DateTime.now());
                    setState(() {
                      _pressedButton3 = true;
                      _pressedButton1 = false;
                      _pressedButton2 = false;
                      _pressedButton4 = false;
                      title = '7 Tage';
                      sleepData = dataPoints;
                      print(sleepData);
                    });
                  },
                ),
                DatePickerTheme(
                  Builder(
                    builder: (context) => FlatButton(
                      child: new Text(
                        "Custom",
                        style: TextStyle(
                          color: _pressedButton4 ? Colors.white : Colors.purple,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.purple),
                      ),
                      color: _pressedButton4 ? Colors.purple : Colors.white,
                      onPressed: () async {
                        setState(() {
                          _pressedButton4 = true;
                          _pressedButton1 = false;
                          _pressedButton2 = false;
                          _pressedButton3 = false;
                        });
                        final List<DateTime> picked =
                            await DateRagePicker.showDatePicker(
                          locale: const Locale("de", "DE"),
                          context: context,
                          initialFirstDate: new DateTime.now(),
                          initialLastDate:
                              (new DateTime.now()).add(new Duration(days: 7)),
                          firstDate: new DateTime(2020),
                          lastDate: new DateTime(2022),
                        );

                        final dataPoints =
                            Provider.of<DataStates>(context, listen: false)
                                .findByDate((picked[0]), (picked[1]));

                        if (picked != null && picked.length == 2) {
                          print(picked);
                          print(picked.runtimeType);
                        }

                        setState(() {
                          title = picked.toString();
                          sleepData = dataPoints;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          //LineAreaPage(),
          //LineAreaPage(),
          ((this.sleepData.length == 0)
              ? Text('Für den ausgewählten Zeitraum liegen keine Daten vor.')
              : Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Sync(
                        title: this.title,
                        sleepData: this.sleepData,
                      ),
                      HypnogramPieChart(
                        sleepData: this.sleepData,
                      )
                    ],
                  ),
                )
          //LineAreaPage()
          ),
        ],
      ),
    );
  }
}
