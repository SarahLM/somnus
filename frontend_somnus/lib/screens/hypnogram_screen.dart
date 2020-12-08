import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:frontend_somnus/widgets/animated_line.dart';
import 'package:frontend_somnus/widgets/line_area_page.dart';
import 'package:frontend_somnus/widgets/syncfusion.dart';
import 'package:frontend_somnus/widgets/theme.dart';

class HypnogramScreen extends StatefulWidget {
  final Color color;
  final buttonTextStyle = TextStyle(color: Colors.purple);

  HypnogramScreen(this.color);

  @override
  _HypnogramScreenState createState() => _HypnogramScreenState();
}

class _HypnogramScreenState extends State<HypnogramScreen> {
  bool _pressedButton1 = true;
  bool _pressedButton2 = false;
  bool _pressedButton3 = false;
  bool _pressedButton4 = false;
  var selectedText = '';

  Widget buildFlatButton(String title, bool button) {
    return FlatButton(
      child: Text(
        title,
        style: TextStyle(
          color: button ? Colors.white : Colors.purple,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.purple),
      ),
      color: button ? Colors.purple : Colors.white,
      onPressed: () {
        setState(() {
          button = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          color: widget.color,
          child: ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                child: Text(
                  'Letzte Aufnahme',
                  style: TextStyle(
                    color: _pressedButton1 ? Colors.white : Colors.purple,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.purple),
                ),
                color: _pressedButton1 ? Colors.purple : Colors.white,
                onPressed: () {
                  setState(() {
                    _pressedButton1 = true;
                    _pressedButton2 = false;
                    _pressedButton3 = false;
                    _pressedButton4 = false;
                    selectedText = 'Letzte Aufnahme';
                  });
                },
              ),
              FlatButton(
                child: Text(
                  '24 Stunden',
                  style: TextStyle(
                    color: _pressedButton2 ? Colors.white : Colors.purple,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.purple),
                ),
                color: _pressedButton2 ? Colors.purple : Colors.white,
                onPressed: () {
                  setState(() {
                    _pressedButton2 = true;
                    _pressedButton1 = false;
                    _pressedButton3 = false;
                    _pressedButton4 = false;
                    selectedText = '24 Stunden';
                  });
                },
              ),
              FlatButton(
                child: Text(
                  '7 Tage',
                  style: TextStyle(
                    color: _pressedButton3 ? Colors.white : Colors.purple,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.purple),
                ),
                color: _pressedButton3 ? Colors.purple : Colors.white,
                onPressed: () {
                  setState(() {
                    _pressedButton3 = true;
                    _pressedButton1 = false;
                    _pressedButton2 = false;
                    _pressedButton4 = false;
                    selectedText = '7 Tage';
                  });
                },
              ),
              DatePickerTheme(
                Builder(
                  builder: (context) => FlatButton(
                    child: new Text(
                      "Custom",
                      style: TextStyle(
                        color: _pressedButton4 ? Colors.white : Colors.purple,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.purple),
                    ),
                    color: _pressedButton4 ? Colors.purple : Colors.white,
                    onPressed: () async {
                      setState(() {
                        _pressedButton4 = true;
                        _pressedButton1 = false;
                        _pressedButton2 = false;
                        _pressedButton3 = false;
                      });
                      final List<DateTime> picked =
                          await DateRagePicker.showDatePicker(
                        locale: const Locale("de", "DE"),
                        context: context,
                        initialFirstDate: new DateTime.now(),
                        initialLastDate:
                            (new DateTime.now()).add(new Duration(days: 7)),
                        firstDate: new DateTime(2020),
                        lastDate: new DateTime(2022),
                      );

                      if (picked != null && picked.length == 2) {
                        print(picked);
                      }
                      setState(() {
                        selectedText = picked.toString();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        //LineAreaPage(),
        //LineAreaPage(),
        Sync(),
        //LineAreaPage()
      ],
    );
  }
}
