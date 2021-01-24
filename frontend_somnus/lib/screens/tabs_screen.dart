import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/analyse_activity.dart';
import 'package:frontend_somnus/screens/home_screen.dart';
import '../widgets/main_drawer.dart';
import 'edit_screen.dart';
import 'hypnogram_screen.dart';
import 'questionnaire_screen.dart';

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
      'title': 'Analyse',
    },
    {
      'page': EditScreen(Colors.red),
      'title': 'Bearbeiten',
    },
    {
      'page': ActivityScreen(),
      'title': 'Aktivitäten',
    },
    //{
    // 'page': DbScreen(Colors.blue),
    // 'title': 'DbScreen',
    //},
    //{
    //  'page': QuestionScreen(),
    //  'title': 'Fragebögen',
    //},
  ];
  @override
  void initState() {
    super.initState();
    _selectedPageIndex = 0;
    _pages1 = [
      HomeScreen(),
      HypnogramScreen(Color(0xFF1E1164)),
      EditScreen(Colors.white),
      //DbScreen(Colors.white),
      ActivityScreen(),
      //QuestionScreen()
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
        backgroundColor: Color(0xff1E1164),
        onTap: (selectedPageIndex) {
          setState(() {
            _selectedPageIndex = selectedPageIndex;
            _pageController.jumpToPage(selectedPageIndex);
          });
        },
        unselectedItemColor: Color(0xff9A97BC),
        selectedItemColor: Color(0xffEDF2F7),
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            label: 'Analyse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_outlined),
            label: 'Bearbeiten',
          ),
          /* BottomNavigationBarItem(
            icon: Icon(Icons.data_usage),
            label: 'Database',
          ) */
          /*BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_outlined),
            label: 'Fragebögen',
          )*/
          BottomNavigationBarItem(
            icon: Icon(Icons.help_center_outlined),
            label: 'Aktivitäten',
          ),
        ],
      ),
    );
  }
}
