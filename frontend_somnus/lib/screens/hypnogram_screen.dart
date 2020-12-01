import 'dart:math';

import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class HypnogramScreen extends StatefulWidget {
  final Color color;
  final buttonTextStyle = TextStyle(color: Colors.purple);

  HypnogramScreen(this.color);

  @override
  _HypnogramScreenState createState() => _HypnogramScreenState();
}

class _HypnogramScreenState extends State<HypnogramScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          color: widget.color,
          child: //Text('Hypnogramm'),
              ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                child: Text(
                  'Letzte Aufnahme',
                  style: TextStyle(color: Colors.purple),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.purple),
                ),
                color: Colors.white,
                onPressed: () {/** */},
              ),
              FlatButton(
                child: Text(
                  '24 Stunden',
                  style: TextStyle(color: Colors.purple),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.purple),
                ),
                color: Colors.white,
                onPressed: () {/** */},
              ),
              FlatButton(
                child: Text(
                  '7 Tage',
                  style: TextStyle(color: Colors.purple),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.purple),
                ),
                color: Colors.white,
                onPressed: () {/** */},
              ),
              FlatButton(
                child: new Text(
                  "Custom",
                  style: TextStyle(color: Colors.purple),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.purple),
                ),
                color: Colors.white,
                onPressed: () async {
                  final List<DateTime> picked =
                      await DateRagePicker.showDatePicker(
                          locale: const Locale("de", "DE"),
                          context: context,
                          initialFirstDate: new DateTime.now(),
                          initialLastDate:
                              (new DateTime.now()).add(new Duration(days: 7)),
                          firstDate: new DateTime(2020),
                          lastDate: new DateTime(2022));
                  if (picked != null && picked.length == 2) {
                    print(picked);
                  }
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
