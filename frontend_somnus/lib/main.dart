import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:frontend_somnus/providers/states.dart';
import 'package:frontend_somnus/screens/disclaimer_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'screens/tabs_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:foreground_service/foreground_service.dart';
import 'widgets/singletons/ble_device_controller.dart';

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

  maybeStartFGS();
}

//use an async method so we can await
void maybeStartFGS() async {
  ///if the app was killed+relaunched, this function will be executed again
  ///but if the foreground service stayed alive,
  ///this does not need to be re-done
  if (!(await ForegroundService.foregroundServiceIsStarted())) {
    await ForegroundService.setServiceIntervalSeconds(1);

    //necessity of editMode is dubious (see function comments)
    await ForegroundService.notification.startEditMode();

    await ForegroundService.notification
        .setTitle("Somnus");
    await ForegroundService.notification
        .setText(DEVICE_NOT_CONNECTED);

    await ForegroundService.notification.finishEditMode();

    await ForegroundService.startForegroundService(foregroundServiceFunction);
    await ForegroundService.getWakeLock();
  }

  ///this exists solely in the main app/isolate,
  ///so needs to be redone after every app kill+relaunch
  await ForegroundService.setupIsolateCommunication((data) {
    print("Received data: " + data);
  });
}

void foregroundServiceFunction() async {
  if (!ForegroundService.isIsolateCommunicationSetup) {
    ForegroundService.setupIsolateCommunication((data) {
      print("Received data: " + data);
    });
  }

  // TODO: check how to communicate in background!

  //ForegroundService.sendToPort("message from bg isolate");
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  @override
  void initState() {
    super.initState();

    _activateForegroundService();
  }

  void _activateForegroundService() async {
    if (!(await ForegroundService.foregroundServiceIsStarted())) {
      maybeStartFGS();
    }
  }

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
        theme: ThemeData(
            //primaryColor: Color(0xFF0F24D9),
            //accentColor: Color(0xFF680FD9),
            primaryColor: Color(0xFF00008B),
            accentColor: Color(0xFF570899)
            //  cardColor: Color(0xFF680FD9),
            ),
      ),
    );
  }
}
