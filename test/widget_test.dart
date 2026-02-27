import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pr11_3/main.dart';

void main() {
  testWidgets('App starts test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
