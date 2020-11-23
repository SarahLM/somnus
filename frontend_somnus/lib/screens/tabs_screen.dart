import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/home_screen.dart';
import '../widgets/main_drawer.dart';
import 'analysis_screen.dart';
import 'hypnogram_screen.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  final List<Map<String, Object>> _pages = [
    {
      'page': HomeScreen(),
      'title': 'Home',
    },
    {
      'page': HypnogramScreen(Colors.green),
      'title': 'Hypnogramm',
    },
    {
      'page': AnalysisScreen(Colors.red),
      'title': 'Analyse',
    },
  ];

  int _selectedPageIndex = 0;
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedPageIndex]['title']),
        backgroundColor: Colors.purple,
      ),
      drawer: MainDrawer(),
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple,
        onTap: _selectPage,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.lightBlue,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Hypnogramm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analyse',
          )
        ],
      ),
    );
  }
}
