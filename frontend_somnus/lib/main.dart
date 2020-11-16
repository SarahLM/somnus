import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:starflut/starflut.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      StarCoreFactory starcore = await Starflut.getFactory();
      StarServiceClass Service = await starcore.initSimple("test", "123", 0, 0, []);
      await starcore
          .regMsgCallBackP((int serviceGroupID, int uMsg, Object wParam, Object lParam) async {
        print("$serviceGroupID  $uMsg   $wParam   $lParam");

        return null;
      });
      StarSrvGroupClass SrvGroup = await Service["_ServiceGroup"];

      /*---script python--*/
      bool isAndroid = await Starflut.isAndroid();
      if (isAndroid == true) {
        await Starflut.copyFileFromAssets(
            "testcallback.py", "flutter_assets/starfiles", "flutter_assets/starfiles");
        await Starflut.copyFileFromAssets(
            "testpy.py", "flutter_assets/starfiles", "flutter_assets/starfiles");
        await Starflut.copyFileFromAssets(
            "python3.6.zip", "flutter_assets/starfiles", null); //desRelatePath must be null
        await Starflut.copyFileFromAssets("zlib.cpython-36m.so", null, null);
        await Starflut.copyFileFromAssets("unicodedata.cpython-36m.so", null, null);
        await Starflut.loadLibrary("libpython3.6m.so");
      }

      String docPath = await Starflut.getDocumentPath();
      print("docPath = $docPath");
      String resPath = await Starflut.getResourcePath();
      print("resPath = $resPath");
      dynamic rr1 = await SrvGroup.initRaw("python36", Service);

      print("initRaw = $rr1");
      var Result = await SrvGroup.loadRawModule(
          "python", "", resPath + "/flutter_assets/starfiles/" + "testpy.py", false);
      print("loadRawModule = $Result");
      dynamic python = await Service.importRawContext("python", "", false, "");
      print("python = " + await python.getString());
      StarObjectClass retobj = await python.call("tt", ["hello ", "world"]);
      print(await retobj[0]);
      print(await retobj[1]);
      print(await python["g1"]);
      StarObjectClass yy = await python.call("yy", ["hello ", "world", 123]);
      print(await yy.call("__len__", []));
      StarObjectClass multiply = await Service.importRawContext("python", "Multiply", true, "");
      StarObjectClass multiply_inst = await multiply.newObject(["", "", 33, 44]);
      print(await multiply_inst.getString());
      print(await multiply_inst.call("multiply", [11, 22]));
      await SrvGroup.clearService();
      await starcore.moduleExit();
      platformVersion = 'Python 3.6';
    } on PlatformException catch (e) {
      print("{$e.message}");
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}