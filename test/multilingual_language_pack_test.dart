import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/core/spell_checker_engine.dart';
import 'package:spellchecker/core/spell_language_pack.dart';

void main() {
  group('multilingual registry', () {
    test('exposes eight built-in language packs', () {
      expect(
        SpellLanguageRegistry.builtIns.map((pack) => pack.id).toList(),
        <String>[
          'en-US',
          'en-GB',
          'hi-IN',
          'es-ES',
          'fr-FR',
          'de-DE',
          'pt-BR',
          'it-IT',
        ],
      );
    });

    test('resolves every new pack by stable language id', () {
      for (final id in <String>[
        'hi-IN',
        'es-ES',
        'fr-FR',
        'de-DE',
        'pt-BR',
        'it-IT',
      ]) {
        expect(SpellLanguageRegistry.contains(id), isTrue);
        expect(SpellLanguageRegistry.byId(id).id, id);
      }
    });
  });

  group('bundled multilingual spelling', () {
    test('accepts representative native-language text', () {
      final samples = <SpellLanguagePack, String>{
        SpellLanguageRegistry.hindiIndia: 'नमस्ते दुनिया धन्यवाद',
        SpellLanguageRegistry.spanishSpain: 'hola mundo gracias',
        SpellLanguageRegistry.frenchFrance: 'bonjour le monde merci',
        SpellLanguageRegistry.germanGermany: 'hallo welt danke',
        SpellLanguageRegistry.portugueseBrazil: 'olá mundo obrigado',
        SpellLanguageRegistry.italianItaly: 'ciao mondo grazie',
      };

      for (final entry in samples.entries) {
        final engine = SpellCheckerEngine(languagePack: entry.key);
        expect(
          engine.check(entry.value),
          isEmpty,
          reason: '${entry.key.displayName} should accept its bundled sample',
        );
      }
    });

    test('suggests corrections inside every new language pack', () {
      final cases = <SpellLanguagePack, (String, String)>{
        SpellLanguageRegistry.hindiIndia: ('नमसते', 'नमस्ते'),
        SpellLanguageRegistry.spanishSpain: ('holaa', 'hola'),
        SpellLanguageRegistry.frenchFrance: ('bonjor', 'bonjour'),
        SpellLanguageRegistry.germanGermany: ('haloo', 'hallo'),
        SpellLanguageRegistry.portugueseBrazil: ('obrigdo', 'obrigado'),
        SpellLanguageRegistry.italianItaly: ('graze', 'grazie'),
      };

      for (final entry in cases.entries) {
        final engine = SpellCheckerEngine(languagePack: entry.key);
        final (typo, expected) = entry.value;
        final issue = engine.check(typo).single;

        expect(issue.languageId, entry.key.id);
        expect(
          issue.suggestions,
          contains(expected),
          reason: '${entry.key.displayName} should suggest $expected for $typo',
        );
      }
    });

    test('normalizes decomposed accents in non-English Latin packs', () {
      expect(
        SpellLanguageRegistry.spanishSpain.normalizeWord('man\u0303ana'),
        'mañana',
      );
      expect(
        SpellLanguageRegistry.frenchFrance.normalizeWord('e\u0301cole'),
        'école',
      );
      expect(
        SpellLanguageRegistry.germanGermany.normalizeWord('fu\u0308r'),
        'für',
      );
      expect(
        SpellLanguageRegistry.portugueseBrazil.normalizeWord('na\u0303o'),
        'não',
      );
      expect(
        SpellLanguageRegistry.italianItaly.normalizeWord('citta\u0300'),
        'città',
      );
    });

    test(
      'recognizes French elision prefixes and preserves them in suggestions',
      () {
        final engine = SpellCheckerEngine(
          languagePack: SpellLanguageRegistry.frenchFrance,
        );

        expect(engine.isCorrect('l’amour'), isTrue);
        expect(engine.suggestionsFor('l’amor'), contains("l'amour"));
      },
    );

    test(
      'recognizes Italian elision prefixes and preserves them in suggestions',
      () {
        final engine = SpellCheckerEngine(
          languagePack: SpellLanguageRegistry.italianItaly,
        );

        expect(engine.isCorrect('l’amore'), isTrue);
        expect(engine.suggestionsFor('l’amor'), contains("l'amore"));
      },
    );

    test('keeps detailed suggestion metadata language-specific', () {
      final engine = SpellCheckerEngine(
        languagePack: SpellLanguageRegistry.spanishSpain,
      );

      final suggestion = engine
          .suggestionDetailsFor('holaa')
          .firstWhere((detail) => detail.word == 'hola');

      expect(suggestion.languageId, 'es-ES');
      expect(suggestion.languageDisplayName, 'Spanish (Spain)');
      expect(suggestion.source, contains('Spanish (Spain)'));
    });
  });
}
