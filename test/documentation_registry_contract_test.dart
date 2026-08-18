import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  test('feature reference follows the live language and rule registries', () {
    final features = File('docs/FEATURES.md').readAsStringSync();

    for (final pack in SpellLanguageRegistry.builtIns) {
      expect(
        features,
        contains('`${pack.id}`'),
        reason: 'FEATURES.md must name built-in language ${pack.id}.',
      );
    }

    for (final rule in WritingRuleRegistry.builtIns) {
      expect(
        features,
        contains('`${rule.id}`'),
        reason: 'FEATURES.md must name built-in rule ${rule.id}.',
      );
    }
  });

  test('language-pack reference follows the live language registry', () {
    final languagePacks = File('docs/LANGUAGE_PACKS.md').readAsStringSync();

    for (final pack in SpellLanguageRegistry.builtIns) {
      expect(
        languagePacks,
        contains('`${pack.id}`'),
        reason: 'LANGUAGE_PACKS.md must name built-in language ${pack.id}.',
      );
    }
  });

  test('writing-rule reference follows the live writing registry', () {
    final writingRules = File('docs/WRITING_RULES.md').readAsStringSync();

    for (final rule in WritingRuleRegistry.builtIns) {
      expect(
        writingRules,
        contains('`${rule.id}`'),
        reason: 'WRITING_RULES.md must name built-in rule ${rule.id}.',
      );
    }
  });
}
