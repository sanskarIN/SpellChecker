import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/editor/spell_checker_page.dart';
import 'l10n/app_localizations.dart';

class SpellCheckerApp extends StatelessWidget {
  const SpellCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4458D8),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'SpellChecker',
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9CA7FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const _AdaptiveSpellCheckerHome(),
    );
  }
}

class _AdaptiveSpellCheckerHome extends StatelessWidget {
  const _AdaptiveSpellCheckerHome();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const page = _SpellCheckerHome();
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final needsScrollableCanvas =
            constraints.maxWidth < 900 && textScale > 1.3;

        if (!needsScrollableCanvas || !constraints.hasBoundedHeight) {
          return page;
        }

        final extraScale = (textScale - 1).clamp(0.0, 2.0);
        final canvasHeight = constraints.maxHeight * (1 + extraScale);

        return SingleChildScrollView(
          child: SizedBox(
            width: constraints.maxWidth,
            height: canvasHeight,
            child: page,
          ),
        );
      },
    );
  }
}

class _SpellCheckerHome extends StatelessWidget {
  const _SpellCheckerHome();

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is! KeyDownEvent ||
            event.logicalKey != LogicalKeyboardKey.f1) {
          return KeyEventResult.ignored;
        }
        showDialog<void>(
          context: context,
          builder: (BuildContext context) => const _KeyboardShortcutsDialog(),
        );
        return KeyEventResult.handled;
      },
      child: const SpellCheckerPage(),
    );
  }
}

class _KeyboardShortcutsDialog extends StatelessWidget {
  const _KeyboardShortcutsDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.keyboardShortcutsTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(l10n.keyboardShortcutsIntro),
              SizedBox(height: 16),
              _ShortcutRow(
                action: l10n.shortcutCheckSpelling,
                shortcut: 'Ctrl/⌘ + Enter',
              ),
              _ShortcutRow(
                action: l10n.shortcutOpenWritingInsights,
                shortcut: 'Ctrl/⌘ + Shift + Enter',
              ),
              _ShortcutRow(
                action: l10n.shortcutNextSpellingIssue,
                shortcut: 'F7',
              ),
              _ShortcutRow(
                action: l10n.shortcutPreviousSpellingIssue,
                shortcut: 'Shift + F7',
              ),
              _ShortcutRow(action: l10n.shortcutOpenHelp, shortcut: 'F1'),
              SizedBox(height: 12),
              Text(l10n.keyboardShortcutsVisibleActions),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.action, required this.shortcut});

  final String action;
  final String shortcut;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: Text(action)),
          const SizedBox(width: 16),
          Semantics(
            label: l10n.shortcutSemantics(action, shortcut),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                shortcut,
                style: textTheme.labelLarge,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
