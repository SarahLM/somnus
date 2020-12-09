import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Sync extends StatelessWidget {
  final String title;
  Sync({this.title});

  final f = new DateFormat('dd.MM.yyyy hh:mm');
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Center(
        child: Column(
          children: [
            Card(
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
                    majorGridLines: MajorGridLines(width: 0),
                    dateFormat: f,
                    interval: 4,
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
                    //maximum: 1.0,
                    //minimum: -0.5,
                    //maximum: 5.1,
                    //rangePadding: ChartRangePadding.additional,
                    isVisible: false,
                  ),
                  series: <ChartSeries>[
                    // Initialize line series
                    StepAreaSeries<SalesData, DateTime>(
                        color: const Color.fromRGBO(
                            252, 176, 28, 1), //Color of awake periods
                        opacity: 1.0,
                        //emptyPointSettings: EmptyPointSettings(color: Colors.black),
                        dataSource: [
                          // Bind data source
                          SalesData(
                            DateTime(2017, 9, 7, 17, 31),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 32),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 33),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 34),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 35),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 36),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 37),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 38),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 39),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 40),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 41),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 42),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 43),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 44),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 45),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 46),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 47),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 48),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 49),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 50),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 51),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 52),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 53),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 54),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 55),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 56),
                            0.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 57),
                            1.0,
                          ),
                          SalesData(
                            DateTime(2017, 9, 7, 17, 58),
                            0.0,
                          ),
                        ],
                        //pointColorMapper: (SalesData sales, _) =>
                        //   sales.segmentColor,
                        xValueMapper: (SalesData sales, _) => sales.year,
                        yValueMapper: (SalesData sales, _) => sales.state,
                        // dataLabelSettings: DataLabelSettings(isVisible: true),
                        name: '24 Stunden')
                  ]),
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
            )
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.state);
  final DateTime year;
  final double state;
  // final Color segmentColor;
}
