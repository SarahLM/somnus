import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/tutorial_screen.dart';
import 'screens/tabs_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  bool _tutorialShown = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somnus',
      home: _tutorialShown ? TabsScreen() : TutorialPage(),
    );
  }
}
