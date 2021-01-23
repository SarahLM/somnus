import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_somnus/screens/connect_device_screen.dart';

void main() {
  testWidgets("RhichText with connection tips is displayed", (WidgetTester tester) async {
    final testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home:ConnectDeviceScreen())
    );
    // create widget to test
    await tester.pumpWidget(testWidget);

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("ConnectionTipRichText"));

    // verify widget
    expect(widgetFinder, findsOneWidget);
  });

  testWidgets("First connection tip is correct", (WidgetTester tester) async {
    final testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home:ConnectDeviceScreen())
    );
    // create widget to test
    await tester.pumpWidget(testWidget);

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("ConnectionTipRichText"));
    RichText richText = widgetFinder.evaluate().first.widget as RichText;
    final text = richText.text.toPlainText();

    // verify widget
    expect(text, "Select your device from the list.");
  });

  testWidgets("Refresh button is displayed", (WidgetTester tester) async {
    final testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home:ConnectDeviceScreen())
    );
    // create widget to test
    await tester.pumpWidget(testWidget);

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("RefreshButton"));

    // verify widget
    expect(widgetFinder, findsOneWidget);
  });

  testWidgets("ListView is displayed", (WidgetTester tester) async {
    final testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home:ConnectDeviceScreen())
    );
    // create widget to test
    await tester.pumpWidget(testWidget);

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("DevicesListView"));

    // verify widget
    expect(widgetFinder, findsOneWidget);
  });
}
