import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_somnus/screens/home_screen.dart';

void main() {
  testWidgets("Text Aktivität hinzufügen wird angezeigt", (WidgetTester tester) async {
    final testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home:HomeScreen())
    );
    // create widget to test
    await tester.pumpWidget(testWidget);

    // create finder to find the widget to test
    final widgetFinder = find.text("Aktivität hinzufügen");

    // verify widget
    expect(widgetFinder, findsOneWidget);
  });

  testWidgets("Text Medikament hinzufügen wird angezeigt", (WidgetTester tester) async {
    final testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home:HomeScreen())
    );
    // create widget to test
    await tester.pumpWidget(testWidget);

    // create finder to find the widget to test
    final widgetFinder = find.text("Medikament hinzufügen");

    // verify widget
    expect(widgetFinder, findsOneWidget);
  });
}