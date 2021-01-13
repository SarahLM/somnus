import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart';

class HypnogramPieChart extends StatefulWidget {
  final List<DataPoint> sleepData;
  HypnogramPieChart({this.sleepData});

  @override
  _HypnogramPieChartState createState() => _HypnogramPieChartState();
}

class _HypnogramPieChartState extends State<HypnogramPieChart> {
  Map<String, double> dataMap;

  String textLabel = "Zeit";
  bool buttonTime = true;
  bool buttonPercent = false;

  List<Color> colorList = [
    Color(0xFF0529B3),
    Color(0xFFFF9221),
  ];

  Map<String, double> getDataList() {
    return dataMap = {
      "Schlaf": (widget.sleepData.where((dataPoint) => dataPoint.state == 0.0))
              .toList()
              .length
              .toDouble() /
          2,
      "Wach": (widget.sleepData.where((dataPoint) => dataPoint.state == 1.0))
              .toList()
              .length
              .toDouble() /
          2,
    };
  }

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    // List<String> parts = d.toString().split(':');
    // return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  Map<String, IconData> iconMapping = {
    'time': FontAwesomeIcons.clock,
    'percent': FontAwesomeIcons.percent,
  };

  Widget buildButton(
      {@required bool buttonUsed,
      @required String text,
      @required bool timeButton,
      @required bool percentButton,
      @required String icon}) {
    return IconButton(
        icon: FaIcon(iconMapping[icon]),
        color: buttonUsed ? Colors.black : Colors.grey,
        iconSize: 24,
        onPressed: () {
          setState(
            () {
              this.buttonTime = timeButton;
              this.buttonPercent = percentButton;
              textLabel = text;
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Schlafdauer',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Gesamtlänge der Aufzeichnung:  ' +
                durationToString(widget.sleepData.length ~/ 2).toString() +
                ' Stunden',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.0,
            ),
          ),
          ButtonBar(mainAxisSize: MainAxisSize.min, children: <Widget>[
            buildButton(
                buttonUsed: buttonTime,
                text: "Zeit in Minuten",
                timeButton: true,
                percentButton: false,
                icon: 'time'),
            buildButton(
                buttonUsed: buttonPercent,
                text: "Prozent",
                timeButton: false,
                percentButton: true,
                icon: 'percent')
          ]),
          Container(
            child: PieChart(
              dataMap: getDataList(),
              animationDuration: Duration(milliseconds: 3000),
              chartLegendSpacing: 32,
              chartRadius: MediaQuery.of(context).size.width / 3.2,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              centerText: textLabel,
              legendOptions: LegendOptions(
                showLegendsInRow: true,
                legendPosition: LegendPosition.bottom,
                showLegends: true,
                //legendShape: LegendShape.circle,
                legendTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              chartValuesOptions: ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: this.buttonPercent,
                showChartValuesOutside: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
