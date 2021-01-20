import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/providers/dates.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/screens/hypnogram_screen.dart';
import 'package:frontend_somnus/widgets/list_widget.dart';
import 'package:frontend_somnus/widgets/no_data_widget.dart';
import 'package:frontend_somnus/widgets/syncfusion.dart';
import 'package:frontend_somnus/widgets/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/date_range_picker_custom.dart' as DateRagePicker;

class EditScreen extends StatefulWidget {
  final Color color;

  EditScreen(this.color);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen>
    with AutomaticKeepAliveClientMixin<EditScreen> {
  bool _pressedButton1 = true;
  bool _pressedButton2 = false;
  bool _pressedButton3 = false;
  bool _pressedButton4 = false;
  String title = '';
  final dataStates = DataStates();

  List<DataPoint> sleepData = [];
  List<DataPoint> dataPoints;

  List<DateEntry> dateEntries = [];
  List<DateEntry> dates;
  DateFormat dateFormat;
  var multipleDays = new DateFormat('dd.MM.yyyy kk:mm ');
  var singleDay = new DateFormat('kk:mm');
  double interval;

  List<Widget> widgetToShow = [];
  final DateFormat serverFormater = DateFormat('dd.MM.yyyy');
  var dateToday = DateTime.now();

  @override
  initState() {
    getInitialData();
    super.initState();
  }

  getInitialData() async {
    final dataPoints = await Provider.of<DataStates>(context, listen: false)
        .getDataForSingleDate(DateTime.now());
    setState(() {
      sleepData = dataPoints;
      title = serverFormater.format(dateToday);
      //timePrinted = DateTime.now().toString();
      // this.title = serverFormater.format(DateTime.now());
    });
    sleepData.length != 0
        ? widgetToShow.add(Sync(
            title: title,
            sleepData: this.sleepData,
            interval: 1,
            dateFormat: this.singleDay,
          ))
        : widgetToShow.add(NoDataWidget(title: ''));
  }

  buildWidgetList(Widget widget) {
    widgetToShow = [];
    widgetToShow.add(widget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: ButtonBar(
          alignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FlatButton(
              child: Text(
                'Heute',
                style: TextStyle(
                  color: _pressedButton1
                      ? Colors.white
                      : Theme.of(context).accentColor,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Theme.of(context).accentColor),
              ),
              color: _pressedButton1
                  ? Theme.of(context).accentColor
                  : Colors.white,
              onPressed: () async {
                final dataPoints =
                    await Provider.of<DataStates>(context, listen: false)
                        .getDataForSingleDate(DateTime.now());
                setState(() {
                  _pressedButton1 = true;
                  _pressedButton2 = false;
                  _pressedButton3 = false;
                  _pressedButton4 = false;
                  title = '';
                  sleepData = dataPoints;
                  interval = 1;
                  this.sleepData.length == 0
                      ? buildWidgetList(NoDataWidget(title: ''))
                      : buildWidgetList(
                          Sync(
                            title: this.title,
                            sleepData: this.sleepData,
                            dateFormat: this.dateFormat,
                            interval: this.interval,
                          ),
                        );
                  //timePrinted = (DateTime.now().toString());
                });
              },
            ),
            FlatButton(
              child: Text(
                '7 Tage',
                style: TextStyle(
                  color: _pressedButton2
                      ? Colors.white
                      : Theme.of(context).accentColor,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Theme.of(context).accentColor),
              ),
              color: _pressedButton2
                  ? Theme.of(context).accentColor
                  : Colors.white,
              onPressed: () async {
                dates = await Provider.of<DataStates>(context, listen: false)
                    .getEditDataForDateRange(
                  DateTime.now(),
                  (new DateTime.now()).add(new Duration(days: -7)),
                );
                setState(() {
                  _pressedButton2 = true;
                  _pressedButton1 = false;
                  _pressedButton3 = false;
                  _pressedButton4 = false;
                  title = '';
                  this.dateEntries = dates;

                  // sleepData = dataPoints;
                  // timePrinted =
                  //     (DateTime.now()).add(new Duration(days: -2)).toString() +
                  //         ' bis ' +
                  //         DateTime.now().toString();
                });
                buildWidgetList(
                  ListWidget(data1: this.dateEntries),
                );

                //dataStates.getResult();
              },
            ),
            FlatButton(
              child: Text(
                '30 Tage',
                style: TextStyle(
                  color: _pressedButton3
                      ? Colors.white
                      : Theme.of(context).accentColor,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Theme.of(context).accentColor),
              ),
              color: _pressedButton3
                  ? Theme.of(context).accentColor
                  : Colors.white,
              onPressed: () async {
                // final dataPoints =
                //     await Provider.of<DataStates>(context, listen: false)
                //         .getDataForDateRange(
                //   DateTime.now(),
                //   (new DateTime.now()).add(new Duration(days: -30)),
                // );
                dates = await Provider.of<DataStates>(context, listen: false)
                    .getEditDataForDateRange(
                  DateTime.now(),
                  (new DateTime.now()).add(new Duration(days: -30)),
                );

                setState(() {
                  _pressedButton3 = true;
                  _pressedButton1 = false;
                  _pressedButton2 = false;
                  _pressedButton4 = false;
                  title = '';
                  this.dateEntries = dates;
                  //sleepData = dataPoints;
                  // timePrinted = DateFormat('dd.MM. yyyy')
                  //         .format((DateTime.now()).add(new Duration(days: -7)))
                  //         .toString() +
                  //     ' bis ' +
                  //     DateFormat('dd.MM. yyyy')
                  //         .format(DateTime.now())
                  //         .toString();
                  // print(sleepData);
                });
                buildWidgetList(
                  ListWidget(data1: this.dateEntries),
                );
              },
            ),
            DatePickerTheme(
              Builder(
                builder: (context) => FlatButton(
                  child: new Text(
                    "Custom",
                    style: TextStyle(
                      color: _pressedButton4
                          ? Colors.white
                          : Theme.of(context).accentColor,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Theme.of(context).accentColor),
                  ),
                  color: _pressedButton4
                      ? Theme.of(context).accentColor
                      : Colors.white,
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
                      firstDate: new DateTime(2019),
                      lastDate: new DateTime(2023),
                    );

                    if (picked != null && picked.length == 2) {
                      print(picked);
                      print(picked.runtimeType);
                      dataPoints =
                          await Provider.of<DataStates>(context, listen: false)
                              .getDataForDateRange((picked[1]), (picked[0]));
                      dates = await Provider.of<DataStates>(context,
                              listen: false)
                          .getEditDataForDateRange((picked[1]), (picked[0]));
                      setState(() {
                        title = DateFormat('dd.MM. yyyy')
                                .format(picked[0])
                                .toString() +
                            ' bis ' +
                            DateFormat('dd.MM. yyyy')
                                .format(picked[1])
                                .toString();
                        sleepData = dataPoints;
                        this.dateEntries = dates;
                        // timePrinted = title;
                      });
                      buildWidgetList(
                        ListWidget(data1: this.dateEntries),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Im ausgewählten Zeitraum liegen Daten für die folgenden Tage vor:',
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: widgetToShow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
