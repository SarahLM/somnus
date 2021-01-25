import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/connect_device_screen.dart';
import 'package:frontend_somnus/screens/database_helper.dart';
import 'package:frontend_somnus/widgets/add_activities_widget.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<bool> _isChecked;
  List<bool> _isCheckedMeds;
  @override
  void initState() {
    super.initState();
    _isChecked = List<bool>.filled(_texts.length, false);
    _isCheckedMeds = List<bool>.filled(_texts.length, false);
  }

  final dbHelper = DatabaseHelper.instance;
  bool _isLoading = false;
  List<String> _texts = [
    "Alkohol getrunken",
    "Kaffee",
    "keine Elektronik",
    "seelische Konflikte",
    "Sport getrieben",
    "Entspannungsübungen",
    "Yoga",
    "andere Umgebung",
    "zu kalt",
    "zu warm",
  ];

  List<String> _meds = [
    "Baldrian",
    "CBD",
    "Johanniskraut",
    "Melatonin",
    "Modafinil",
    "Wakix",
    "Xyrem",
    "Zopiclon",
    "Zolpidem"
  ];

  List<Icon> _icons = [
    Icon(Icons.local_bar_outlined),
    Icon(Icons.free_breakfast_outlined),
    Icon(Icons.no_cell_outlined),
    Icon(Icons.psychology),
    Icon(Icons.directions_run_outlined),
    Icon(Icons.self_improvement_outlined),
    Icon(Icons.self_improvement_outlined),
    Icon(Icons.find_replace_outlined),
    Icon(Icons.ac_unit),
    Icon(Icons.fireplace_outlined),
  ];

  List<Icon> _iconsMeds = [
    Icon(Icons.spa_outlined),
    Icon(Icons.spa_outlined),
    Icon(Icons.spa_outlined),
    Icon(Icons.spa_outlined),
    Icon(Icons.science_outlined),
    Icon(Icons.science_outlined),
    Icon(Icons.science_outlined),
    Icon(Icons.science_outlined),
    Icon(Icons.science_outlined),
  ];

  _pressOK() {
    Navigator.of(context).pop();
    final snackBar = SnackBar(
        content: Text('Aktivitäten hinzugefügt'),
        duration: const Duration(seconds: 1));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _pressOKMeds() {
    Navigator.of(context).pop();
    final snackBar = SnackBar(
        content: Text('Medikamente hinzugefügt'),
        duration: const Duration(seconds: 1));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Somnus',
      debugShowCheckedModeBanner: false,
      home: LoadingOverlay(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background_home.png"),
                  fit: BoxFit.cover)),
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            body: StaggeredGridView.count(
              physics: NeverScrollableScrollPhysics(), //disable scrolling
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Willkommen!',
                        style: TextStyle(
                            color: Color(0xFFEDF2F7),
                            fontWeight: FontWeight.w700,
                            fontSize: 30.0),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Letzte Aufzeichnung',
                          style: Theme.of(context).textTheme.bodyText2),
                      Text(
                        '26.01.2021',
                        style: TextStyle(
                            color: Color(0xFFEDF2F7),
                            fontWeight: FontWeight.w700,
                            fontSize: 20.0),
                      )
                    ],
                  ),
                ),
                _buildTile(
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Material(
                              color: Color(0xFF1E1164),
                              shape: CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(Icons.directions_run,
                                    color: Colors.white, size: 30.0),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(bottom: 16.0)),
                            Text('Aktivität hinzufügen',
                                style: TextStyle(
                                    color: Color(0xFFEDF2F7),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22.0)),
                          ]),
                    ),
                    onTap: () => _showDialogActivity(context),
                    color: Color.fromRGBO(0, 0, 0, 0.4)),
                _buildTile(
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Material(
                            color: Color(0xFF1E1164),
                            shape: CircleBorder(),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(
                                Icons.science,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 16.0)),
                          Text('Medikament hinzufügen',
                              style: TextStyle(
                                  color: Color(0xFFEDF2F7),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22.0)),
                        ]),
                  ),
                  onTap: () => _showDialogMeds(context),
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                ),
                Container(
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => ConnectDeviceScreen(),
                              //   ),
                              // );
                            },
                            child: Text(
                              'Mit Gerät verbinden',
                              style: TextStyle(color: Color(0xFFEDF2F7)),
                            ),
                          ),
                          FlatButton(
                            onPressed: null,
                            child: Text(
                              'Verbindung trennen',
                              style: TextStyle(color: Color(0xFFEDF2F7)),
                            ),
                          ),
                        ]),
                    // ),
                    // onTap: () => Navigator.of(context)
                    //     .push(MaterialPageRoute(builder: (_) => null)),
                  ),
                ),
              ],
              staggeredTiles: [
                StaggeredTile.extent(2, 160.0),
                StaggeredTile.extent(1, 190.0),
                StaggeredTile.extent(1, 190.0),
                StaggeredTile.extent(2, 110.0), //Buttons
              ],
            ),
          ),
        ),
        isLoading: _isLoading,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildTile(Widget child, {Function() onTap, Color color}) {
    return Material(
        color: color,
        elevation: 14.0,
        shadowColor: Color(0x802196F3),
        child: InkWell(
            onTap: onTap != null
                ? () => onTap()
                : () {
                    print('Not set yet');
                  },
            child: child));
  }

  Future<void> _showDialogActivity(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AddActivities(
            title: 'Aktivitäten',
            texts: _texts,
            icons: _icons,
            isChecked: _isChecked,
            pressOK: _pressOK,
          );
        });
  }

  Future<void> _showDialogMeds(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AddActivities(
            title: 'Medikamente',
            texts: _meds,
            icons: _iconsMeds,
            isChecked: _isCheckedMeds,
            pressOK: _pressOKMeds,
          );
        });
  }
}
