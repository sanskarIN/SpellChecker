import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  group('SpellCheckerEngine.analyze', () {
    test('unbounded analysis matches the historical check API', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello', 'world'});
      const text = 'hello wrld again';

      final report = engine.analyze(text, suggestionLimit: 2);
      final issues = engine.check(text, suggestionLimit: 2);

      expect(report.issues, issues);
      expect(report.issueLimit, isNull);
      expect(report.truncated, isFalse);
      expect(report.complete, isTrue);
      expect(report.scannedTokenCount, 3);
      expect(report.capturedIssueCount, 2);
    });

    test('exactly reaching the cap is still a complete result', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});

      final report = engine.analyze('wrld agin hello', maxIssues: 2);

      expect(report.issues.map((issue) => issue.word), <String>[
        'wrld',
        'agin',
      ]);
      expect(report.issueLimit, 2);
      expect(report.truncated, isFalse);
      expect(report.complete, isTrue);
      expect(report.scannedTokenCount, 3);
    });

    test('reports truncation only after proving another issue exists', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});

      final report = engine.analyze('wrld agin othr hello', maxIssues: 2);

      expect(report.issues.map((issue) => issue.word), <String>[
        'wrld',
        'agin',
      ]);
      expect(report.issueLimit, 2);
      expect(report.truncated, isTrue);
      expect(report.complete, isFalse);
      expect(report.scannedTokenCount, 3);
      expect(report.capturedIssueCount, 2);
    });

    test('does not generate suggestions for the overflow issue', () {
      final ranker = _RecordingRanker();
      final engine = SpellCheckerEngine(
        dictionary: <String>{'cat', 'cut', 'dog', 'dig', 'fog', 'fig'},
        suggestionRanker: ranker,
      );

      final report = engine.analyze('cot dag fug', maxIssues: 2);

      expect(report.truncated, isTrue);
      expect(ranker.targets, contains('cot'));
      expect(ranker.targets, contains('dag'));
      expect(ranker.targets, isNot(contains('fug')));
    });

    test('rejects non-positive issue caps', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});

      expect(() => engine.analyze('wrld', maxIssues: 0), throwsArgumentError);
      expect(() => engine.analyze('wrld', maxIssues: -1), throwsArgumentError);
    });

    test('exposes an immutable issue list', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});
      final report = engine.analyze('wrld', maxIssues: 1);

      expect(
        () => report.issues.add(report.issues.single),
        throwsUnsupportedError,
      );
    });
  });
}

class _RecordingRanker implements SpellSuggestionRanker {
  final Set<String> targets = <String>{};

  @override
  int compare(
    SpellSuggestionRankingContext context,
    SpellSuggestionCandidate a,
    SpellSuggestionCandidate b,
  ) {
    targets.add(context.target);
    return const DefaultSpellSuggestionRanker().compare(context, a, b);
  }
}
