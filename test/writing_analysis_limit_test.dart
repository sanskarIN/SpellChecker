import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  group('WritingAnalyzer bounded analysis', () {
    test('default analysis remains unbounded and complete', () {
      final result = WritingAnalyzer().analyze(
        'hello  world world!!',
        languagePack: pack,
      );

      expect(result.issueLimit, isNull);
      expect(result.isTruncated, isFalse);
      expect(result.isComplete, isTrue);
      expect(result.capturedIssueCount, result.issues.length);
      expect(result.issues, isNotEmpty);
    });

    test('rejects non-positive maxIssues values', () {
      final analyzer = WritingAnalyzer();

      expect(
        () => analyzer.analyze(
          'Hello world.',
          languagePack: pack,
          maxIssues: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => analyzer.analyze(
          'Hello world.',
          languagePack: pack,
          maxIssues: -1,
        ),
        throwsArgumentError,
      );
    });

    test('exactly reaching the limit remains complete', () {
      final analyzer = WritingAnalyzer(
        rules: <WritingRule>[
          _OffsetsRule('only-rule', <int>[1, 3, 5]),
        ],
      );
      const text = 'abcdefghij';

      final result = analyzer.analyze(
        text,
        languagePack: pack,
        maxIssues: 3,
      );

      expect(result.issueLimit, 3);
      expect(result.capturedIssueCount, 3);
      expect(result.isTruncated, isFalse);
      expect(result.isComplete, isTrue);
      expect(result.issues.map((issue) => issue.start), <int>[1, 3, 5]);
    });

    test('reports truncation only after an additional finding exists', () {
      final analyzer = WritingAnalyzer(
        rules: <WritingRule>[
          _OffsetsRule('only-rule', <int>[1, 3, 5, 7]),
        ],
      );
      const text = 'abcdefghij';

      final result = analyzer.analyze(
        text,
        languagePack: pack,
        maxIssues: 3,
      );

      expect(result.issueLimit, 3);
      expect(result.capturedIssueCount, 3);
      expect(result.isTruncated, isTrue);
      expect(result.isComplete, isFalse);
      expect(result.issues.map((issue) => issue.start), <int>[1, 3, 5]);
    });

    test('bounded capture matches the globally sorted unbounded prefix', () {
      final analyzer = WritingAnalyzer(
        rules: <WritingRule>[
          _OffsetsRule('rule-z', <int>[90, 10, 50]),
          _OffsetsRule('rule-a', <int>[80, 5, 20]),
        ],
      );
      final text = List<String>.filled(100, 'x').join();

      final unbounded = analyzer.analyze(text, languagePack: pack);
      final bounded = analyzer.analyze(
        text,
        languagePack: pack,
        maxIssues: 3,
      );

      expect(unbounded.issues.map((issue) => issue.start), <int>[
        5,
        10,
        20,
        50,
        80,
        90,
      ]);
      expect(bounded.issues, unbounded.issues.take(3).toList());
      expect(bounded.isTruncated, isTrue);
    });

    test('later rules can displace worse retained findings', () {
      final analyzer = WritingAnalyzer(
        rules: <WritingRule>[
          _OffsetsRule('first-rule', <int>[70, 80, 90]),
          _OffsetsRule('second-rule', <int>[1, 2, 3]),
        ],
      );
      final text = List<String>.filled(100, 'x').join();

      final result = analyzer.analyze(
        text,
        languagePack: pack,
        maxIssues: 2,
      );

      expect(result.issues.map((issue) => issue.start), <int>[1, 2]);
      expect(result.isTruncated, isTrue);
      expect(result.analyzedRuleIds, <String>{'first-rule', 'second-rule'});
    });

    test('captured per-rule counts describe retained findings only', () {
      final analyzer = WritingAnalyzer(
        rules: <WritingRule>[
          _OffsetsRule('rule-a', <int>[1, 4, 7]),
          _OffsetsRule('rule-b', <int>[2, 3, 8]),
        ],
      );
      const text = 'abcdefghij';

      final result = analyzer.analyze(
        text,
        languagePack: pack,
        maxIssues: 4,
      );

      expect(result.isTruncated, isTrue);
      expect(result.issueCountByRule, <String, int>{
        'rule-a': 2,
        'rule-b': 2,
      });
      expect(result.capturedIssueCount, 4);
    });

    test('result metadata enforces a consistent bounded contract', () {
      expect(
        () => WritingAnalysisResult(
          issues: const <WritingIssue>[],
          analyzedRuleIds: const <String>{},
          languageId: 'en-US',
          issueLimit: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => WritingAnalysisResult(
          issues: const <WritingIssue>[],
          analyzedRuleIds: const <String>{},
          languageId: 'en-US',
          isTruncated: true,
        ),
        throwsArgumentError,
      );
    });

    test('captured issues remain immutable', () {
      final result = WritingAnalyzer(
        rules: <WritingRule>[
          _OffsetsRule('only-rule', <int>[1, 2]),
        ],
      ).analyze('abcd', languagePack: pack, maxIssues: 1);

      expect(
        () => result.issues.add(
          const WritingIssue(
            ruleId: 'extra',
            ruleName: 'Extra',
            message: 'Extra',
            start: 0,
            end: 1,
            originalText: 'a',
            languageId: 'en-US',
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}

class _OffsetsRule extends WritingRule {
  const _OffsetsRule(this.id, this.offsets);

  @override
  final String id;

  final List<int> offsets;

  @override
  String get displayName => id;

  @override
  String get description => 'Synthetic test rule.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final offset in offsets) {
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Synthetic finding at $offset.',
        start: offset,
        end: offset + 1,
        originalText: text.substring(offset, offset + 1),
        replacement: '',
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
