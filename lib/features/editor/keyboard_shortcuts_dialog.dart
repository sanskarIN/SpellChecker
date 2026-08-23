import 'package:flutter/material.dart';

class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Keyboard shortcuts'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
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
              _ShortcutRow(
                action: 'Next spelling issue',
                shortcut: 'F7',
              ),
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
