import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/core/spell_issue.dart';
import 'package:spellchecker/features/editor/spell_check_editing_controller.dart';

void main() {
  testWidgets('buildTextSpan highlights checked and active issues', (
    WidgetTester tester,
  ) async {
    final controller = SpellCheckEditingController(text: 'Helo wrld');
    controller.setIssues(
      const <SpellIssue>[
        SpellIssue(word: 'Helo', start: 0, end: 4),
        SpellIssue(word: 'wrld', start: 5, end: 9),
      ],
      activeIssueIndex: 1,
    );

    late TextSpan span;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            span = controller.buildTextSpan(
              context: context,
              style: const TextStyle(fontSize: 16),
              withComposing: false,
            );
            return const SizedBox();
          },
        ),
      ),
    );

    final children = span.children!.whereType<TextSpan>().toList();
    expect(children.map((TextSpan child) => child.text), <String>['Helo', ' ', 'wrld']);
    expect(children.first.style?.decoration, TextDecoration.underline);
    expect(children.last.style?.decoration, TextDecoration.underline);
    expect(children.last.style?.backgroundColor, isNotNull);
    expect(controller.activeIssueIndex, 1);

    controller.dispose();
  });

  test('clearIssues resets highlighting state', () {
    final controller = SpellCheckEditingController(text: 'Helo');
    controller.setIssues(
      const <SpellIssue>[SpellIssue(word: 'Helo', start: 0, end: 4)],
      activeIssueIndex: 0,
    );

    controller.clearIssues();

    expect(controller.issues, isEmpty);
    expect(controller.activeIssueIndex, -1);
    controller.dispose();
  });
}
