import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:pie_chart/pie_chart.dart';
//import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class HypnogramPieChart extends StatelessWidget {
  final List<DataPoint> sleepData;
  Map<String, double> dataMap;
  String textLabel;

  Map<String, double> getDataList() {
    return dataMap = {
      "Wach": (sleepData.where((dataPoint) => dataPoint.state == 1.0))
          .toList()
          .length
          .toDouble(),
      "Schlaf": (sleepData.where((dataPoint) => dataPoint.state == 0.0))
          .toList()
          .length
          .toDouble(),
    };
  }

  HypnogramPieChart({this.sleepData});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Schlafdauer'),
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
                onPressed: () {}),
            FlatButton(
                child: Text(
                  'in Prozent',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.purple),
                ),
                onPressed: () {}),
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
            // legendPosition: LegendPosition.right,
            showLegends: true,
            // legendShape: _BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true,
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
    );
  }
}
