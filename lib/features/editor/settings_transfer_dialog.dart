import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/settings_transfer_codec.dart';
import '../../core/spell_language_pack.dart';

class SettingsTransferDialog extends StatefulWidget {
  const SettingsTransferDialog({super.key, required this.initialDocument});

  final SpellCheckerSettingsDocument initialDocument;

  @override
  State<SettingsTransferDialog> createState() => _SettingsTransferDialogState();
}

class _SettingsTransferDialogState extends State<SettingsTransferDialog> {
  final TextEditingController _importController = TextEditingController();
  late final String _exportText;
  String? _errorMessage;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _exportText = SpellCheckerSettingsCodec.encode(widget.initialDocument);
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _copyExport() async {
    await Clipboard.setData(ClipboardData(text: _exportText));
    if (!mounted) {
      return;
    }
    setState(() {
      _errorMessage = null;
      _statusMessage = 'Portable settings JSON copied to the clipboard.';
    });
  }

  void _import() {
    final source = _importController.text.trim();
    if (source.isEmpty) {
      setState(() {
        _statusMessage = null;
        _errorMessage = 'Paste a portable settings JSON document first.';
      });
      return;
    }

    try {
      final document = SpellCheckerSettingsCodec.decode(source);
      Navigator.of(context).pop(document);
    } on FormatException catch (error) {
      setState(() {
        _statusMessage = null;
        _errorMessage = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPack = SpellLanguageRegistry.byId(
      widget.initialDocument.languageId,
    );
    final overrideCount = widget.initialDocument.writingRuleOverrides.length;

    return AlertDialog(
      title: const Row(
        children: <Widget>[
          Icon(Icons.settings_backup_restore_outlined),
          SizedBox(width: 10),
          Expanded(child: Text('Portable settings')),
        ],
      ),
      content: SizedBox(
        width: 680,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 650),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              const Text(
                'Portable settings contain preferences only. Editor text, personal vocabulary, ignored session words, spelling or writing findings, and correction history are never included.',
              ),
              const SizedBox(height: 16),
              Text(
                'Current durable settings',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text('Language: ${selectedPack.displayName}'),
              Text(
                'Suggestions per issue: ${widget.initialDocument.suggestionLimit}',
              ),
              Text(
                'Explicit writing-rule overrides: $overrideCount ${overrideCount == 1 ? 'language' : 'languages'}',
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _exportText,
                    key: const ValueKey<String>('portable-settings-export'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  key: const ValueKey<String>('copy-portable-settings'),
                  onPressed: _copyExport,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy settings JSON'),
                ),
              ),
              const Divider(height: 32),
              Text(
                'Import settings',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              const Text(
                'Import replaces selected language, suggestion count, and the complete set of explicit per-language writing-rule overrides. Missing override keys return that language to built-in rule defaults.',
              ),
              const SizedBox(height: 10),
              TextField(
                key: const ValueKey<String>('portable-settings-import'),
                controller: _importController,
                minLines: 5,
                maxLines: 9,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'Portable settings JSON',
                  alignLabelWithHint: true,
                ),
              ),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _errorMessage!,
                    key: const ValueKey<String>('portable-settings-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              if (_statusMessage != null) ...<Widget>[
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _statusMessage!,
                    key: const ValueKey<String>('portable-settings-status'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  key: const ValueKey<String>('import-portable-settings'),
                  onPressed: _import,
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('Import settings'),
                ),
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
