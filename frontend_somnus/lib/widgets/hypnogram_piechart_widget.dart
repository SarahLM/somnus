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

  String textLabel = "Zeit in Minuten";
  bool buttonTime = true;
  bool buttonPercent = false;

  List<Color> colorList = [
    Color(0xFF0353ed),
    Color(0xFFf01d7e),
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
  }

  String durationToStringAlternative(int min) {
    Duration d = new Duration(minutes: min);
    var seconds = d.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('$hours h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('$minutes min');
    }

    return tokens.join(':');
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
        color: buttonUsed ? Color(0xFFEDF2F7) : Color(0xFFA0AEC0),
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
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Card(
        elevation: 8,
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Schlafdauer',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEDF2F7)),
            ),
            Text(
              'Gesamtlänge der Aufzeichnung:  ' +
                  durationToStringAlternative(widget.sleepData.length ~/ 2)
                      .toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
                color: Color(0xFFEDF2F7),
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
                  legendTextStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFFEDF2F7)),
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
      ),
    );
  }
}
