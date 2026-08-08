from pathlib import Path

path = Path('lib/core/spell_language_pack.dart')
text = path.read_text()

old_dictionary = '''    dictionary: <String>{
      ...EnglishDictionary.words,
      ...EnglishDictionaryExtension.words,
      ..._unicodeLoanwords,
      ..._usVariantWords,
    },'''
new_dictionary = '''    dictionary: _buildEnglishUsDictionary(),'''

if old_dictionary in text:
    text = text.replace(old_dictionary, new_dictionary, 1)
elif new_dictionary not in text:
    raise RuntimeError('Could not find the English US dictionary construction block.')

marker = '''  static Set<String> _buildEnglishGbDictionary() {'''
method = '''  static Set<String> _buildEnglishUsDictionary() {
    final words = <String>{
      ...EnglishDictionary.words,
      ...EnglishDictionaryExtension.words,
      ..._unicodeLoanwords,
      ..._usVariantWords,
    };
    words.removeAll(EnglishGbDictionary.words);
    words.addAll(_usVariantWords);
    return words;
  }

'''

if method.strip() not in text:
    if marker not in text:
        raise RuntimeError('Could not find the GB dictionary builder marker.')
    text = text.replace(marker, method + marker, 1)

path.write_text(text)

updated = path.read_text()
for required in (
    'dictionary: _buildEnglishUsDictionary()',
    'words.removeAll(EnglishGbDictionary.words)',
    'words.addAll(_usVariantWords)',
):
    if required not in updated:
        raise RuntimeError(f'Missing variant guard: {required}')

print('US/UK variant isolation guard applied.')
