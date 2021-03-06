import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_somnus/screens/tabs_screen.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialScreen extends StatelessWidget {
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
  int tutorialScreen;
  final introKey = GlobalKey<IntroductionScreenState>();

  Map<String, IconData> iconMapping = {
    'home': Icons.home_outlined,
    'analyse': Icons.insights_outlined,
    'edit': Icons.edit_outlined,
    'activity': Icons.help_center_outlined
  };

  Future<void> _onIntroEnd(context) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tutorialScreen = prefs.getInt("tutorialScreen");
    await prefs.setInt("tutorialScreen", 1);

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

  Widget _buildIcon(String iconName, Color color) {
    return Align(
      child: Material(
        color: color,
        shape: CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Icon(iconMapping[iconName], color: Colors.white, size: 130.0),
        ),
      ),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(
      fontSize: 19.0,
      color: Colors.black,
    );
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.black),
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
              "Verschaff dir einen ??berblick, wie die App dir helfen kann, dein Schlafmuster besser zu verstehen.",
          image: _buildImage('somnus_logo_neu'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Home",
          body:
              "Hier erh??ltst du einen kurzen ??berblick ??ber aktuelle Aufzeichnungen und kannst dich mit deinem Xiaomi-Band verbinden",
          image: _buildIcon('home', Theme.of(context).primaryColor),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Analyse",
          body:
              "W??hle Aufnahmen aus, sieh dir das Hypnogramm und eine Kurzauswertung an.",
          image: _buildIcon(
            'analyse',
            Color(0xFF2752E4),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Bearbeiten",
          body: "Bearbeite deine Hypnogramme.",
          image: _buildIcon(
            'edit',
            Theme.of(context).accentColor,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Aktivit??ten",
          body:
              "Schau dir an, wie verschiedene Aktivit??ten deinen Schlaf beeinflussen.",
          image: _buildIcon(
            'activity',
            Theme.of(context).primaryColor,
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('??berspringen'),
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
        activeColor: Color(0xFFf01d7e),
      ),
    );
  }
}
