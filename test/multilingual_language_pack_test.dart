import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/core/spell_checker_engine.dart';
import 'package:spellchecker/core/spell_language_pack.dart';

void main() {
  group('multilingual registry', () {
    test('exposes thirteen built-in language packs', () {
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
          'bn-IN',
          'mr-IN',
          'ta-IN',
          'te-IN',
          'ru-RU',
        ],
      );
    });

    test('resolves every V3.2 pack by stable language id', () {
      for (final id in <String>['bn-IN', 'mr-IN', 'ta-IN', 'te-IN', 'ru-RU']) {
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
        SpellLanguageRegistry.bengaliIndia: 'নমস্কার বিশ্ব ধন্যবাদ',
        SpellLanguageRegistry.marathiIndia: 'नमस्कार जग धन्यवाद',
        SpellLanguageRegistry.tamilIndia: 'வணக்கம் உலகம் நன்றி',
        SpellLanguageRegistry.teluguIndia: 'నమస్కారం ప్రపంచం ధన్యవాదాలు',
        SpellLanguageRegistry.russianRussia: 'привет мир спасибо',
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

    test('suggests corrections inside every multilingual pack', () {
      final cases = <SpellLanguagePack, (String, String)>{
        SpellLanguageRegistry.hindiIndia: ('नमसते', 'नमस्ते'),
        SpellLanguageRegistry.spanishSpain: ('holaa', 'hola'),
        SpellLanguageRegistry.frenchFrance: ('bonjor', 'bonjour'),
        SpellLanguageRegistry.germanGermany: ('haloo', 'hallo'),
        SpellLanguageRegistry.portugueseBrazil: ('obrigdo', 'obrigado'),
        SpellLanguageRegistry.italianItaly: ('graze', 'grazie'),
        SpellLanguageRegistry.bengaliIndia: ('ধন্যবদ', 'ধন্যবাদ'),
        SpellLanguageRegistry.marathiIndia: ('नमसकार', 'नमस्कार'),
        SpellLanguageRegistry.tamilIndia: ('நன்ற', 'நன்றி'),
        SpellLanguageRegistry.teluguIndia: ('నమస్కార', 'నమస్కారం'),
        SpellLanguageRegistry.russianRussia: ('превет', 'привет'),
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

    test('keeps Unicode join controls inside a single Indic word', () {
      const joinedWord = 'क्\u200Dष';
      final pack = SpellLanguageRegistry.hindiIndia;
      final matches = pack.tokenize('अब $joinedWord शब्द').toList();

      expect(matches.map((match) => match.group(0)).toList(), <String>[
        'अब',
        joinedWord,
        'शब्द',
      ]);
      expect(pack.isValidWord(joinedWord), isTrue);
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
        languagePack: SpellLanguageRegistry.russianRussia,
      );

      final suggestion = engine
          .suggestionDetailsFor('превет')
          .firstWhere((detail) => detail.word == 'привет');

      expect(suggestion.languageId, 'ru-RU');
      expect(suggestion.languageDisplayName, 'Russian (Russia)');
      expect(suggestion.source, contains('Russian (Russia)'));
    });
  });
}
