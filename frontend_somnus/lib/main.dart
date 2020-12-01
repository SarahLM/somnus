import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/disclaimer_screen.dart';
import 'screens/tabs_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

int disclaimerScreen;
int tutorialScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  disclaimerScreen = prefs.getInt("disclaimerScreen");
  await prefs.setInt("disclaimerScreen", 1);
  //tutorialScreen = prefs.getInt("tutorialScreen");
  //await prefs.setInt("tutorialScreen", 1);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somnus',
      initialRoute: disclaimerScreen == 0 || disclaimerScreen == null
          ? "disclaimerScreen"
          : "/",
      routes: {
        '/': (context) => TabsScreen(),
        'disclaimerScreen': (context) => DisclaimerScreen()
      },
    );
  }
}
