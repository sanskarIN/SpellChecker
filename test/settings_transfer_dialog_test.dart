import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/core/settings_transfer_codec.dart';
import 'package:spellchecker/features/editor/settings_transfer_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Finder settingsTransferList() {
    return find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(ListView),
    );
  }

  Future<void> scrollToImportArea(WidgetTester tester) async {
    final list = settingsTransferList();
    expect(list, findsOneWidget);
    await tester.drag(list, const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('portable-settings-import')),
      findsOneWidget,
    );
  }

  testWidgets('portable settings dialog describes privacy boundary and export', (
    WidgetTester tester,
  ) async {
    await _openDialog(
      tester,
      SpellCheckerSettingsDocument(
        languageId: 'en-GB',
        suggestionLimit: 7,
        writingRuleOverrides: <String, Iterable<String>>{
          'en-GB': const <String>[],
        },
      ),
    );

    expect(find.text('Portable settings'), findsOneWidget);
    expect(find.textContaining('Editor text'), findsOneWidget);
    expect(find.textContaining('personal vocabulary'), findsOneWidget);
    expect(find.text('Language: English (UK)'), findsOneWidget);
    expect(find.text('Suggestions per issue: 7'), findsOneWidget);

    final export = tester.widget<SelectableText>(
      find.byKey(const ValueKey<String>('portable-settings-export')),
    );
    final exportedText = export.data!;
    expect(exportedText, contains('"format": "spellchecker-settings"'));
    expect(exportedText, contains('"languageId": "en-GB"'));
    expect(exportedText, isNot(contains('personalWords')));
    expect(exportedText, isNot(contains('editorText')));
  });

  testWidgets('copy action writes the deterministic export to clipboard', (
    WidgetTester tester,
  ) async {
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'Clipboard.setData') {
            final arguments = methodCall.arguments as Map<Object?, Object?>;
            copiedText = arguments['text'] as String?;
          }
          return null;
        });

    final document = SpellCheckerSettingsDocument(
      languageId: 'en-US',
      suggestionLimit: 5,
    );
    await _openDialog(tester, document);

    await tester.tap(
      find.byKey(const ValueKey<String>('copy-portable-settings')),
    );
    await tester.pumpAndSettle();

    expect(copiedText, SpellCheckerSettingsCodec.encode(document));
    await scrollToImportArea(tester);
    expect(
      find.byKey(const ValueKey<String>('portable-settings-status')),
      findsOneWidget,
    );
  });

  testWidgets('valid import returns a decoded settings document', (
    WidgetTester tester,
  ) async {
    SpellCheckerSettingsDocument? imported;
    await _openDialog(
      tester,
      SpellCheckerSettingsDocument(
        languageId: 'en-US',
        suggestionLimit: 5,
      ),
      onImported: (SpellCheckerSettingsDocument? value) => imported = value,
    );

    final source = SpellCheckerSettingsCodec.encode(
      SpellCheckerSettingsDocument(
        languageId: 'en-GB',
        suggestionLimit: 9,
        writingRuleOverrides: <String, Iterable<String>>{
          'en-US': const <String>[],
        },
      ),
    );
    await scrollToImportArea(tester);
    await tester.enterText(
      find.byKey(const ValueKey<String>('portable-settings-import')),
      source,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('import-portable-settings')),
    );
    await tester.pumpAndSettle();

    expect(imported, isNotNull);
    expect(imported!.languageId, 'en-GB');
    expect(imported!.suggestionLimit, 9);
    expect(imported!.hasWritingRuleOverride('en-US'), isTrue);
    expect(imported!.writingRuleIdsFor('en-US'), isEmpty);
  });

  testWidgets('invalid import stays open and reports a format error', (
    WidgetTester tester,
  ) async {
    SpellCheckerSettingsDocument? imported;
    await _openDialog(
      tester,
      SpellCheckerSettingsDocument(
        languageId: 'en-US',
        suggestionLimit: 5,
      ),
      onImported: (SpellCheckerSettingsDocument? value) => imported = value,
    );

    await scrollToImportArea(tester);
    await tester.enterText(
      find.byKey(const ValueKey<String>('portable-settings-import')),
      '{invalid',
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('import-portable-settings')),
    );
    await tester.pumpAndSettle();

    expect(imported, isNull);
    expect(find.text('Portable settings'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('portable-settings-error')),
      findsOneWidget,
    );
  });
}

Future<void> _openDialog(
  WidgetTester tester,
  SpellCheckerSettingsDocument document, {
  ValueChanged<SpellCheckerSettingsDocument?>? onImported,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return FilledButton(
              onPressed: () async {
                final result = await showDialog<SpellCheckerSettingsDocument>(
                  context: context,
                  builder: (BuildContext context) => SettingsTransferDialog(
                    initialDocument: document,
                  ),
                );
                onImported?.call(result);
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}
