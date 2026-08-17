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
    'EXECUTABLE_BUILDS.md',
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

  test('all official Flutter platform runners are committed', () {
    const platformAnchors = <String, String>{
      'android': 'android/app/src/main/AndroidManifest.xml',
      'ios': 'ios/Runner.xcodeproj/project.pbxproj',
      'linux': 'linux/CMakeLists.txt',
      'macos': 'macos/Runner.xcodeproj/project.pbxproj',
      'web': 'web/index.html',
      'windows': 'windows/CMakeLists.txt',
    };

    for (final entry in platformAnchors.entries) {
      expect(
        Directory(entry.key).existsSync(),
        isTrue,
        reason: '${entry.key}/ must be committed for official platform support.',
      );
      expect(
        File(entry.value).existsSync(),
        isTrue,
        reason: '${entry.value} must exist for the ${entry.key} runner.',
      );
    }

    final metadata = File('.metadata').readAsStringSync();
    for (final platform in platformAnchors.keys) {
      expect(
        metadata,
        contains('platform: $platform'),
        reason: '.metadata must track the $platform Flutter runner.',
      );
    }
  });

  test('executable build guide accounts for repository-controlled files', () {
    const startMarker = '<!-- tracked-file-inventory:start -->';
    const endMarker = '<!-- tracked-file-inventory:end -->';
    const generatedPlatformRoots = <String>[
      'android/',
      'ios/',
      'linux/',
      'macos/',
      'windows/',
    ];
    const crossPlatformControlFiles = <String>{
      '.metadata',
      '.github/workflows/platform-bootstrap.yml',
      '.github/workflows/cross-platform.yml',
    };

    final guide = File('docs/EXECUTABLE_BUILDS.md').readAsStringSync();
    final start = guide.indexOf(startMarker);
    final end = guide.indexOf(endMarker);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final inventory = guide.substring(start + startMarker.length, end);
    final inventoryPathPattern = RegExp(r'^- `([^`]+)`$', multiLine: true);
    final documentedPaths = <String>{};
    for (final match in inventoryPathPattern.allMatches(inventory)) {
      documentedPaths.add(match.group(1)!);
    }

    final gitResult = Process.runSync('git', const [
      'ls-files',
    ], runInShell: Platform.isWindows);
    expect(
      gitResult.exitCode,
      0,
      reason: 'git ls-files must succeed for repository documentation checks.',
    );

    final trackedOutput = gitResult.stdout as String;
    final trackedPaths = <String>{};
    for (final path in trackedOutput.split(RegExp(r'\r?\n'))) {
      if (path.isNotEmpty) {
        trackedPaths.add(path);
      }
    }

    bool isGeneratedPlatformFile(String path) {
      return generatedPlatformRoots.any(path.startsWith);
    }

    final missing = trackedPaths
        .where(
          (path) =>
              !documentedPaths.contains(path) &&
              !isGeneratedPlatformFile(path) &&
              !crossPlatformControlFiles.contains(path),
        )
        .toList()
      ..sort();
    final stale = documentedPaths.difference(trackedPaths).toList()..sort();

    expect(
      missing,
      isEmpty,
      reason: 'EXECUTABLE_BUILDS.md is missing tracked files: $missing',
    );
    expect(
      stale,
      isEmpty,
      reason: 'EXECUTABLE_BUILDS.md lists files not tracked by Git: $stale',
    );
  });
}
