import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/widgets/hypnogram_piechart_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
//import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import '../widgets/date_range_picker_custom.dart' as DateRagePicker;
import 'package:frontend_somnus/widgets/syncfusion.dart';
import 'package:frontend_somnus/widgets/theme.dart';
import 'package:pdf/widgets.dart' as pw;

class HypnogramScreen extends StatefulWidget {
  final Color color;
  // buttonTextStyle = TextStyle(color: Theme.of(context).accentColor);

  HypnogramScreen(this.color);

  @override
  _HypnogramScreenState createState() => _HypnogramScreenState();
}

class _HypnogramScreenState extends State<HypnogramScreen> {
  bool _pressedButton1 = true;
  bool _pressedButton2 = false;
  bool _pressedButton3 = false;
  bool _pressedButton4 = false;
  String title = '';

  List<DataPoint> sleepData;
  List<DataPoint> dataPoints;

  @override
  initState() {
    final dataStatesData = Provider.of<DataStates>(context, listen: false);
    final dataPoints = dataStatesData.items;
    setState(() {
      sleepData = dataPoints;
    });
    super.initState();
  }

  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();

  Future<Uint8List> _printScreen() {
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pw.Document();

      final image = await wrapWidget(
        doc.document,
        key: _printKey,
        pixelRatio: 2.0,
      );

      doc.addPage(pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Expanded(
                child: pw.Image(image),
              ),
            );
          }));

      return doc.save();
    });
  }

  Widget buildFlatButton(String title, bool button) {
    return FlatButton(
      child: Text(
        title,
        style: TextStyle(
          color: button ? Colors.white : Theme.of(context).accentColor,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Theme.of(context).accentColor),
      ),
      color: button ? Theme.of(context).accentColor : Colors.white,
      onPressed: () {
        setState(() {
          button = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          ButtonBar(
            //mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                child: Text(
                  'Letzte Aufnahme',
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
                onPressed: () {
                  final dataStatesData =
                      Provider.of<DataStates>(context, listen: false);
                  final dataPoints = dataStatesData.items;
                  setState(() {
                    _pressedButton1 = true;
                    _pressedButton2 = false;
                    _pressedButton3 = false;
                    _pressedButton4 = false;
                    title = '';
                    sleepData = dataPoints;
                  });
                },
              ),
              FlatButton(
                child: Text(
                  '24 Stunden',
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
                onPressed: () {
                  final dataPoints =
                      Provider.of<DataStates>(context, listen: false)
                          .findByDate(
                              (new DateTime.now()).add(new Duration(days: -2)),
                              DateTime.now());
                  setState(() {
                    _pressedButton2 = true;
                    _pressedButton1 = false;
                    _pressedButton3 = false;
                    _pressedButton4 = false;
                    title = '';
                    sleepData = dataPoints;
                  });
                },
              ),
              FlatButton(
                child: Text(
                  '7 Tage',
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
                onPressed: () {
                  final dataPoints =
                      Provider.of<DataStates>(context, listen: false)
                          .findByDate(
                              (new DateTime.now()).add(new Duration(days: -7)),
                              DateTime.now());
                  setState(() {
                    _pressedButton3 = true;
                    _pressedButton1 = false;
                    _pressedButton2 = false;
                    _pressedButton4 = false;
                    title = '';
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
                        firstDate: new DateTime(2020),
                        lastDate: new DateTime(2022),
                      );

                      if (picked != null && picked.length == 2) {
                        print(picked);
                        print(picked.runtimeType);
                        dataPoints =
                            Provider.of<DataStates>(context, listen: false)
                                .findByDate((picked[0]), (picked[1]));
                        setState(() {
                          title = picked.toString();
                          sleepData = dataPoints;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              color: widget.color,
              child: Container(),
            ),
            //LineAreaPage(),
            //LineAreaPage(),
            ((this.sleepData.length == 0)
                ? Text('Für den ausgewählten Zeitraum ' +
                    title +
                    ' liegen keine Daten vor.')
                : Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        RepaintBoundary(
                          key: _printKey,
                          child: Sync(
                            title: this.title,
                            sleepData: this.sleepData,
                          ),
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
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.print),
        onPressed: _printScreen,
      ),
    );
  }
}
