import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/db_analyse_screen.dart';
import 'package:frontend_somnus/screens/home_screen.dart';
import 'package:sqflite/sqlite_api.dart';
import '../widgets/main_drawer.dart';
import 'edit_screen.dart';
import 'hypnogram_screen.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Widget> _pages1;
  PageController _pageController;
  var _selectedPageIndex;
  final List<Map<String, Object>> _pages = [
    {
      'page': HomeScreen(),
      'title': 'Home',
    },
    {
      'page': HypnogramScreen(Colors.white),
      'title': 'Hypnogramm',
    },
    {
      'page': EditScreen(Colors.red),
      'title': 'Bearbeiten',
    },
    {
      'page': DbScreen(Colors.blue),
      'title': 'DbScreen',
    },
  ];
  @override
  void initState() {
    super.initState();
    _selectedPageIndex = 0;
    _pages1 = [
      HomeScreen(),
      HypnogramScreen(Colors.white),
      EditScreen(Colors.white),
      DbScreen(Colors.white),
    ];
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_pages[_selectedPageIndex]['title']),
        // backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.more_vert),
            onPressed: () => _scaffoldKey.currentState.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: MainDrawer(),
      body: //_pages[_selectedPageIndex]['page'],
          PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _pages1,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        onTap: (selectedPageIndex) {
          setState(() {
            _selectedPageIndex = selectedPageIndex;
            _pageController.jumpToPage(selectedPageIndex);
          });
        },
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.yellow,
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
            icon: Icon(Icons.edit),
            label: 'Bearbeiten',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_usage),
            label: 'Database',
          )
        ],
      ),
    );
  }
}
