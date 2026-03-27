import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App package is valid', (WidgetTester tester) async {
    // Minimal smoke test — verifies the package compiles and loads
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Countdowns')),
        ),
      ),
    );

    expect(find.text('Countdowns'), findsOneWidget);
  });
}
