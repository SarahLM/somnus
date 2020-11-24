import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_somnus/screens/tabs_screen.dart';
import 'package:introduction_screen/introduction_screen.dart';

class TuturialScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Tutorial Screen',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TutorialPage(),
    );
  }
}

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TabsScreen()),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/images/$assetName.png', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Willkommen bei Somnus!",
          body:
              "Verschaff dir einen Überblick, wie die App dir helfen kann, dein Schlafmuster besser zu verstehen.",
          image: _buildImage('somnus_logo'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Home",
          body: "Hier verbindest du dich mit dem XIOMI Device.",
          image: _buildImage('tutorial_connect'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Hypnogramm",
          body:
              "Wähle Aufnahmen aus, sieh dir das Hypnogramm und eine Kurzauswertung an.",
          image: _buildImage('tutorial_hypnogram'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Analyse",
          body:
              "Schau dir eine detaillierte Analyse ausgewählter Aufnahmen an.",
          image: _buildImage('tutorial_analysis'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Überspringen'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Verstanden!',
          style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
