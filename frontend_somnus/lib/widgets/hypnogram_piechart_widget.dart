import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:pie_chart/pie_chart.dart';

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

  Map<String, double> getDataList() {
    return dataMap = {
      "Wach": (widget.sleepData.where((dataPoint) => dataPoint.state == 1.0))
          .toList()
          .length
          .toDouble(),
      "Schlaf": (widget.sleepData.where((dataPoint) => dataPoint.state == 0.0))
          .toList()
          .length
          .toDouble(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Schlafdauer',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                  child: Text(
                    'in Zeit',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.purple),
                  ),
                  onPressed: () {
                    setState(() {
                      this.textLabel = "Zeit";
                      this.time_percent = false;
                    });
                  }),
              FlatButton(
                  child: Text(
                    'in Prozent',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.purple),
                  ),
                  onPressed: () {
                    setState(() {
                      this.textLabel = "Prozent";
                      this.time_percent = true;
                    });
                  }),
            ],
          ),
          Container(
              child: PieChart(
            dataMap: getDataList(),
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 3.2,
            //colorList: colorList,
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
              showChartValuesOutside: false,
            ),
          )
              //SfCircularChart(
              //   series: <CircularSeries>[
              //     // Renders doughnut chart
              //     DoughnutSeries<DataPoint, DateTime>(

              //         dataSource: sleepData,
              //         //pointColorMapper: (DataPoint data, _) => data.color,
              //         xValueMapper: (DataPoint data, _) => data.date,
              //         yValueMapper: (DataPoint data, _) => data.state,
              //         dataLabelSettings: DataLabelSettings(
              //             // Renders the data label
              //             isVisible: true),
              //         // Mode of grouping
              //         groupMode: CircularChartGroupMode.value,
              //         groupTo: 2)
              //   ],
              // ),
              ),
        ],
      ),
    );
  }
}
