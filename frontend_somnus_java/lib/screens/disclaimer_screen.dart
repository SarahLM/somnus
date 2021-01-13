import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/tutorial_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tabs_screen.dart';

int tutorialScreen;

class DisclaimerScreen extends StatefulWidget {
  @override
  _DisclaimerScreenState createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  @override
  void initState() {
    _getTutorialScreenStatus().then((value) {
      print('Async done');
    });
    super.initState();
  }

  Future<void> _getTutorialScreenStatus() async {
    print('I am in _getTutorialScreen Status');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tutorialScreen = await prefs.getInt('tutorialScreen');
    print('int tutorialScreen is ');
    print(tutorialScreen);
    return tutorialScreen;
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0, color: Colors.black);
    final disclaimer =
        'Die in der SOMNUS App dargestellten Inhalte dienen ausschließlich der neutralen Information und allgemeinen Weiterbildung. Sie stellen keine Empfehlung oder Bewerbung der beschriebenen oder erwähnten diagnostischen Methoden, Behandlungen oder Arzneimittel dar. \n\n'
        'Der Service von SOMNUS erhebt weder einen Anspruch auf Vollständigkeit noch kann die Aktualität, Richtigkeit und Ausgewogenheit der dargebotenen Information garantiert werden. \n\n'
        'Der Service von SOMNUS ersetzt keinesfalls die fachliche Beratung durch einen Arzt oder Apotheker und er darf nicht als Grundlage zur eigenständigen Diagnose und Beginn, Änderung oder Beendigung einer Behandlung von Krankheiten verwendet werden. Konsultieren Sie bei gesundheitlichen Fragen oder Beschwerden immer den Arzt Ihres Vertrauens! \n\n'
        'Die Entwickler von SOMNUS übernehemen keine Haftung für Unannehmlichkeiten oder Schäden, die sich aus der Anwendung der in der SOMNUS App dargestellten Information ergeben.\n\n';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'DISCLAIMER',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    disclaimer,
                    style: bodyStyle,
                  ),
                  const SizedBox(height: 10),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => tutorialScreen == 1
                              ? TabsScreen()
                              : TutorialPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Verstanden',
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
