import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/connect_device_screen.dart';
import 'package:frontend_somnus/screens/disclaimer_screen.dart';
import 'package:frontend_somnus/screens/questionnaire_screen.dart';
import '../screens/tutorial_screen.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E1164), Color(0xFF2752E4)]),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            ListTile(
              leading: Icon(
                Icons.plagiarism_rounded,
                size: 26,
                color: Colors.white,
              ),
              title: Text(
                'Disclaimer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DisclaimerScreen()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.school,
                size: 26,
                color: Colors.white,
              ),
              title: Text(
                'Tutorial',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TutorialPage()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.bluetooth_searching,
                size: 26,
                color: Colors.white,
              ),
              title: Text(
                'Ger??t verbinden',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ConnectDeviceScreen()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.question_answer_outlined,
                size: 26,
                color: Colors.white,
              ),
              title: Text(
                'Frageb??gen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => QuestionScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
