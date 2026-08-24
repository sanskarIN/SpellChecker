import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/editor/spell_checker_page.dart';

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
    return AlertDialog(
      title: const Text('Keyboard shortcuts'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Use these shortcuts while SpellChecker has focus. On macOS, ⌘ replaces Ctrl for the primary command shortcuts.',
              ),
              SizedBox(height: 16),
              _ShortcutRow(
                action: 'Check spelling',
                shortcut: 'Ctrl/⌘ + Enter',
              ),
              _ShortcutRow(
                action: 'Open Writing insights',
                shortcut: 'Ctrl/⌘ + Shift + Enter',
              ),
              _ShortcutRow(action: 'Next spelling issue', shortcut: 'F7'),
              _ShortcutRow(
                action: 'Previous spelling issue',
                shortcut: 'Shift + F7',
              ),
              _ShortcutRow(
                action: 'Open keyboard shortcut help',
                shortcut: 'F1',
              ),
              SizedBox(height: 12),
              Text(
                'All commands also remain available through visible buttons so keyboard access is never required.',
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: Text(action)),
          const SizedBox(width: 16),
          Semantics(
            label: '$action shortcut: $shortcut',
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
