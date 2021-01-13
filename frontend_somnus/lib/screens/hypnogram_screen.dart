import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/widgets/hypnogram_piechart_widget.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../widgets/date_range_picker_custom.dart' as DateRagePicker;
import 'package:frontend_somnus/widgets/syncfusion.dart';
import 'package:frontend_somnus/widgets/theme.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'database_helper.dart';

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
  String timePrinted;

  final dataStates = DataStates();

  List<DataPoint> sleepData;
  List<DataPoint> dataPoints;
  final dbHelper = DatabaseHelper.instance;

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
      timePrinted = DateTime.now().toString();
    });
  }

  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();

  Future<Uint8List> _printScreen() async {
    const imageProvider = const AssetImage('assets/images/somnus_logo.png');
    final image1 = await flutterImageProvider(imageProvider);
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
            return pw.Container(
              padding: pw.EdgeInsets.all(8),
              child: pw.Center(
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: <pw.Widget>[
                        pw.Text('Somnus',
                            textScaleFactor: 1.5,
                            style: pw.TextStyle(
                              fontStyle: pw.FontStyle.italic,
                              fontWeight: pw.FontWeight.bold,
                            )),
                        pw.Container(
                          height: 50,
                          width: 50,
                          child: pw.Image.provider(image1),
                        )
                      ],
                    ),
                    pw.Text('Zeitraum: ' + timePrinted),
                    pw.Expanded(
                      child: pw.Image(image),
                    ),
                    pw.Text(
                      'Schlafdauer',
                    ),
                    pw.Text(
                      'Gesamtlänge der Aufzeichnung:  ' +
                          durationToString(sleepData.length) +
                          ' Stunden',
                    ),
                    pw.SizedBox(
                      height: 4,
                    ),
                    pw.Text('Davon schlafend: ' +
                        durationToString((sleepData
                                .where((dataPoint) => dataPoint.state == 0.0))
                            .toList()
                            .length) +
                        ' Stunden'),
                    pw.Text('Davon wach: ' +
                        durationToString((sleepData
                                .where((dataPoint) => dataPoint.state == 1.0))
                            .toList()
                            .length) +
                        ' Stunden'),
                  ],
                ),
              ),
            );
          }));

      return doc.save();
    });
  }

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  Future<String> uploadFile(String filename, String url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      (await rootBundle.load('assets/inputAccelero.csv')).buffer.asUint8List(),
      filename: 'inputAccelero.csv', // use the real name if available, or omit
    );

    //await new File('assets/out.csv').create(recursive: false);
    //var myFile = File('assets/out.csv');
    // var out = myFile.openWrite();
    request.files.add(multipartFile);
    var res = await request.send();
    var string = res.stream.transform(new Utf8Decoder()).listen(null);
    // out.write(string);
    return res.reasonPhrase;
    //return string;
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
                // final dataStatesData =
                //Provider.of<DataStates>(context, listen: false);
                //final dataPoints = dataStatesData.items;
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
                  timePrinted = (DateTime.now().toString());
                });
              },
            ),
            FlatButton(
              child: Text(
                'Gestern',
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
                // final dataPoints =
                //     Provider.of<DataStates>(context, listen: false).findByDate(
                //         (new DateTime.now()).add(new Duration(days: -2)),
                //         DateTime.now());
                final DateTime date1 = DateTime.now();
                dataPoints = await Provider.of<DataStates>(context,
                        listen: false)
                    .getDataForSingleDate(date1.add(new Duration(days: -1)));
                setState(() {
                  _pressedButton2 = true;
                  _pressedButton1 = false;
                  _pressedButton3 = false;
                  _pressedButton4 = false;
                  title = '';
                  sleepData = dataPoints;
                  timePrinted =
                      (DateTime.now()).add(new Duration(days: -2)).toString() +
                          ' bis ' +
                          DateTime.now().toString();
                });
                //dataStates.getResult();
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
              onPressed: () async {
                final dataPoints =
                    await Provider.of<DataStates>(context, listen: false)
                        .getDataForDateRange(
                  DateTime.now(),
                  (new DateTime.now()).add(new Duration(days: -7)),
                );
                setState(() {
                  _pressedButton3 = true;
                  _pressedButton1 = false;
                  _pressedButton2 = false;
                  _pressedButton4 = false;
                  title = '';
                  sleepData = dataPoints;
                  timePrinted = DateFormat('dd.MM. yyyy')
                          .format((DateTime.now()).add(new Duration(days: -7)))
                          .toString() +
                      ' bis ' +
                      DateFormat('dd.MM. yyyy')
                          .format(DateTime.now())
                          .toString();
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
                      firstDate: new DateTime(2021),
                      lastDate: new DateTime(2023),
                    );

                    if (picked != null && picked.length == 2) {
                      print(picked);
                      print(picked.runtimeType);
                      dataPoints =
                          await Provider.of<DataStates>(context, listen: false)
                              .getDataForDateRange((picked[1]), (picked[0]));
                      setState(() {
                        title = DateFormat('dd.MM. yyyy')
                                .format(picked[0])
                                .toString() +
                            ' bis ' +
                            DateFormat('dd.MM. yyyy')
                                .format(picked[1])
                                .toString();
                        sleepData = dataPoints;
                        timePrinted = title;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container(
            //   alignment: Alignment.center,
            //   color: widget.color,
            //   child: Container(),
            // ),
            //LineAreaPage(),
            //LineAreaPage(),
            ((this.sleepData.length == 0)
                ? Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Icon(
                              Icons.sentiment_dissatisfied,
                              color: Colors.orange,
                              size: 60.0,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(
                              'Für den ausgewählten Zeitraum ' +
                                  title +
                                  ' liegen keine Daten vor.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: Column(
                      children: [
                        Container(
                          child: RepaintBoundary(
                            key: _printKey,
                            child: Sync(
                              title: this.title,
                              sleepData: this.sleepData,
                            ),
                          ),
                        ),
                        HypnogramPieChart(
                          sleepData: this.sleepData,
                        ),
                        SizedBox(height: 20),
                        // Text(
                        //   'Schlafdauer',
                        //   style: TextStyle(
                        //       fontSize: 20, fontWeight: FontWeight.bold),
                        // ),
                        // Text(
                        //   'Gesamtlänge der Aufzeichnung:  ' +
                        //       durationToString(sleepData.length) +
                        //       ' Stunden',
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.w600,
                        //     fontSize: 12.0,
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 4,
                        // ),
                        // Text('Davon schlafend: ' +
                        //     durationToString((sleepData.where(
                        //             (dataPoint) => dataPoint.state == 0.0))
                        //         .toList()
                        //         .length) +
                        //     ' Stunden'),
                        // Text('Davon wach: ' +
                        //     durationToString((sleepData.where(
                        //             (dataPoint) => dataPoint.state == 1.0))
                        //         .toList()
                        //         .length) +
                        //     ' Stunden'),
                      ],
                    ),
                  )
            //LineAreaPage()
            ),
          ],
        ),
      ),
      floatingActionButton: this.sleepData.length != 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  child: const Icon(Icons.print),
                  onPressed: _printScreen,
                ),
                FloatingActionButton(
                  child: const Icon(Icons.upload_file),
                  onPressed: () async {
                    var file = 'inputAccelero.csv';

                    var res =
                        await uploadFile(file, 'http://10.0.2.2:5000/data');

                    print(res);
                    dbHelper.resultsToDb();
                  },
                ),
              ],
            )
          : Container(),
    );
  }
}
