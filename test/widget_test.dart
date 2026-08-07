import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/app.dart';

void main() {
  testWidgets('checks text and displays a spelling issue', (WidgetTester tester) async {
    await tester.pumpWidget(const SpellCheckerApp());

    expect(find.text('Ready to check'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'Helo world');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('Helo'), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
  });
}
