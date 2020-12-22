import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class HypnogramPieChart extends StatefulWidget {
  final List<DataPoint> sleepData;
  HypnogramPieChart({this.sleepData});

  @override
  _HypnogramPieChartState createState() => _HypnogramPieChartState();
}

class _HypnogramPieChartState extends State<HypnogramPieChart> {
  Map<String, double> dataMap;

  String textLabel = "Zeit";
  // ignore: non_constant_identifier_names
  bool time_percent = false;
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
          .toDouble(),
      "Wach": (widget.sleepData.where((dataPoint) => dataPoint.state == 1.0))
          .toList()
          .length
          .toDouble(),
    };
  }

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
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
                durationToString(widget.sleepData.length) +
                ' Stunden',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.0,
            ),
          ),
          ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.clock),
                  color: buttonTime ? Colors.black : Colors.grey,
                  iconSize: 24,
                  onPressed: () {
                    setState(() {
                      buttonTime = true;
                      buttonPercent = false;
                      this.textLabel = "Zeit";
                      this.time_percent = false;
                    });
                  }),
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.percent),
                  iconSize: 24,
                  color: buttonPercent ? Colors.black : Colors.grey,
                  onPressed: () {
                    setState(() {
                      buttonTime = false;
                      buttonPercent = true;
                      this.textLabel = "Prozent";
                      this.time_percent = true;
                    });
                  }),
            ],
          ),
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
                showChartValuesInPercentage: this.time_percent,
                showChartValuesOutside: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
