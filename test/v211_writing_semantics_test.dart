import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/features/editor/writing_insights_dialog.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

String _currentPackageVersion() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final match = RegExp(
    r'^version:\s*(\S+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec);
  if (match == null) {
    throw StateError('pubspec.yaml must declare a package version.');
  }
  return match.group(1)!;
}

void main() {
  final analyzer = WritingAnalyzer();
  final enabledRuleIds = analyzer.rules.map((rule) => rule.id).toSet();
  final supportedRuleCount = analyzer.rules
      .where((rule) => rule.supports(SpellLanguageRegistry.englishUs))
      .length;

  Future<void> scrollUntilBuilt(WidgetTester tester, Finder finder) async {
    final insightsList = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(ListView),
    );
    expect(insightsList, findsOneWidget);

    for (var index = 0; index < 8 && finder.evaluate().isEmpty; index++) {
      await tester.drag(insightsList, const Offset(0, -260));
      await tester.pumpAndSettle();
    }
    expect(finder, findsOneWidget);
  }

  test(
    'accessibility guide stays aligned with the current release contract',
    () {
      final accessibility = File('docs/ACCESSIBILITY.md').readAsStringSync();
      final currentVersion = _currentPackageVersion();

      expect(accessibility, contains('`$currentVersion`'));
      expect(accessibility, isNot(contains('`2.16.0+21`')));
      expect(
        accessibility,
        contains(
          'Android, iOS, Linux, macOS, Web, and Windows runners are committed '
          'and release-build validated.',
        ),
      );
      expect(
        accessibility,
        isNot(contains('Only the web host is committed/release-built.')),
      );
    },
  );

  test('Writing insights rejects a non-positive issue limit at runtime', () {
    expect(
      () => WritingInsightsDialog(
        text: 'hello world',
        languagePack: SpellLanguageRegistry.englishUs,
        analyzer: analyzer,
        initialEnabledRuleIds: enabledRuleIds,
        maxIssues: 0,
      ),
      throwsArgumentError,
    );
  });

  testWidgets('limited Writing insights exposes live exact count semantics', (
    WidgetTester tester,
  ) async {
    const text = 'hello  world world!! hello  world world!!';
    final expected = analyzer.analyze(
      text,
      languagePack: SpellLanguageRegistry.englishUs,
      enabledRuleIds: enabledRuleIds,
      maxIssues: 1,
    );
    expect(expected.isTruncated, isTrue);
    expect(expected.totalIssueCount, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WritingInsightsDialog(
            text: text,
            languagePack: SpellLanguageRegistry.englishUs,
            analyzer: analyzer,
            initialEnabledRuleIds: enabledRuleIds,
            maxIssues: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final ruleCountFinder = find.byKey(
      const ValueKey<String>('writing-rules-visible-count'),
    );
    await scrollUntilBuilt(tester, ruleCountFinder);
    final ruleCount = tester.widget<Semantics>(ruleCountFinder);
    expect(ruleCount.properties.liveRegion, isTrue);
    expect(
      ruleCount.properties.label,
      '$supportedRuleCount visible rules of $supportedRuleCount',
    );

    final findingCountFinder = find.byKey(
      const ValueKey<String>('writing-findings-visible-count'),
    );
    await scrollUntilBuilt(tester, findingCountFinder);
    final findingCount = tester.widget<Semantics>(findingCountFinder);
    expect(findingCount.properties.liveRegion, isTrue);
    expect(
      findingCount.properties.label,
      '1 visible findings. 1 captured of ${expected.totalIssueCount} total findings.',
    );
  });

  testWidgets('filtering updates live rule and finding count semantics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WritingInsightsDialog(
            text: 'hello  world world!!',
            languagePack: SpellLanguageRegistry.englishUs,
            analyzer: analyzer,
            initialEnabledRuleIds: enabledRuleIds,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final search = find.byKey(const ValueKey<String>('writing-review-search'));
    await tester.enterText(search, 'clarity');
    await tester.pumpAndSettle();

    final ruleCountFinder = find.byKey(
      const ValueKey<String>('writing-rules-visible-count'),
    );
    await scrollUntilBuilt(tester, ruleCountFinder);
    final ruleCount = tester.widget<Semantics>(ruleCountFinder);
    expect(
      ruleCount.properties.label,
      '1 visible rules of $supportedRuleCount',
    );

    final findingCountFinder = find.byKey(
      const ValueKey<String>('writing-findings-visible-count'),
    );
    await scrollUntilBuilt(tester, findingCountFinder);
    final findingCount = tester.widget<Semantics>(findingCountFinder);
    expect(findingCount.properties.label, contains('visible findings'));
    expect(findingCount.properties.liveRegion, isTrue);
  });
}
