import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Sync extends StatelessWidget {
  final String title;
  final List<DataPoint> sleepData;
  final DateFormat dateFormat;
  final double interval;
  final Color colorAsleep = Color(0xFF0529B3);
  final Color colorAwake = Color(0xFFFF9221);

  Sync({
    @required this.title,
    @required this.sleepData,
    @required this.dateFormat,
    @required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(15),
      child: Center(
        child: Column(
          children: [
            this.title != '' ? Text(this.title) : Text(''),
            Container(
              height: 418,
              child: Card(
                elevation: 8,
                //Initialize chart
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Hypnogramm',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SfCartesianChart(
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
                        // title: ChartTitle(
                        //   text: this.title,
                        // ),
                        primaryXAxis: DateTimeAxis(
                          isVisible: true,
                          majorGridLines: MajorGridLines(width: 0),
                          dateFormat: this.dateFormat,
                          interval: this.interval,
                          labelRotation: 90,
                          plotBands: <PlotBand>[
                            /*   Plot band: different height for sleep and awake */

                            PlotBand(
                              isVisible: true,
                              // start: DateTime(2017, 9, 7, 17, 31),
                              // end: DateTime(2017, 9, 7, 17, 58),
                              associatedAxisStart: 0.5,
                              associatedAxisEnd: 0,
                              shouldRenderAboveSeries: false,
                              color: colorAsleep,
                              // const Color.fromRGBO(
                              //     0, 0, 139, 0.2), //Color of the sleep periods
                              opacity: 1.0,
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
                              emptyPointSettings: EmptyPointSettings(
                                  mode: EmptyPointMode.zero,
                                  color: Colors.transparent),
                              //animationDuration: 2000,
                              color: colorAwake,
                              // const Color.fromRGBO(
                              //     252, 176, 28, 1), //Color of awake periods
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
                    // SizedBox(
                    //   height: 10,
                    // ),
                    Divider(
                      color: Theme.of(context).accentColor,
                      height: 0,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
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
                                color: colorAsleep,
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
                                color: colorAwake,
                                //border: Border.all(color: Colors.blueAccent),
                              ),
                            ),
                            Text('Wach')
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 20,
            ),
            // Text(
            //   'Aufgezeichnete Datenpunkte:  ',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontWeight: FontWeight.w600,
            //     fontSize: 12.0,
            //   ),
            // ),
            // Text(sleepData.length.toString()),
            // SizedBox(
            //   height: 20,
            // ),
            // Text(
            //   'Gesamtschlafdauer:  ',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontWeight: FontWeight.w600,
            //     fontSize: 12.0,
            //   ),
            // ),
            // Text((sleepData.where((dataPoint) => dataPoint.state == 0.0))
            //         .toList()
            //         .length
            //         .toString() +
            //     ' Minuten'),
            // HypnogramPieChart(
            //   sleepData: this.sleepData,
            // ),
          ],
        ),
      ),
    );
  }
}
