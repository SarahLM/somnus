import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_somnus/tutorial_screen.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            height: 120,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: Text(
              'Navigate to ..',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(
              Icons.plagiarism_rounded,
              size: 26,
            ),
            title: Text(
              'Disclaimer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              //...,
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
        ],
      ),
    );
  }
}
