import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/widgets/hypnogram_piechart_widget.dart';
import 'package:frontend_somnus/widgets/no_data_widget.dart';
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

enum WidgetMarker { hypnogram, piechart }

class HypnogramScreen extends StatefulWidget {
  final Color color;
  HypnogramScreen(this.color);

  @override
  _HypnogramScreenState createState() => _HypnogramScreenState();
  static const routeName = '/hypnogram-screen';
}

class _HypnogramScreenState extends State<HypnogramScreen>
    with AutomaticKeepAliveClientMixin<HypnogramScreen> {
  bool _pressedButton1 = true;
  bool _pressedButton2 = false;
  bool _pressedButton3 = false;
  bool _pressedButton4 = false;
  String title = '';
  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  var syncList = List<Widget>();
  var list = List<Widget>();
  bool isLoading = false;
  final dataStates = DataStates();
  List<DataPoint> sleepData = [];
  List<DataPoint> dataPoints;
  List<DateTime> picked;
  final dbHelper = DatabaseHelper.instance;
  bool _canShowButton = true;
  WidgetMarker selectedWidgetMarker = WidgetMarker.hypnogram;

  void hideWidget() {
    setState(() {
      _canShowButton = !_canShowButton;
    });
  }

  @override
  initState() {
    getInitialData();
    super.initState();
  }

  getInitialData() async {
    final dataPoints = await Provider.of<DataStates>(context, listen: false)
        .getDataForSingleDate(DateTime.now());
    list.add(Sync(
      sleepData: dataPoints,
      title: title,
    ));
    setState(() {
      sleepData = dataPoints;
      title = formatter.format(DateTime.now());
      this.syncList = list;
    });
  }

  Future<List<DataPoint>> getDataToday() async {
    return await Provider.of<DataStates>(context, listen: false)
        .getDataForSingleDate(DateTime.now());
  }

  Future<List<DataPoint>> getDataYesterday() async {
    return await Provider.of<DataStates>(context, listen: false)
        .getDataForSingleDate(DateTime.now().add(new Duration(days: -1)));
  }

  Future<List<DataPoint>> getDataSevenDays() async {
    return await Provider.of<DataStates>(context, listen: false)
        .getDataForDateRange(
      DateTime.now(),
      (new DateTime.now()).add(new Duration(days: -7)),
    );
  }

  Future<List<DataPoint>> getDataCustomRange(picked) async {
    return await Provider.of<DataStates>(context, listen: false)
        .getDataForDateRange((picked[1]), (picked[0]));
  }

  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();

  _printScreen() {
    //const imageProvider = const AssetImage('assets/images/somnus_logo.png');
    // final image1 = await flutterImageProvider(imageProvider);
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
                          // child: pw.Image.provider(image1),
                        )
                      ],
                    ),
                    pw.Text('Zeitraum: ' + title),
                    pw.Expanded(
                      // ignore: deprecated_member_use
                      child: pw.Image(image),
                    ),
                    pw.Text(
                      'Schlafdauer',
                    ),
                    pw.Text(
                      'Gesamtlänge der Aufzeichnung:  ' +
                          durationToString(sleepData.length ~/ 2) +
                          ' Stunden',
                    ),
                    pw.SizedBox(
                      height: 4,
                    ),
                    pw.Text('Davon schlafend: ' +
                        durationToString((sleepData.where(
                                    (dataPoint) => dataPoint.state == 0.0))
                                .toList()
                                .length ~/
                            2) +
                        ' Stunden'),
                    pw.Text('Davon wach: ' +
                        durationToString((sleepData.where(
                                    (dataPoint) => dataPoint.state == 1.0))
                                .toList()
                                .length ~/
                            2) +
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

  Future<String> uploadFile(String filePath, String url) async {
    http.Response response;
    var request = http.MultipartRequest('POST', Uri.parse(url));
    try {
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        (await rootBundle.load(filePath)).buffer.asUint8List(),
        filename: filePath.split("/").last, //filename argument is mandatory!
      );
      request.files.add(multipartFile);
      response = await http.Response.fromStream(await request.send());
      print("Result: ${response.statusCode}");
      print(response.body);

      return response.body;
    } catch (error) {
      print('Error uploding file');
    }
    return null;
  }

  Future<List<Widget>> buildList(var dates) async {
    list = [];
    for (int i = 0; i < dates.length; i++) {
      var data = await Provider.of<DataStates>(context, listen: false)
          .getDataForSingleDate(dates[i].date);
      list.add(Sync(title: formatter.format(dates[i].date), sleepData: data));
    }
    return list;
  }

  Widget getWidget() {
    switch (selectedWidgetMarker) {
      case WidgetMarker.hypnogram:
        return !isLoading
            ? Column(
                children: [
                  ((this.sleepData == null || this.sleepData.length == 0)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NoDataWidget(title: this.title),
                        )
                      : Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 15),
                              child: RepaintBoundary(
                                key: _printKey,
                                child: Column(
                                  children: syncList,
                                ),
                              ),
                            ),
                          ],
                        )),
                ],
              )
            : Container(
                child: Text('Daten werden geladen ...'),
                alignment: Alignment.center,
                height: 200,
              );
      case WidgetMarker.piechart:
        if (!isLoading && sleepData.length != 0) {
          return HypnogramPieChart(
            sleepData: this.sleepData,
          );
        } else {
          if (isLoading) {
            return Container(
              child: Text('Daten werden geladen ...'),
              alignment: Alignment.center,
              height: 200,
            );
          }
          if (sleepData.length == 0) {
            return NoDataWidget(title: title);
          }
        }

        Container(
          child: Text('Daten werden geladen ...'),
          alignment: Alignment.center,
          height: 200,
        );
    }
  }

  // Widget buildFlatButton(String title, bool button) {
  //   return FlatButton(
  //     child: Text(
  //       title,
  //       style: TextStyle(
  //         color: button ? Colors.white : Theme.of(context).accentColor,
  //       ),
  //     ),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(18.0),
  //       side: BorderSide(color: Theme.of(context).accentColor),
  //     ),
  //     color: button ? Theme.of(context).accentColor : Colors.white,
  //     onPressed: () {
  //       setState(() {
  //         button = true;
  //       });
  //     },
  //   );
  // }

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
                  'Heute',
                  style: TextStyle(
                    color: _pressedButton1
                        ? Colors.white
                        : Color(
                            0xFFA0AEC0,
                          ),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                color: _pressedButton1 ? Color(0xFF2752E4) : Colors.transparent,
                onPressed: () async {
                  setState(() {
                    _pressedButton1 = true;
                    _pressedButton2 = false;
                    _pressedButton3 = false;
                    _pressedButton4 = false;
                    //isLoading = true;
                  });
                  dataPoints = await getDataToday();
                  list = [];
                  list.add(
                    Sync(
                      sleepData: dataPoints,
                      title: formatter.format(DateTime.now()),
                    ),
                  );
                  setState(() {
                    title = formatter.format(DateTime.now());
                    sleepData = dataPoints;
                    this.syncList = list;
                    isLoading = false;
                  });
                },
              ),
              FlatButton(
                child: Text(
                  'Gestern',
                  style: TextStyle(
                    color: _pressedButton2 ? Colors.white : Color(0xFFA0AEC0),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                color: _pressedButton2 ? Color(0xFF2752E4) : Colors.transparent,
                onPressed: () async {
                  setState(() {
                    _pressedButton2 = true;
                    _pressedButton1 = false;
                    _pressedButton3 = false;
                    _pressedButton4 = false;
                    // isLoading = true;
                  });
                  dataPoints = await getDataYesterday();
                  list = [];
                  list.add(Sync(
                    sleepData: dataPoints,
                    title: formatter
                        .format(DateTime.now().add(new Duration(days: -1))),
                  ));

                  setState(() {
                    isLoading = false;
                    this.title = formatter
                        .format(DateTime.now().add(new Duration(days: -1)));
                    sleepData = dataPoints;
                    this.syncList = list;
                  });
                },
              ),
              FlatButton(
                child: Text(
                  '7 Tage',
                  style: TextStyle(
                    color: _pressedButton3 ? Colors.white : Color(0xFFA0AEC0),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                color: _pressedButton3 ? Color(0xFF2752E4) : Colors.transparent,
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    _pressedButton3 = true;
                    _pressedButton1 = false;
                    _pressedButton2 = false;
                    _pressedButton4 = false;
                  });
                  dataPoints = await getDataSevenDays();
                  var dates =
                      await Provider.of<DataStates>(context, listen: false)
                          .getEditDataForDateRange(DateTime.now(),
                              (new DateTime.now()).add(new Duration(days: -7)));
                  await buildList(dates);
                  setState(() {
                    title = formatter.format(
                            (DateTime.now()).add(new Duration(days: -7))) +
                        ' bis ' +
                        formatter.format(DateTime.now()).toString();
                    sleepData = dataPoints;
                    this.syncList = list;
                    isLoading = false;
                  });
                },
              ),
              DatePickerTheme(
                Builder(
                  builder: (context) => FlatButton(
                    child: new Text(
                      'Custom',
                      style: TextStyle(
                        color:
                            _pressedButton4 ? Colors.white : Color(0xFFA0AEC0),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    color: _pressedButton4
                        ? Color(0xFF2752E4)
                        : Colors.transparent,
                    onPressed: () async {
                      setState(() {
                        _pressedButton4 = true;
                        _pressedButton1 = false;
                        _pressedButton2 = false;
                        _pressedButton3 = false;
                      });
                      picked = await DateRagePicker.showDatePicker(
                        locale: const Locale("de", "DE"),
                        context: context,
                        initialFirstDate: new DateTime.now(),
                        initialLastDate:
                            (new DateTime.now()).add(new Duration(days: 7)),
                        firstDate: new DateTime(2019),
                        lastDate: new DateTime(2023),
                      );

                      if (picked != null && picked.length == 2) {
                        setState(() {
                          isLoading = true;
                        });
                        dataPoints = await Provider.of<DataStates>(context,
                                listen: false)
                            .getDataForDateRange((picked[1]), (picked[0]));
                        var dates = await Provider.of<DataStates>(context,
                                listen: false)
                            .getEditDataForDateRange((picked[1]), (picked[0]));
                        await buildList(dates);

                        setState(() {
                          title = formatter.format(picked[0]) +
                              ' bis ' +
                              formatter.format(picked[1]);
                          sleepData = dataPoints;
                          this.syncList = list;
                          isLoading = false;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Color(0xFF1E1164),
                // expandedHeight: 200.0,
                floating: false,
                pinned: true,
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FlatButton(
                        onPressed: () {
                          setState(() {
                            selectedWidgetMarker = WidgetMarker.hypnogram;
                          });
                        },
                        child: Text(
                          'Hypnogramm(e)',
                          style: TextStyle(
                              color: (selectedWidgetMarker ==
                                      WidgetMarker.hypnogram)
                                  ? Color(0xFFEDF2F7)
                                  : Color(0xFFA0AEC0)),
                        )),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          selectedWidgetMarker = WidgetMarker.piechart;
                        });
                      },
                      child: Text(
                        'Schlafdauer',
                        style: TextStyle(
                            color:
                                (selectedWidgetMarker == WidgetMarker.piechart)
                                    ? Color(0xFFEDF2F7)
                                    : Color(0xFFA0AEC0)),
                      ),
                    )
                  ],
                ),
              ),
            ];
          },
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E1164),
                    Color(0xFF2752E4),
                  ]),
            ),
            child: SingleChildScrollView(
              child: Container(
                child: getWidget(),
              ),
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            this.sleepData.length != 0 &&
                    selectedWidgetMarker == WidgetMarker.hypnogram
                ? FloatingActionButton(
                    heroTag: null,
                    child: const Icon(Icons.print),
                    onPressed: _printScreen,
                  )
                : const SizedBox.shrink(),
            !_canShowButton
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      heroTag: null,
                      child: const Icon(Icons.upload_file),
                      onPressed: () async {
                        final snackBar = SnackBar(
                          content: Text('Daten werden verarbeitet'),
                        );

                        Scaffold.of(context).showSnackBar(snackBar);

                        hideWidget();

                        // var res = await uploadFile(
                        //     'assets/incoming.csv', 'http://10.0.2.2:5000/data');

                        try {
                          final res =
                              await rootBundle.loadString("assets/result.csv");
                          await dbHelper.resultsToDb(res);
                        } catch (error) {
                          final snackBar = SnackBar(
                            content: Text('Fehler bei der Datenverarbeitung'),
                          );

                          Scaffold.of(context).showSnackBar(snackBar);
                        }
                        hideWidget();
                        if (_pressedButton1) {
                          dataPoints = await getDataToday();
                          list = [];
                          list.add(Sync(
                            sleepData: dataPoints,
                            title: formatter.format(DateTime.now()),
                          ));
                        }
                        if (_pressedButton2) {
                          dataPoints = await getDataYesterday();
                          list = [];
                          list.add(Sync(
                            sleepData: dataPoints,
                            title: formatter.format(
                                DateTime.now().add(new Duration(days: -1))),
                          ));
                        }
                        if (_pressedButton3) {
                          dataPoints = await getDataSevenDays();
                          var dates = await Provider.of<DataStates>(context,
                                  listen: false)
                              .getEditDataForDateRange(
                                  DateTime.now(),
                                  (new DateTime.now())
                                      .add(new Duration(days: -7)));
                          await buildList(dates);
                        }
                        if (_pressedButton4) {
                          dataPoints = await Provider.of<DataStates>(context,
                                  listen: false)
                              .getDataForDateRange((picked[1]), (picked[0]));
                          var dates = await Provider.of<DataStates>(context,
                                  listen: false)
                              .getEditDataForDateRange(
                                  (picked[1]), (picked[0]));
                          await buildList(dates);
                        }
                        setState(() {
                          sleepData = dataPoints;
                          this.syncList = list;
                        });
                      },
                    ),
                  ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
