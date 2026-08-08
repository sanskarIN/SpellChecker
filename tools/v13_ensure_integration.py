from pathlib import Path
import runpy

page = Path('lib/features/editor/spell_checker_page.dart').read_text()
pubspec = Path('pubspec.yaml').read_text()
manager = Path('lib/features/editor/dictionary_manager_dialog.dart').read_text()
barrel = Path('lib/spell_checker.dart').read_text()

integrated = all(
    (
        "ValueKey<String>('language-selector')" in page,
        'version: 1.3.0+4' in pubspec,
        'encodeForLanguage' in manager,
        "export 'core/spell_language_pack.dart';" in barrel,
        'languageId: _languagePack.id' in page,
    )
)

if integrated:
    print('V1.3 application integration is already present.')
else:
    helper = Path('tools/v13_apply.py')
    if not helper.exists():
        raise RuntimeError(
            'V1.3 integration is incomplete and the guarded apply helper is missing.'
        )
    print('V1.3 integration is missing; applying guarded transform now.')
    runpy.run_path(str(helper), run_name='__main__')
