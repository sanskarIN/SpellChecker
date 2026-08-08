import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/core/spell_checker_engine.dart';
import 'package:spellchecker/core/spell_language_pack.dart';

void main() {
  group('SpellLanguageRegistry', () {
    test('provides explicit US and UK English packs', () {
      expect(
        SpellLanguageRegistry.builtIns.map((pack) => pack.id),
        containsAll(<String>['en-US', 'en-GB']),
      );
      expect(SpellLanguageRegistry.defaultPack.id, 'en-US');
      expect(SpellLanguageRegistry.byId('missing').id, 'en-US');
    });

    test('tokenizes Unicode letters with normalized punctuation', () {
      final pack = SpellLanguageRegistry.englishUs;
      final words = pack
          .tokenize("Café naïve résumé writer’s open‑source")
          .map((match) => match.group(0))
          .toList();

      expect(
        words,
        <String>['Café', 'naïve', 'résumé', 'writer’s', 'open‑source'],
      );
      expect(pack.normalizeWord('Writer’s'), "writer's");
      expect(pack.normalizeWord('open‑source'), 'open-source');
    });
  });

  group('language-aware SpellCheckerEngine', () {
    test('US and UK packs distinguish common spelling variants', () {
      final us = SpellCheckerEngine(languagePack: SpellLanguageRegistry.englishUs);
      final uk = SpellCheckerEngine(languagePack: SpellLanguageRegistry.englishGb);

      expect(us.isCorrect('color'), isTrue);
      expect(us.isCorrect('colour'), isFalse);
      expect(uk.isCorrect('colour'), isTrue);
      expect(uk.isCorrect('color'), isFalse);
    });

    test('Unicode loanwords are checked as whole tokens', () {
      final engine = SpellCheckerEngine(languagePack: SpellLanguageRegistry.englishUs);

      expect(engine.check('café naïve résumé'), isEmpty);
    });

    test('issues carry the producing language id', () {
      final engine = SpellCheckerEngine(languagePack: SpellLanguageRegistry.englishGb);

      final issue = engine.check('color').single;

      expect(issue.languageId, 'en-GB');
    });

    test('detailed suggestions carry language and source metadata', () {
      final engine = SpellCheckerEngine(languagePack: SpellLanguageRegistry.englishGb);

      final details = engine.suggestionDetailsFor('colur');

      expect(details, isNotEmpty);
      expect(details.first.languageId, 'en-GB');
      expect(details.first.languageDisplayName, 'English (UK)');
      expect(details.first.source, contains('English (UK)'));
      expect(details.map((detail) => detail.word), contains('colour'));
    });

    test('personal words do not leak between language engines', () {
      final us = SpellCheckerEngine(languagePack: SpellLanguageRegistry.englishUs);
      final uk = SpellCheckerEngine(languagePack: SpellLanguageRegistry.englishGb);

      us.addToPersonalDictionary('zorbax');
      us.ignoreWord('temporaryword');

      expect(us.isCorrect('zorbax'), isTrue);
      expect(us.isCorrect('temporaryword'), isTrue);
      expect(uk.isCorrect('zorbax'), isFalse);
      expect(uk.isCorrect('temporaryword'), isFalse);
    });
  });
}
