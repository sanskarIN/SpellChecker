import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const currentVersion = '2.16.0+21';
  const builtInLanguageIds = <String>['en-US', 'en-GB'];
  const builtInRuleIds = <String>[
    'repeated-word',
    'sentence-capitalization',
    'repeated-space',
    'punctuation-spacing',
    'missing-punctuation-space',
    'trailing-whitespace',
    'repeated-punctuation',
    'unmatched-parenthesis',
    'unmatched-square-bracket',
    'unmatched-curly-brace',
  ];

  const evergreenDocs = <String>[
    'GETTING_STARTED.md',
    'FEATURES.md',
    'USER_GUIDE.md',
    'CONFIGURATION.md',
    'KEYBOARD_SHORTCUTS.md',
    'FAQ.md',
    'GLOSSARY.md',
    'EXAMPLES.md',
    'API.md',
    'LANGUAGE_PACKS.md',
    'WRITING_RULES.md',
    'ARCHITECTURE.md',
    'PLATFORM_SUPPORT.md',
    'PERFORMANCE.md',
    'PRIVACY.md',
    'ACCESSIBILITY.md',
    'DEVELOPMENT.md',
    'TESTING.md',
    'TROUBLESHOOTING.md',
    'RELEASING.md',
    'ROADMAP.md',
    'RELEASE_HISTORY.md',
    'DOCUMENTATION_MAINTENANCE.md',
  ];

  test('documentation hub links every evergreen topic', () {
    final index = File('docs/README.md').readAsStringSync();

    expect(index, contains(currentVersion));
    for (final fileName in evergreenDocs) {
      expect(
        File('docs/$fileName').existsSync(),
        isTrue,
        reason: 'docs/$fileName must exist.',
      );
      expect(
        index,
        contains('($fileName)'),
        reason: 'docs/README.md must link $fileName.',
      );
    }
  });

  test('current feature reference names every language and writing rule', () {
    final features = File('docs/FEATURES.md').readAsStringSync();

    for (final languageId in builtInLanguageIds) {
      expect(features, contains('`$languageId`'));
    }
    for (final ruleId in builtInRuleIds) {
      expect(
        features,
        contains('`$ruleId`'),
        reason: 'FEATURES.md must name current built-in rule $ruleId.',
      );
    }
  });

  test('configuration documents both current transfer formats', () {
    final configuration = File('docs/CONFIGURATION.md').readAsStringSync();

    expect(configuration, contains('`spellchecker-settings`'));
    expect(configuration, contains('Current version: `1`'));
    expect(configuration, contains('Current exports use version 2'));
  });

  test('platform support does not claim uncommitted native runners', () {
    final platformSupport = File('docs/PLATFORM_SUPPORT.md').readAsStringSync();

    expect(platformSupport, contains('Flutter web'));
    for (final directory in <String>[
      'android',
      'ios',
      'windows',
      'macos',
      'linux',
    ]) {
      expect(Directory(directory).existsSync(), isFalse);
    }
  });
}
