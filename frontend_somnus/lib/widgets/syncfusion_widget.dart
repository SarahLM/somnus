import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/datapoint.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Syncfusion extends StatelessWidget {
  final String title;
  final List<DataPoint> sleepData;
  final Color colorAsleep = Color(0xFF0353ed);
  final Color colorAwake = Color(0xFFf01d7e);
  final DateFormat formatter = DateFormat('kk:mm');

  Syncfusion({
    @required this.title,
    @required this.sleepData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            Container(
              height: 350,
              child: Card(
                elevation: 8,
                //Initialize chart
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      this.title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEDF2F7)),
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
                        primaryXAxis: DateTimeAxis(
                          isVisible: true,
                          majorGridLines: MajorGridLines(width: 0),
                          dateFormat: formatter,
                          interval: 1,
                          labelRotation: 90,
                          plotBands: <PlotBand>[
                            /*   Plot band: different height for sleep and awake */

                            PlotBand(
                              isVisible: true,
                              associatedAxisStart: 0.5,
                              associatedAxisEnd: 0,
                              shouldRenderAboveSeries: false,
                              color: colorAsleep,
                              opacity: 1.0,
                            ),

                            /* Plot band same height for sleep and awake */
                          ],
                        ),
                        primaryYAxis: NumericAxis(
                          interval: 1,
                          maximum: 0.7,
                          isVisible: false,
                        ),
                        series: <ChartSeries>[
                          // Initialize line series
                          StepAreaSeries<DataPoint, DateTime>(
                              color: colorAwake,
                              //Color of awake periods
                              opacity: 1.0,
                              dataSource: sleepData,
                              xValueMapper: (DataPoint sales, _) => sales.date,
                              yValueMapper: (DataPoint sales, _) => sales.state,
                              name: '24 Stunden')
                        ]),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
