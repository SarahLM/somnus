import 'package:flutter/material.dart';

import './widgets/main_drawer.dart';

import 'hypnogram_screen.dart';
import 'analysis_screen.dart';
import 'ble_widget.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    BleDevices(),
    HypnogramWidget(Colors.green),
    AnalysisWidget(Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somnus',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Somnus'),
          //title: Image.asset('assets/title.png', fit: BoxFit.cover),
          actions: <Widget>[
            // IconButton(
            //   icon: Icon(
            //     Icons.more_vert,
            //     color: Colors.white,
            //   ),
            //   onPressed: () {
            //     // do something
            //   },
            // )
          ],
          backgroundColor: Colors.purple,
        ),
        drawer: MainDrawer(),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped, // new
          currentIndex: _currentIndex,
          backgroundColor: Colors.purple,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.lightBlue,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.favorite),
              label: 'Hypnogramm',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.analytics), label: 'Analyse')
          ],
        ),
        body: //Center(
            //child: BleDevices(),
            _children[_currentIndex],

        //),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
