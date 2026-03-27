import 'package:flutter_test/flutter_test.dart';
import 'package:countdowns/main.dart';

void main() {
  testWidgets('CountdownsApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CountdownsApp());
    // App should render without errors
    expect(find.byType(CountdownsApp), findsOneWidget);
  });
}
