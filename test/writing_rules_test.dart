import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  group('built-in writing rules', () {
    test('repeated word rule finds adjacent duplicates only', () {
      const rule = RepeatedWordRule();

      final issues = rule
          .analyze('This is is fine. Is this is?', pack)
          .toList();

      expect(issues, hasLength(1));
      expect(issues.single.ruleId, 'repeated-word');
      expect(issues.single.originalText, ' is');
      expect(issues.single.replacement, '');
    });

    test('sentence capitalization finds first words after boundaries', () {
      const rule = SentenceCapitalizationRule();

      final issues = rule.analyze('hello world. next sentence!', pack).toList();

      expect(issues, hasLength(2));
      expect(issues.map((issue) => issue.originalText), <String>[
        'hello',
        'next',
      ]);
      expect(issues.map((issue) => issue.replacement), <String>[
        'Hello',
        'Next',
      ]);
    });

    test('sentence capitalization ignores dot-connected word segments', () {
      const rule = SentenceCapitalizationRule();

      final issues = rule
          .analyze('Visit example.com today. next sentence', pack)
          .toList();

      expect(issues.map((issue) => issue.originalText), <String>['next']);
    });

    test('repeated space rule keeps newlines outside its scope', () {
      const rule = RepeatedSpaceRule();

      final issues = rule.analyze('one  two\n  three', pack).toList();

      expect(issues, hasLength(2));
      expect(issues.every((issue) => issue.replacement == ' '), isTrue);
    });

    test(
      'punctuation spacing removes horizontal whitespace before punctuation',
      () {
        const rule = PunctuationSpacingRule();

        final issues = rule.analyze('Hello , world  ! Fine\t?', pack).toList();

        expect(issues, hasLength(3));
        expect(
          issues.map((issue) => issue.originalText),
          orderedEquals(<String>[' ', '  ', '\t']),
        );
        expect(issues.every((issue) => issue.replacement == ''), isTrue);
        expect(
          issues.every((issue) => issue.ruleId == 'punctuation-spacing'),
          isTrue,
        );
      },
    );

    test(
      'punctuation spacing ignores punctuation without preceding whitespace',
      () {
        const rule = PunctuationSpacingRule();

        expect(rule.analyze('Hello, world! Fine?', pack), isEmpty);
      },
    );

    test('trailing whitespace handles LF, CRLF, and document end', () {
      const rule = TrailingWhitespaceRule();
      const text = 'one  \ntwo\t\r\nthree   ';

      final issues = rule.analyze(text, pack).toList();

      expect(issues, hasLength(3));
      expect(
        issues.map((issue) => issue.originalText),
        orderedEquals(<String>['  ', '\t', '   ']),
      );
      expect(issues.every((issue) => issue.replacement == ''), isTrue);
      for (final issue in issues) {
        expect(text.substring(issue.start, issue.end), issue.originalText);
      }
    });

    test('trailing whitespace ignores indentation and interior spacing', () {
      const rule = TrailingWhitespaceRule();

      expect(rule.analyze('  indented\nword\tinside', pack), isEmpty);
    });

    test('repeated punctuation rule collapses identical punctuation runs', () {
      const rule = RepeatedPunctuationRule();

      final issues = rule.analyze('Really?? Yes!! Wait...', pack).toList();

      expect(issues, hasLength(3));
      expect(issues.map((issue) => issue.replacement), <String>['?', '!', '.']);
    });
  });

  group('WritingAnalyzer', () {
    test('rejects duplicate rule identifiers', () {
      expect(
        () => WritingAnalyzer(
          rules: const <WritingRule>[RepeatedSpaceRule(), RepeatedSpaceRule()],
        ),
        throwsArgumentError,
      );
    });

    test('runs enabled rules and returns sorted issues', () {
      final analyzer = WritingAnalyzer();

      final result = analyzer.analyze(
        'hello  world world!!',
        languagePack: pack,
      );

      expect(result.languageId, 'en-US');
      expect(result.isClean, isFalse);
      expect(result.analyzedRuleIds, hasLength(7));
      expect(
        result.issues.map((issue) => issue.start),
        orderedEquals(
          result.issues.map((issue) => issue.start).toList()..sort(),
        ),
      );
      expect(result.issueCountByRule['repeated-word'], 1);
      expect(result.issueCountByRule['sentence-capitalization'], 1);
      expect(result.issueCountByRule['repeated-space'], 1);
      expect(result.issueCountByRule['repeated-punctuation'], 1);
      expect(result.issueCountByRule['missing-punctuation-space'], isNull);
      expect(result.issueCountByRule['punctuation-spacing'], isNull);
      expect(result.issueCountByRule['trailing-whitespace'], isNull);
    });

    test(
      'expanded rules are enabled by default and address mixed mechanics',
      () {
        final analyzer = WritingAnalyzer();

        final result = analyzer.analyze(
          'Hello  !\nWorld  Next,word  ',
          languagePack: pack,
        );

        expect(
          result.analyzedRuleIds,
          containsAll(<String>{
            'missing-punctuation-space',
            'punctuation-spacing',
            'trailing-whitespace',
          }),
        );
        expect(result.issueCountByRule['missing-punctuation-space'], 1);
        expect(result.issueCountByRule['punctuation-spacing'], 1);
        expect(result.issueCountByRule['trailing-whitespace'], 1);
      },
    );

    test('can disable all but one rule', () {
      final analyzer = WritingAnalyzer();

      final result = analyzer.analyze(
        'hello  hello!!',
        languagePack: pack,
        enabledRuleIds: <String>{'repeated-space'},
      );

      expect(result.analyzedRuleIds, <String>{'repeated-space'});
      expect(result.issues, hasLength(1));
      expect(result.issues.single.ruleId, 'repeated-space');
    });

    test('English rules support both built-in English packs', () {
      const rules = <WritingRule>[
        RepeatedWordRule(),
        PunctuationSpacingRule(),
        MissingPunctuationSpaceRule(),
        TrailingWhitespaceRule(),
      ];

      for (final rule in rules) {
        expect(rule.supports(SpellLanguageRegistry.englishUs), isTrue);
        expect(rule.supports(SpellLanguageRegistry.englishGb), isTrue);
      }
    });

    test('registry resolves expanded stable rule IDs', () {
      expect(
        WritingRuleRegistry.byId('punctuation-spacing'),
        isA<PunctuationSpacingRule>(),
      );
      expect(
        WritingRuleRegistry.byId('missing-punctuation-space'),
        isA<MissingPunctuationSpaceRule>(),
      );
      expect(
        WritingRuleRegistry.byId('trailing-whitespace'),
        isA<TrailingWhitespaceRule>(),
      );
      expect(
        WritingRuleRegistry.defaultEnabledRuleIds,
        containsAll(<String>{
          'missing-punctuation-space',
          'punctuation-spacing',
          'trailing-whitespace',
        }),
      );
    });
  });
}
