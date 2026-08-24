import 'package:flutter/material.dart';

import '../../core/spell_language_pack.dart';

class SpellingLanguagePickerDialog extends StatefulWidget {
  const SpellingLanguagePickerDialog({
    required this.languagePacks,
    required this.selectedLanguageId,
    super.key,
  });

  final List<SpellLanguagePack> languagePacks;
  final String selectedLanguageId;

  @override
  State<SpellingLanguagePickerDialog> createState() =>
      _SpellingLanguagePickerDialogState();
}

class _SpellingLanguagePickerDialogState
    extends State<SpellingLanguagePickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SpellLanguagePack> get _visibleLanguagePacks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.languagePacks;
    }

    return widget.languagePacks
        .where(
          (SpellLanguagePack pack) =>
              pack.displayName.toLowerCase().contains(query) ||
              pack.id.toLowerCase().contains(query) ||
              pack.languageCode.toLowerCase().contains(query) ||
              pack.regionCode.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final visiblePacks = _visibleLanguagePacks;

    return AlertDialog(
      title: const Text('Choose spelling language'),
      content: SizedBox(
        width: 520,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              key: const ValueKey<String>('language-picker-search'),
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (String value) => setState(() => _query = value),
              decoration: InputDecoration(
                labelText: 'Search languages',
                hintText: 'Name or language ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear language search',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: visiblePacks.isEmpty
                  ? const _NoLanguageMatches()
                  : ListView.builder(
                      itemCount: visiblePacks.length,
                      itemBuilder: (BuildContext context, int index) {
                        final pack = visiblePacks[index];
                        final selected = pack.id == widget.selectedLanguageId;
                        return Semantics(
                          selected: selected,
                          button: true,
                          label:
                              '${pack.displayName}, spelling language ${pack.id}${selected ? ', selected' : ''}',
                          child: ListTile(
                            key: ValueKey<String>('language-option-${pack.id}'),
                            selected: selected,
                            title: Text(pack.displayName),
                            subtitle: Text(pack.id),
                            trailing: selected
                                ? const Icon(
                                    Icons.check_circle,
                                    semanticLabel: 'Selected language',
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(pack.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _NoLanguageMatches extends StatelessWidget {
  const _NoLanguageMatches();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Semantics(
        liveRegion: true,
        label: 'No spelling languages match the current search.',
        child: Text(
          'No matching languages',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
