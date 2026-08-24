import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/core/spell_language_pack.dart';
import 'package:spellchecker/features/editor/language_picker_dialog.dart';

void main() {
  testWidgets('searches spelling languages by display name and stable ID', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _LanguagePickerHarness(
          languagePacks: SpellLanguageRegistry.builtIns,
          selectedLanguageId: 'en-US',
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('language-selector')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose spelling language'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('language-option-en-US')),
      findsOneWidget,
    );

    final search = find.byKey(
      const ValueKey<String>('language-picker-search'),
    );
    await tester.enterText(search, 'Tamil');
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('language-option-ta-IN')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('language-option-en-US')),
      findsNothing,
    );

    await tester.enterText(search, 'pt-BR');
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('language-option-pt-BR')),
      findsOneWidget,
    );
    expect(find.text('Portuguese (Brazil)'), findsOneWidget);
  });

  testWidgets('returns the selected stable language ID', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _LanguagePickerHarness(
          languagePacks: SpellLanguageRegistry.builtIns,
          selectedLanguageId: 'en-US',
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('language-selector')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('language-picker-search')),
      'hi-IN',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('language-option-hi-IN')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Selected: hi-IN'), findsOneWidget);
    expect(find.text('Choose spelling language'), findsNothing);
  });

  testWidgets('supports empty-result recovery and cancellation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _LanguagePickerHarness(
          languagePacks: SpellLanguageRegistry.builtIns,
          selectedLanguageId: 'en-GB',
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('language-selector')),
    );
    await tester.pumpAndSettle();

    final search = find.byKey(
      const ValueKey<String>('language-picker-search'),
    );
    await tester.enterText(search, 'not-a-language');
    await tester.pump();

    expect(find.text('No matching languages'), findsOneWidget);
    expect(find.byTooltip('Clear language search'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear language search'));
    await tester.pump();

    expect(find.text('No matching languages'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('language-option-en-GB')),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Selected: none'), findsOneWidget);
  });
}

class _LanguagePickerHarness extends StatefulWidget {
  const _LanguagePickerHarness({
    required this.languagePacks,
    required this.selectedLanguageId,
  });

  final List<SpellLanguagePack> languagePacks;
  final String selectedLanguageId;

  @override
  State<_LanguagePickerHarness> createState() => _LanguagePickerHarnessState();
}

class _LanguagePickerHarnessState extends State<_LanguagePickerHarness> {
  String? _selectedLanguageId;

  @override
  Widget build(BuildContext context) {
    final selectedPack = SpellLanguageRegistry.byId(widget.selectedLanguageId);
    return Scaffold(
      body: Column(
        children: <Widget>[
          SpellingLanguageSelector(
            selectorKey: const ValueKey<String>('language-selector'),
            languagePacks: widget.languagePacks,
            selectedLanguage: selectedPack,
            onChanged: (String languageId) {
              setState(() => _selectedLanguageId = languageId);
            },
          ),
          Text('Selected: ${_selectedLanguageId ?? 'none'}'),
        ],
      ),
    );
  }
}
