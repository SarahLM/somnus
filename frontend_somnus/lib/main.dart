import 'package:flutter/material.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/screens/disclaimer_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'screens/tabs_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

int disclaimerScreen;
int tutorialScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  disclaimerScreen = prefs.getInt("disclaimerScreen");
  await prefs.setInt("disclaimerScreen", 1);
  //tutorialScreen = prefs.getInt("tutorialScreen");
  //await prefs.setInt("tutorialScreen", 1);
  Intl.defaultLocale = "de_DE";
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => DataStates(),
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('de', ''), // German, no country code
        ],
        title: 'Somnus',
        initialRoute: disclaimerScreen == 0 || disclaimerScreen == null
            ? "disclaimerScreen"
            : "/",
        routes: {
          '/': (context) => TabsScreen(),
          'disclaimerScreen': (context) => DisclaimerScreen()
        },
      ),
    );
  }
}
