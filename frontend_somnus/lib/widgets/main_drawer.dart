import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/connect_device_screen.dart';
import 'package:frontend_somnus/screens/disclaimer_screen.dart';
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
            // Container(
            //   color: Colors.blue,
            //   height: 120,
            //   width: double.infinity,
            //   padding: EdgeInsets.all(20),
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     'Gehe zu ..',
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //       fontSize: 30,
            //     ),
            // ),
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
              ),
              title: Text(
                'Tutorial',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
              ),
              title: Text(
                'Connect Device',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ConnectDeviceScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
