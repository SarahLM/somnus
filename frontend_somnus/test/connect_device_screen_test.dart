import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_somnus/widgets/ble_connect_widget.dart';

void main() {
  testWidgets("RhichText with connection tips is displayed", (WidgetTester tester) async {
    // create widget to test
    await tester.pumpWidget(BleConnect());

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("ConnectionTipRichText"));

    // verify widget
    expect(widgetFinder, findsOneWidget);
  });

  testWidgets("First connection tip is correct", (WidgetTester tester) async {
    // create widget to test
    await tester.pumpWidget(BleConnect());

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("ConnectionTipRichText"));
    RichText richText = widgetFinder.evaluate().first.widget as RichText;
    final text = richText.text.toPlainText();

    // verify widget
    expect(text, "Select your device from the list.");
  });

  testWidgets("Refresh button is displayed", (WidgetTester tester) async {
    // create widget to test
    await tester.pumpWidget(BleConnect());

    // create finder to find the widget to test
    final widgetFinder = find.byKey(Key("RefreshButton"));

    // verify widget
    expect(widgetFinder, findsOneWidget);
  });

}
