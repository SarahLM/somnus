import 'package:flutter/material.dart';

class DatePickerTheme extends Theme {
  /*
   * Colors:
   *    Primary Blue: #335C81 (51, 92, 129)
   *    Light Blue:   #74B3CE (116, 179, 206)
   *    Yellow:       #FCA311 (252, 163, 17)
   *    Red:          #E15554 (255, 85, 84)
   *    Green:        #3BB273 (59, 178, 115)
   */

  static int _fullAlpha = 255;
  static Color blueDark = new Color.fromARGB(_fullAlpha, 51, 92, 129);
  static Color blueLight = new Color.fromARGB(_fullAlpha, 116, 179, 206);
  static Color yellow = new Color.fromARGB(_fullAlpha, 252, 163, 17);
  static Color red = new Color.fromARGB(_fullAlpha, 255, 85, 84);
  static Color green = new Color.fromARGB(_fullAlpha, 59, 178, 115);

  static Color activeIconColor = yellow;

  DatePickerTheme(Widget child)
      : super(
          child: child,
          data: new ThemeData(
            primaryColor: Colors.deepPurple,
            accentColor: Colors.purple,
            cardColor: Colors.purple,
            backgroundColor: Colors.purple,
            highlightColor: Colors.purple,
            splashColor: Colors.purple,
            colorScheme: ColorScheme.light(
              primary: Colors.purple, //FlatButton Text Color!
            ),
          ),
        );
}

// data: new ThemeData(
//                 primaryColor: blueDark,
//                 accentColor: yellow,
//                 cardColor: blueLight,
//                 backgroundColor: blueDark,
//                 highlightColor: red,
//                 splashColor: green));
