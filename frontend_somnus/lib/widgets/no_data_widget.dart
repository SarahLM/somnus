import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Icon(
              Icons.sentiment_dissatisfied,
              color: Color(0xFFEDF2F7),
              size: 60.0,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Column(
              children: [
                Text(
                  'Für den ausgewählten Zeitraum ' +
                      title +
                      ' liegen keine Daten vor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFEDF2F7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
