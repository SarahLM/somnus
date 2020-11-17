import 'package:flutter/material.dart';
import 'package:frontend_somnus/home_widget.dart';
import 'home_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Somnus', home: Home());
  }
}
