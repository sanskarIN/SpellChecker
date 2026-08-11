import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  group('WritingAnalysisResult diagnostics', () {
    test('unbounded analyzer reports exact overall and per-rule totals', () {
      final analyzer = WritingAnalyzer(
        rules: const <WritingRule>[
          _DiagnosticOffsetsRule('alpha', <int>[1, 5, 9]),
          _DiagnosticOffsetsRule('beta', <int>[2, 4]),
        ],
      );

      final result = analyzer.analyze(
        'abcdefghijk',
        languagePack: pack,
      );

      expect(result.isTruncated, isFalse);
      expect(result.capturedIssueCount, 5);
      expect(result.totalIssueCount, 5);
      expect(result.uncapturedIssueCount, 0);
      expect(result.hasExactIssueTotals, isTrue);
      expect(result.totalIssueCountByRule, <String, int>{
        'alpha': 3,
        'beta': 2,
      });
      expect(result.issueCountByRule, result.totalIssueCountByRule);
    });

    test('bounded analyzer counts uncaptured findings exactly', () {
      final analyzer = WritingAnalyzer(
        rules: const <WritingRule>[
          _DiagnosticOffsetsRule('alpha', <int>[8, 6, 4, 2]),
          _DiagnosticOffsetsRule('beta', <int>[9, 7, 5, 3, 1]),
        ],
      );

      final result = analyzer.analyze(
        'abcdefghijk',
        languagePack: pack,
        maxIssues: 3,
      );

      expect(result.isTruncated, isTrue);
      expect(result.issueLimit, 3);
      expect(result.capturedIssueCount, 3);
      expect(result.totalIssueCount, 9);
      expect(result.uncapturedIssueCount, 6);
      expect(result.issues.map((WritingIssue issue) => issue.start), <int>[
        1,
        2,
        3,
      ]);
      expect(result.issueCountByRule, <String, int>{
        'beta': 2,
        'alpha': 1,
      });
      expect(result.totalIssueCountByRule, <String, int>{
        'alpha': 4,
        'beta': 5,
      });
    });

    test('disabled rules do not contribute to exact totals', () {
      final analyzer = WritingAnalyzer(
        rules: const <WritingRule>[
          _DiagnosticOffsetsRule('alpha', <int>[1, 2]),
          _DiagnosticOffsetsRule('beta', <int>[3, 4, 5]),
        ],
      );

      final result = analyzer.analyze(
        'abcdef',
        languagePack: pack,
        enabledRuleIds: <String>{'beta'},
        maxIssues: 1,
      );

      expect(result.analyzedRuleIds, <String>{'beta'});
      expect(result.totalIssueCount, 3);
      expect(result.totalIssueCountByRule, <String, int>{'beta': 3});
      expect(result.uncapturedIssueCount, 2);
    });

    test('zero findings still have exact analyzer diagnostics', () {
      final analyzer = WritingAnalyzer(
        rules: const <WritingRule>[
          _DiagnosticOffsetsRule('alpha', <int>[]),
        ],
      );

      final result = analyzer.analyze(
        'abc',
        languagePack: pack,
        maxIssues: 2,
      );

      expect(result.isClean, isTrue);
      expect(result.isComplete, isTrue);
      expect(result.totalIssueCount, 0);
      expect(result.uncapturedIssueCount, 0);
      expect(result.totalIssueCountByRule, isEmpty);
    });

    test('per-rule total diagnostics are immutable', () {
      final result = WritingAnalyzer(
        rules: const <WritingRule>[
          _DiagnosticOffsetsRule('alpha', <int>[1, 2]),
        ],
      ).analyze('abcd', languagePack: pack, maxIssues: 1);

      expect(
        () => result.totalIssueCountByRule!['alpha'] = 99,
        throwsUnsupportedError,
      );
      expect(
        () => result.totalIssueCountByRule!.clear(),
        throwsUnsupportedError,
      );
    });

    test('direct V2.7-style construction may omit exact diagnostics', () {
      const issue = WritingIssue(
        ruleId: 'alpha',
        ruleName: 'Alpha',
        message: 'Review this.',
        start: 0,
        end: 1,
        originalText: 'a',
        replacement: 'A',
        languageId: 'en-US',
      );

      final result = WritingAnalysisResult(
        issues: const <WritingIssue>[issue],
        analyzedRuleIds: const <String>{'alpha'},
        languageId: 'en-US',
        issueLimit: 1,
        isTruncated: true,
      );

      expect(result.totalIssueCount, isNull);
      expect(result.totalIssueCountByRule, isNull);
      expect(result.uncapturedIssueCount, isNull);
      expect(result.hasExactIssueTotals, isFalse);
    });

    test('exact totals reject fewer findings than captured', () {
      const issue = WritingIssue(
        ruleId: 'alpha',
        ruleName: 'Alpha',
        message: 'Review this.',
        start: 0,
        end: 1,
        originalText: 'a',
        languageId: 'en-US',
      );

      expect(
        () => WritingAnalysisResult(
          issues: const <WritingIssue>[issue],
          analyzedRuleIds: const <String>{'alpha'},
          languageId: 'en-US',
          totalIssueCount: 0,
        ),
        throwsArgumentError,
      );
    });

    test('complete exact totals must equal captured findings', () {
      const issue = WritingIssue(
        ruleId: 'alpha',
        ruleName: 'Alpha',
        message: 'Review this.',
        start: 0,
        end: 1,
        originalText: 'a',
        languageId: 'en-US',
      );

      expect(
        () => WritingAnalysisResult(
          issues: const <WritingIssue>[issue],
          analyzedRuleIds: const <String>{'alpha'},
          languageId: 'en-US',
          totalIssueCount: 2,
        ),
        throwsArgumentError,
      );
    });

    test('truncated exact totals must prove an uncaptured finding', () {
      const issue = WritingIssue(
        ruleId: 'alpha',
        ruleName: 'Alpha',
        message: 'Review this.',
        start: 0,
        end: 1,
        originalText: 'a',
        languageId: 'en-US',
      );

      expect(
        () => WritingAnalysisResult(
          issues: const <WritingIssue>[issue],
          analyzedRuleIds: const <String>{'alpha'},
          languageId: 'en-US',
          issueLimit: 1,
          isTruncated: true,
          totalIssueCount: 1,
        ),
        throwsArgumentError,
      );
    });

    test('per-rule totals must sum to the exact overall total', () {
      expect(
        () => WritingAnalysisResult(
          issues: const <WritingIssue>[],
          analyzedRuleIds: const <String>{'alpha'},
          languageId: 'en-US',
          totalIssueCount: 0,
          totalIssueCountByRule: const <String, int>{'alpha': 1},
        ),
        throwsArgumentError,
      );
    });

    test('per-rule totals cannot under-report captured rule counts', () {
      const issue = WritingIssue(
        ruleId: 'alpha',
        ruleName: 'Alpha',
        message: 'Review this.',
        start: 0,
        end: 1,
        originalText: 'a',
        languageId: 'en-US',
      );

      expect(
        () => WritingAnalysisResult(
          issues: const <WritingIssue>[issue],
          analyzedRuleIds: const <String>{'alpha'},
          languageId: 'en-US',
          issueLimit: 1,
          isTruncated: true,
          totalIssueCount: 2,
          totalIssueCountByRule: const <String, int>{'beta': 2},
        ),
        throwsArgumentError,
      );
    });
  });
}

class _DiagnosticOffsetsRule extends WritingRule {
  const _DiagnosticOffsetsRule(this.id, this.offsets);

  @override
  final String id;

  final List<int> offsets;

  @override
  String get displayName => id;

  @override
  String get description => 'Synthetic diagnostics rule.';

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
