import 'package:flutter/material.dart';

class AddActivities extends StatelessWidget {
  const AddActivities({
    Key key,
    @required String title,
    @required List<String> texts,
    @required List<Icon> icons,
    @required List<bool> isChecked,
    @required Function pressOK,
  })  : _title = title,
        _texts = texts,
        _icons = icons,
        _isChecked = isChecked,
        _pressOK = pressOK,
        super(key: key);
  final String _title;
  final List<String> _texts;
  final List<Icon> _icons;
  final List<bool> _isChecked;

  final Function _pressOK;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(_title),
        content: Container(
          height: 300,
          width: 300,
          child: Scrollbar(
            child: ListView.builder(
              itemCount: _texts.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_texts[index]),
                  secondary: _icons[index],
                  value: _isChecked[index],
                  onChanged: (val) {
                    setState(
                      () {
                        _isChecked[index] = val;
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Ok',
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
            onPressed: _pressOK,
            // final snackBar = SnackBar(
            //   content: Text(_snackBarText),
            // );
            // _scaffoldKey.currentState.showSnackBar(snackBar);
            //Navigator.pop(context);
          ),
        ],
      );
    });
  }
}
