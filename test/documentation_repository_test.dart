import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
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

List<File> _trackedMarkdownFiles() {
  final result = Process.runSync('git', const <String>[
    'ls-files',
    '*.md',
  ], runInShell: Platform.isWindows);
  if (result.exitCode != 0) {
    throw StateError(
      'git ls-files *.md must succeed for documentation checks.',
    );
  }
  return (result.stdout as String)
      .split(RegExp(r'\r?\n'))
      .where((path) => path.isNotEmpty)
      .map(File.new)
      .toList(growable: false);
}

String? _repositoryRelativeTarget(String destination) {
  var value = destination.trim();
  if (value.isEmpty || value.startsWith('#')) {
    return null;
  }
  if (value.startsWith('<') && value.endsWith('>')) {
    value = value.substring(1, value.length - 1);
  }

  final uri = Uri.tryParse(value);
  if (uri == null || uri.hasScheme || value.startsWith('//')) {
    return null;
  }
  if (uri.path.isEmpty) {
    return null;
  }
  return Uri.decodeComponent(uri.path);
}

void main() {
  final currentVersion = _currentPackageVersion();
  final currentReleaseVersion = currentVersion.split('+').first;
  final builtInLanguageIds = SpellLanguageRegistry.builtIns
      .map((pack) => pack.id)
      .toList(growable: false);
  final builtInRuleIds = WritingRuleRegistry.builtIns
      .map((rule) => rule.id)
      .toList(growable: false);

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

  test('repository-relative Markdown links resolve', () {
    final failures = <String>[];
    final linkPattern = RegExp(r'!?\[[^\]]*\]\(([^)]+)\)');

    for (final markdownFile in _trackedMarkdownFiles()) {
      final content = markdownFile.readAsStringSync();
      for (final match in linkPattern.allMatches(content)) {
        final destination = match.group(1)!;
        final target = _repositoryRelativeTarget(destination);
        if (target == null) {
          continue;
        }
        final resolvedPath = target.startsWith('/')
            ? target.substring(1)
            : '${markdownFile.parent.path}/$target';
        if (!File(resolvedPath).existsSync() &&
            !Directory(resolvedPath).existsSync()) {
          failures.add('${markdownFile.path} -> $destination');
        }
      }
    }

    expect(
      failures,
      isEmpty,
      reason: 'Broken repository-relative Markdown links: $failures',
    );
  });

  test(
    'tracked Markdown has H1 headings, balanced fences, and no conflicts',
    () {
      final failures = <String>[];

      for (final markdownFile in _trackedMarkdownFiles()) {
        final lines = markdownFile.readAsLinesSync();
        if (!markdownFile.path.startsWith('.github/')) {
          final h1Count = lines.where((line) => line.startsWith('# ')).length;
          if (h1Count == 0) {
            failures.add('${markdownFile.path}: expected at least one H1');
          }
        }

        final fenceCount = lines
            .where((line) => line.trimLeft().startsWith('```'))
            .length;
        if (fenceCount.isOdd) {
          failures.add('${markdownFile.path}: unbalanced fenced code block');
        }

        if (lines.any(
          (line) =>
              line.startsWith('<<<<<<< ') ||
              line == '=======' ||
              line.startsWith('>>>>>>> '),
        )) {
          failures.add(
            '${markdownFile.path}: unresolved merge conflict marker',
          );
        }
      }

      expect(failures, isEmpty, reason: 'Malformed Markdown: $failures');
    },
  );

  test('current package version stays synchronized', () {
    final expectedByPath = <String, String>{
      'README.md': '`$currentVersion`',
      'docs/README.md': '`$currentVersion`',
      'docs/GETTING_STARTED.md': '`$currentVersion`',
      'docs/EXECUTABLE_BUILDS.md': '`$currentVersion`',
      'docs/RELEASING.md': 'version: $currentVersion',
      'docs/RELEASE_HISTORY.md': 'Current package version: `$currentVersion`.',
      'lib/features/editor/spell_checker_page.dart':
          "applicationVersion: '$currentReleaseVersion'",
      'CHANGELOG.md': '## [$currentReleaseVersion] - ',
    };

    for (final entry in expectedByPath.entries) {
      final content = File(entry.key).readAsStringSync();
      expect(
        content,
        contains(entry.value),
        reason:
            '${entry.key} must reflect current package version $currentVersion.',
      );
    }
  });

  test('current guides reject known obsolete release claims', () {
    const currentGuidePaths = <String>[
      'docs/GETTING_STARTED.md',
      'docs/USER_GUIDE.md',
      'docs/DEVELOPMENT.md',
      'docs/TESTING.md',
      'docs/RELEASING.md',
      'docs/FAQ.md',
    ];
    const obsoleteMarkers = <String>[
      '2.16.0+21',
      '3.0.0+22',
      'Native runner directories and native release artifacts are not currently committed/produced.',
      'The current repository has no committed native runner directories',
      'The release workflow additionally runs `flutter build web --release`.',
      'The release workflow repeats those gates and additionally builds/uploads the web artifact.',
    ];

    final failures = <String>[];
    for (final path in currentGuidePaths) {
      final content = File(path).readAsStringSync();
      for (final marker in obsoleteMarkers) {
        if (content.contains(marker)) {
          failures.add('$path -> $marker');
        }
      }
    }

    expect(
      failures,
      isEmpty,
      reason: 'Current guides contain obsolete release claims: $failures',
    );
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

  test('current language references cover every built-in pack', () {
    const referencePaths = <String>[
      'README.md',
      'docs/README.md',
      'docs/FEATURES.md',
      'docs/LANGUAGE_PACKS.md',
      'docs/USER_GUIDE.md',
      'docs/CONFIGURATION.md',
      'docs/FAQ.md',
    ];

    for (final path in referencePaths) {
      final content = File(path).readAsStringSync();
      for (final languageId in builtInLanguageIds) {
        expect(
          content,
          contains(languageId),
          reason: '$path must name current built-in language $languageId.',
        );
      }
    }
  });

  test('current writing references cover every built-in rule', () {
    const referencePaths = <String>[
      'README.md',
      'docs/FEATURES.md',
      'docs/WRITING_RULES.md',
      'docs/USER_GUIDE.md',
    ];

    for (final path in referencePaths) {
      final content = File(path).readAsStringSync();
      for (final ruleId in builtInRuleIds) {
        expect(
          content,
          contains(ruleId),
          reason: '$path must name current built-in writing rule $ruleId.',
        );
      }
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
        reason:
            '${entry.key}/ must be committed for official platform support.',
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

  test('platform metadata stays aligned with the six-target support contract', () {
    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();
    expect(iosInfo, contains('<string>SpellChecker</string>'));
    expect(iosInfo, contains(r'$(FLUTTER_BUILD_NAME)'));
    expect(iosInfo, contains(r'$(FLUTTER_BUILD_NUMBER)'));

    final linuxConfig = File('linux/CMakeLists.txt').readAsStringSync();
    expect(linuxConfig, contains('set(BINARY_NAME "spellchecker")'));
    expect(
      linuxConfig,
      contains('set(APPLICATION_ID "in.sanskar.spellchecker")'),
    );

    final macosInfo = File(
      'macos/Runner/Configs/AppInfo.xcconfig',
    ).readAsStringSync();
    expect(macosInfo, contains('PRODUCT_NAME = SpellChecker'));
    expect(
      macosInfo,
      contains('PRODUCT_BUNDLE_IDENTIFIER = in.sanskar.spellchecker'),
    );

    final macosReleaseEntitlements = File(
      'macos/Runner/Release.entitlements',
    ).readAsStringSync();
    expect(
      macosReleaseEntitlements,
      contains('com.apple.security.app-sandbox'),
    );
    expect(
      macosReleaseEntitlements,
      isNot(contains('com.apple.security.network.client')),
    );
    expect(
      macosReleaseEntitlements,
      isNot(contains('com.apple.security.network.server')),
    );

    final windowsResource = File(
      'windows/runner/Runner.rc',
    ).readAsStringSync();
    expect(windowsResource, contains('FLUTTER_VERSION_MAJOR'));
    expect(windowsResource, contains('FLUTTER_VERSION_BUILD'));
    expect(windowsResource, contains('VALUE "ProductName", "SpellChecker"'));
    expect(
      windowsResource,
      contains('VALUE "OriginalFilename", "spellchecker.exe"'),
    );

    final webIndex = File('web/index.html').readAsStringSync();
    final webManifest = File('web/manifest.json').readAsStringSync();
    for (final content in <String>[webIndex, webManifest]) {
      expect(content, contains('SpellChecker'));
      expect(content, isNot(contains('V2.16')));
    }
    expect(webManifest, contains('"id": "."'));
    expect(webManifest, contains('"scope": "."'));
    expect(webManifest, contains('icons/Icon-192.png'));
    expect(webManifest, contains('icons/Icon-512.png'));
    expect(File('web/icons/Icon-192.png').existsSync(), isTrue);
    expect(File('web/icons/Icon-512.png').existsSync(), isTrue);

    const workflowPaths = <String>[
      '.github/workflows/cross-platform.yml',
      '.github/workflows/release.yml',
    ];
    const buildMarkers = <String>[
      'flutter build web --release',
      'flutter build apk --release',
      'flutter build appbundle --release',
      'flutter build linux --release',
      'flutter build windows --release',
      'flutter build macos --release',
      'flutter build ios --release --no-codesign',
    ];
    for (final workflowPath in workflowPaths) {
      final workflow = File(workflowPath).readAsStringSync();
      for (final marker in buildMarkers) {
        expect(
          workflow,
          contains(marker),
          reason: '$workflowPath must keep the release build step: $marker',
        );
      }
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
      'web/',
      'windows/',
    ];
    const crossPlatformControlFiles = <String>{
      '.metadata',
      '.github/workflows/platform-bootstrap.yml',
      '.github/workflows/cross-platform.yml',
      '.github/workflows/v3-docs-sync.yml',
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

    final missing =
        trackedPaths
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
