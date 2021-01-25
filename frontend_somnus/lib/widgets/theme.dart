import 'package:flutter/material.dart';

class DatePickerTheme extends Theme {
  DatePickerTheme(Widget child)
      : super(
          child: child,
          data: new ThemeData(
            primaryColor: Color(0xFF1E1164),
            accentColor: Color(0xFFc753fa),
            cardColor: Colors.purple,
            backgroundColor: Colors.purple,
            highlightColor: Colors.purple,
            splashColor: Color(0xFF570899),
            colorScheme: ColorScheme.light(
              primary: Color(0xFFf01d7e), //FlatButton Text Color!
            ),
          ),
        );
}
