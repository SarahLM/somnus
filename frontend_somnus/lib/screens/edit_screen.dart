import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/providers/dates.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/widgets/list_widget.dart';
import 'package:frontend_somnus/widgets/no_data_widget.dart';
import 'package:frontend_somnus/widgets/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/date_range_picker_custom.dart' as DateRangePicker;

class EditScreen extends StatefulWidget {
  EditScreen();

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen>
    with AutomaticKeepAliveClientMixin<EditScreen> {
  // bool _pressedButton1 = true;
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

  List<Widget> widgetToShow = [];
  final DateFormat serverFormater = DateFormat('dd.MM.yyyy');
  var dateToday = DateTime.now();

  @override
  initState() {
    getInitialData();
    super.initState();
  }

  getInitialData() async {
    dates = await Provider.of<DataStates>(context, listen: false)
        .getEditDataForDateRange(
      DateTime.now(),
      (new DateTime.now()).add(new Duration(days: -7)),
    );
    setState(() {
      _pressedButton2 = true;
      _pressedButton3 = false;
      _pressedButton4 = false;
      title = '';
      this.dateEntries = dates;
    });
    this.dateEntries.length != 0
        ? buildWidgetList(ListWidget(data: this.dateEntries))
        : buildWidgetList(NoDataWidget(title: ''));
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
        backgroundColor: Color(0xFF1E1164),
        title: ButtonBar(
          alignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FlatButton(
              child: Text(
                '7 Tage',
                style: TextStyle(
                  color: _pressedButton2
                      ? Colors.white
                      : Color(
                          0xFFA0AEC0,
                        ),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              color: _pressedButton2 ? Color(0xFF2752E4) : Colors.transparent,
              onPressed: () async {
                dates = await Provider.of<DataStates>(context, listen: false)
                    .getEditDataForDateRange(
                  DateTime.now(),
                  (new DateTime.now()).add(new Duration(days: -7)),
                );
                setState(() {
                  _pressedButton2 = true;
                  _pressedButton3 = false;
                  _pressedButton4 = false;
                  title = '';
                  this.dateEntries = dates;
                });

                this.dateEntries.length != 0
                    ? buildWidgetList(ListWidget(data: this.dateEntries))
                    : buildWidgetList(NoDataWidget(title: ''));
              },
            ),
            FlatButton(
              child: Text(
                '30 Tage',
                style: TextStyle(
                  color: _pressedButton3 ? Colors.white : Color(0xFFA0AEC0),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              color: _pressedButton3 ? Color(0xFF2752E4) : Colors.transparent,
              onPressed: () async {
                dates = await Provider.of<DataStates>(context, listen: false)
                    .getEditDataForDateRange(
                  DateTime.now(),
                  (new DateTime.now()).add(new Duration(days: -30)),
                );

                setState(() {
                  _pressedButton3 = true;
                  _pressedButton2 = false;
                  _pressedButton4 = false;
                  title = '';
                  this.dateEntries = dates;
                });

                this.dateEntries.length != 0
                    ? buildWidgetList(ListWidget(data: this.dateEntries))
                    : buildWidgetList(NoDataWidget(title: ''));
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
                          : Color(
                              0xFFA0AEC0,
                            ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  color:
                      _pressedButton4 ? Color(0xFF2752E4) : Colors.transparent,
                  onPressed: () async {
                    setState(() {
                      _pressedButton4 = true;
                      _pressedButton2 = false;
                      _pressedButton3 = false;
                    });
                    final List<DateTime> picked =
                        await DateRangePicker.showDatePicker(
                      locale: const Locale("de", "DE"),
                      context: context,
                      initialFirstDate: new DateTime.now(),
                      initialLastDate:
                          (new DateTime.now()).add(new Duration(days: 7)),
                      firstDate: new DateTime(2019),
                      lastDate: new DateTime(2023),
                    );

                    if (picked != null && picked.length == 2) {
                      dataPoints =
                          await Provider.of<DataStates>(context, listen: false)
                              .getDataForDateRange((picked[1]), (picked[0]));
                      dates = await Provider.of<DataStates>(context,
                              listen: false)
                          .getEditDataForDateRange((picked[1]), (picked[0]));
                      setState(() {
                        title = serverFormater.format(picked[0]) +
                            ' bis ' +
                            serverFormater.format(picked[1]);
                        sleepData = dataPoints;
                        this.dateEntries = dates;
                      });
                      this.dateEntries.length != 0
                          ? buildWidgetList(ListWidget(data: this.dateEntries))
                          : buildWidgetList(NoDataWidget(title: title));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E1164), Color(0xFF2752E4)]),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Im ausgewählten Zeitraum liegen Daten für die folgenden Tage vor:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFEDF2F7)),
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
