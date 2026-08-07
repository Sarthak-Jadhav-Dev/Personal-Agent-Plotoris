// Basic smoke test for Plotoris App.

import 'package:flutter_test/flutter_test.dart';

import 'package:plotoris_app/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PlotorisApp());

    // Verify that the splash screen shows the app name.
    expect(find.text('Plotoris'), findsOneWidget);
    expect(find.text('AI-Powered Planning'), findsOneWidget);
  });
}
