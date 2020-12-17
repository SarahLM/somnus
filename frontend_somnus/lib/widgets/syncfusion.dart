//import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:frontend_somnus/widgets/hypnogram_piechart_widget.dart';
//import 'package:frontend_somnus/providers/states.dart';
//import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Sync extends StatelessWidget {
  final String title;
  final List<DataPoint> sleepData;
  Sync({this.title, this.sleepData});

  final f = new DateFormat('dd.MM.yyyy hh:mm');
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 300,
              child: Card(
                elevation: 8,
                //Initialize chart
                child: SfCartesianChart(
                    plotAreaBorderColor: Colors.transparent,
                    //plotAreaBackgroundColor: Colors.grey,
                    zoomPanBehavior: ZoomPanBehavior(
                        // Performs zooming on double tap
                        enableSelectionZooming: true,
                        selectionRectBorderColor: Colors.red,
                        selectionRectBorderWidth: 1,
                        selectionRectColor: Colors.grey),
                    enableAxisAnimation: true,
                    tooltipBehavior: TooltipBehavior(enable: true),
                    title: ChartTitle(text: this.title),
                    primaryXAxis: DateTimeAxis(
                      isVisible: false,
                      majorGridLines: MajorGridLines(width: 0),
                      dateFormat: f,
                      // interval: 1,
                      labelRotation: 90,
                      plotBands: <PlotBand>[
                        /*   Plot band different height for sleep and awake */

                        PlotBand(
                          isVisible: true,
                          // start: DateTime(2017, 9, 7, 17, 31),
                          // end: DateTime(2017, 9, 7, 17, 58),
                          associatedAxisStart: 0.5,
                          associatedAxisEnd: 0,
                          shouldRenderAboveSeries: false,
                          color: const Color.fromRGBO(
                              0, 0, 139, 0.2), //Color of the sleep periods
                          opacity: 0.6,
                        ),

                        /* Plot band same height for sleep and awake */

                        // PlotBand(
                        //   isVisible: true,
                        //   // start: DateTime(2017, 9, 7, 17, 31),
                        //   // end: DateTime(2017, 9, 7, 17, 58),
                        //   associatedAxisStart: 0,
                        //   associatedAxisEnd: 1,
                        //   shouldRenderAboveSeries: false,
                        //   color: const Color.fromRGBO(
                        //       0, 0, 139, 0.2), //Color of the sleep periods
                        //   opacity: 0.6,
                        // ),
                      ],
                    ),
                    primaryYAxis: NumericAxis(
                      interval: 1,
                      maximum: 1.0,
                      //minimum: -0.5,
                      //maximum: 5.1,
                      //rangePadding: ChartRangePadding.additional,
                      isVisible: false,
                    ),
                    series: <ChartSeries>[
                      // Initialize line series
                      StepAreaSeries<DataPoint, DateTime>(
                          //animationDuration: 2000,
                          color: const Color.fromRGBO(
                              252, 176, 28, 1), //Color of awake periods
                          opacity: 1.0,
                          //emptyPointSettings: EmptyPointSettings(color: Colors.black),
                          dataSource: sleepData,
                          //pointColorMapper: (SalesData sales, _) =>
                          //   sales.segmentColor,
                          xValueMapper: (DataPoint sales, _) => sales.date,
                          yValueMapper: (DataPoint sales, _) => sales.state,
                          // dataLabelSettings: DataLabelSettings(isVisible: true),
                          name: '24 Stunden')
                    ]),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      height: 30,
                      width: 20,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 139, 0.6),
                        //border: Border.all(color: Colors.blueAccent),
                      ),
                    ),
                    Text('Schlaf'),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      height: 30,
                      width: 20,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(252, 176, 28, 0.7),
                        //border: Border.all(color: Colors.blueAccent),
                      ),
                    ),
                    Text('Wach')
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Aufgezeichnete Datenpunkte:  ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
              ),
            ),
            Text(sleepData.length.toString()),
            SizedBox(
              height: 20,
            ),
            Text(
              'Gesamtschlafdauer:  ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
              ),
            ),
            Text((sleepData.where((dataPoint) => dataPoint.state == 0.0))
                    .toList()
                    .length
                    .toString() +
                ' Minuten'),
            HypnogramPieChart(
              sleepData: this.sleepData,
            ),
          ],
        ),
      ),
    );
  }
}

// class DataPoint {
//   DataPoint(this.date, this.state);
//   final DateTime date;
//   final double state;
//   // final Color segmentColor;
// }
