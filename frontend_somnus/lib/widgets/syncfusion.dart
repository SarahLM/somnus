import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Sync extends StatelessWidget {
  final f = new DateFormat('dd.MM.yyyy hh:mm');
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          //Initialize chart
          child: SfCartesianChart(
              zoomPanBehavior: ZoomPanBehavior(
                  // Performs zooming on double tap
                  enableSelectionZooming: true,
                  selectionRectBorderColor: Colors.red,
                  selectionRectBorderWidth: 1,
                  selectionRectColor: Colors.grey),
              enableAxisAnimation: true,
              tooltipBehavior: TooltipBehavior(enable: true),
              title: ChartTitle(text: '24 Stunden'),
              primaryXAxis: DateTimeAxis(
                dateFormat: f,
                interval: 1,
                labelRotation: 90,
              ),
              primaryYAxis: NumericAxis(
                interval: 1,
                // minimum: -0.1,
                //maximum: 1.1,
                rangePadding: ChartRangePadding.additional,
                isVisible: false,
              ),
              series: <ChartSeries>[
                // Initialize line series
                LineSeries<SalesData, DateTime>(
                    dataSource: [
                      // Bind data source
                      SalesData(DateTime(2017, 9, 7, 17, 31), 0.0, Colors.red),
                      SalesData(DateTime(2017, 9, 7, 17, 32), 0.0, Colors.red),
                      SalesData(DateTime(2017, 9, 7, 17, 33), 0.0, Colors.red),
                      SalesData(DateTime(2017, 9, 7, 17, 34), 0.0, Colors.red),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 35), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 36), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 37), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 38), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 39), 1.0, Colors.green),
                      SalesData(DateTime(2017, 9, 7, 17, 40), 0.0, Colors.red),
                      SalesData(DateTime(2017, 9, 7, 17, 41), 0.0, Colors.red),
                      SalesData(DateTime(2017, 9, 7, 17, 42), 0.0, Colors.red),
                      SalesData(DateTime(2017, 9, 7, 17, 43), 0.0, Colors.red),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 44), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 45), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 46), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 47), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 48), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 49), 1.0, Colors.green),
                      SalesData(DateTime(2017, 9, 7, 17, 50), 0.0, Colors.red),
                      SalesData(DateTime(2017, 9, 7, 17, 51), 0.0, Colors.red),
                      SalesData(DateTime(2017, 9, 7, 17, 52), 0.0, Colors.red),
                      SalesData(DateTime(2017, 9, 7, 17, 53), 0.0, Colors.red),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 54), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 55), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 56), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 57), 1.0, Colors.green),
                      SalesData(
                          DateTime(2017, 9, 7, 17, 58), 1.0, Colors.green),
                    ],
                    pointColorMapper: (SalesData sales, _) =>
                        sales.segmentColor,
                    xValueMapper: (SalesData sales, _) => sales.year,
                    yValueMapper: (SalesData sales, _) => sales.state,
                    // dataLabelSettings: DataLabelSettings(isVisible: true),
                    name: '24 Stunden')
              ]),
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.state, this.segmentColor);
  final DateTime year;
  final double state;
  final Color segmentColor;
}
