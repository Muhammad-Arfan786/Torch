// Basic widget test for Torch app

import 'package:flutter_test/flutter_test.dart';
import 'package:torch/main.dart';
import 'package:torch/services/settings_service.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Create a settings service for testing
    final settingsService = SettingsService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(settingsService: settingsService));

    // Verify that the app title is displayed
    expect(find.text('TORCH'), findsOneWidget);
  });
}
