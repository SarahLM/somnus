import 'package:flutter/material.dart';
import 'package:frontend_somnus/screens/connect_device_screen.dart';
import 'package:frontend_somnus/screens/database_helper.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<bool> _isChecked;
  @override
  void initState() {
    super.initState();
    _isChecked = List<bool>.filled(_texts.length, false);
  }

  final dbHelper = DatabaseHelper.instance;
  bool _isLoading = false;
  List<String> _texts = [
    "Laufen",
    "Schwimmen",
    "Alkohol",
    "Rauchen",
    "Spätes Essen",
    "Multimedia"
  ];

  List<Icon> _icons = [
    Icon(Icons.ac_unit),
    Icon(Icons.ac_unit),
    Icon(Icons.ac_unit),
    Icon(Icons.ac_unit),
    Icon(Icons.ac_unit),
    Icon(Icons.ac_unit),
  ];

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
            backgroundColor: Colors.transparent,
            body: StaggeredGridView.count(
              physics: NeverScrollableScrollPhysics(), //disable scrolling
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              children: <Widget>[
                _buildTile(
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
                          Text('23.01.2021',
                              style: TextStyle(
                                  color: Color(0xFFEDF2F7),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.0))
                        ],
                      ),
                    ),
                    color: Colors.transparent),
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
                                    fontSize: 24.0)),
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
                                    fontSize: 24.0)),
                          ]),
                    ),
                    color: Color.fromRGBO(0, 0, 0, 0.4)),
                // _buildTile(
                //   Padding(
                //       padding: const EdgeInsets.all(24.0),
                //       child: Column(
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: <Widget>[
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: <Widget>[
                //               Column(
                //                 mainAxisAlignment: MainAxisAlignment.start,
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: <Widget>[
                //                   Text('Revenue',
                //                       style: TextStyle(color: Colors.green)),
                //                   Text('\$16K',
                //                       style: TextStyle(
                //                           color: Colors.black,
                //                           fontWeight: FontWeight.w700,
                //                           fontSize: 34.0)),
                //                 ],
                //               ),
                //             ],
                //           ),
                //           Padding(padding: EdgeInsets.only(bottom: 4.0)),
                //         ],
                //       )),
                // ),
                // _buildTile(
                //   Padding(
                //     padding: const EdgeInsets.all(24.0),
                //     child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         children: <Widget>[
                //           Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: <Widget>[
                //               Text('Shop Items',
                //                   style: TextStyle(color: Colors.redAccent)),
                //               Text('173',
                //                   style: TextStyle(
                //                       color: Colors.black,
                //                       fontWeight: FontWeight.w700,
                //                       fontSize: 34.0))
                //             ],
                //           ),
                //           Material(
                //             color: Colors.red,
                //             borderRadius: BorderRadius.circular(24.0),
                //             child: Center(
                //               child: Padding(
                //                 padding: EdgeInsets.all(16.0),
                //                 child: Icon(Icons.store,
                //                     color: Colors.white, size: 30.0),
                //               ),
                //             ),
                //           )
                //         ]),
                //   ),
                //   // onTap: () => Navigator.of(context)
                //   //     .push(MaterialPageRoute(builder: (_) => null)),
                //   color: Color(0xFF20d2f4),
                // ),
                //   _buildTile(
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ConnectDeviceScreen(),
                                ),
                              );
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
                //StaggeredTile.extent(2, 220.0),
                StaggeredTile.extent(2, 110.0),
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
        //borderRadius: BorderRadius.circular(5.0), //original: 12
        shadowColor: Color(0x802196F3),
        child: InkWell(
            // Do onTap() if it isn't null, otherwise do print()
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
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Aktivitäten'),
              content: Container(
                height: 300,
                width: 300,
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: _texts.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title: Text(_texts[index]),
                        secondary: _icons[index],
                        value: _isChecked[index],
                        onChanged: (val) {
                          setState(
                            () {
                              _isChecked[index] = val;
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        });
  }
}
