import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_somnus/screens/edit_screen.dart';

void main() {
  // TODO: find solution for provider error

  testWidgets("FlatButton Heute wird angezeigt", (WidgetTester tester) async {
    final testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home:EditScreen())
    );
    // create widget to test
    await tester.pumpWidget(testWidget);

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("FlatButton7Tage"));

    // verify widget
    expect(widgetFinder, findsOneWidget);
  });

  testWidgets("FlatButton Heute Text 'Heute' angezeigt", (WidgetTester tester) async {
    final testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home:EditScreen())
    );
    // create widget to test
    await tester.pumpWidget(testWidget);

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("FlatButton7Tage"));
    Text text = widgetFinder.evaluate().first.widget as Text;

    // verify widget
    expect(text, "7 Tage");
  });

  testWidgets("FlatButton Gestern wird angezeigt", (WidgetTester tester) async {
    final testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home:EditScreen())
    );
    // create widget to test
    await tester.pumpWidget(testWidget);

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("FlatButton30Tage"));

    // verify widget
    expect(widgetFinder, findsOneWidget);
  });

  testWidgets("FlatButton Gestern Text 'Gestern' angezeigt", (WidgetTester tester) async {
    final testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home:EditScreen())
    );
    // create widget to test
    await tester.pumpWidget(testWidget);

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("FlatButton30Tage"));
    Text text = widgetFinder.evaluate().first.widget as Text;

    // verify widget
    expect(text, "30 Tage");
  });
}