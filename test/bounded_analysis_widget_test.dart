import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('limits large spelling result sets and disables replace all', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final largeUnknownText = List<String>.filled(201, 'Zorbax').join(' ');
    await tester.enterText(find.byType(TextField), largeUnknownText);
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('200+'), findsOneWidget);
    expect(
      find.textContaining('Showing the first 200 spelling issues'),
      findsOneWidget,
    );
    expect(find.text('200 captured occurrences'), findsWidgets);
    expect(find.text('Replace all…'), findsNothing);
  });

  testWidgets('small complete result sets retain replace all', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Zorbax Zorbax');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('2 occurrences'), findsWidgets);
    expect(find.text('Replace all…'), findsWidgets);
    expect(
      find.textContaining('Showing the first 200 spelling issues'),
      findsNothing,
    );
  });
}
