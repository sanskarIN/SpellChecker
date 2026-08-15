import 'dart:convert';

import 'spell_language_pack.dart';

/// Versioned, non-document SpellChecker preferences suitable for copy/paste
/// transfer between installations.
///
/// The document deliberately excludes editor text, personal vocabulary,
/// ignored session words, findings, and correction history.
class SpellCheckerSettingsDocument {
  SpellCheckerSettingsDocument({
    required this.languageId,
    required this.suggestionLimit,
    Map<String, Iterable<String>> writingRuleOverrides =
        const <String, Iterable<String>>{},
  }) : writingRuleOverrides = Map<String, Set<String>>.unmodifiable(
         <String, Set<String>>{
           for (final entry in writingRuleOverrides.entries)
             entry.key: Set<String>.unmodifiable(entry.value),
         },
       );

  final String languageId;
  final int suggestionLimit;

  /// Explicit per-language writing-rule overrides only.
  ///
  /// An absent language key means "unset; use registry defaults". A present
  /// key whose set is empty means "explicitly disable all writing rules".
  final Map<String, Set<String>> writingRuleOverrides;

  bool hasWritingRuleOverride(String languageId) {
    return writingRuleOverrides.containsKey(languageId);
  }

  Set<String>? writingRuleIdsFor(String languageId) {
    return writingRuleOverrides[languageId];
  }
}

class SpellCheckerSettingsCodec {
  const SpellCheckerSettingsCodec._();

  static const String format = 'spellchecker-settings';
  static const int version = 1;
  static const int minSuggestionLimit = 1;
  static const int maxSuggestionLimit = 10;

  static final RegExp _ruleIdPattern = RegExp(
    r'^[a-z][a-z0-9]*(?:[-._][a-z0-9]+)*$',
  );

  static String encode(SpellCheckerSettingsDocument document) {
    _validateLanguageId(document.languageId, fieldName: 'languageId');
    _validateSuggestionLimit(document.suggestionLimit);

    final sortedLanguageIds = document.writingRuleOverrides.keys.toList()
      ..sort();
    final overrides = <String, List<String>>{};
    for (final languageId in sortedLanguageIds) {
      _validateLanguageId(
        languageId,
        fieldName: 'writingRuleOverrides language',
      );
      final ruleIds = document.writingRuleOverrides[languageId]!.toList()
        ..sort();
      for (final ruleId in ruleIds) {
        _validateRuleId(ruleId);
      }
      overrides[languageId] = ruleIds;
    }

    return const JsonEncoder.withIndent('  ').convert(<String, Object>{
      'format': format,
      'version': version,
      'languageId': document.languageId,
      'suggestionLimit': document.suggestionLimit,
      'writingRuleOverrides': overrides,
    });
  }

  static SpellCheckerSettingsDocument decode(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException('Settings JSON is invalid: ${error.message}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Settings document must be a JSON object.');
    }

    if (decoded['format'] != format) {
      throw const FormatException('Unsupported settings document format.');
    }
    if (decoded['version'] != version) {
      throw FormatException(
        'Unsupported settings document version: ${decoded['version']}.',
      );
    }

    final languageId = decoded['languageId'];
    if (languageId is! String) {
      throw const FormatException('languageId must be a string.');
    }
    _validateLanguageId(languageId, fieldName: 'languageId');

    final suggestionLimit = decoded['suggestionLimit'];
    if (suggestionLimit is! int) {
      throw const FormatException('suggestionLimit must be an integer.');
    }
    _validateSuggestionLimit(suggestionLimit);

    final rawOverrides = decoded['writingRuleOverrides'];
    if (rawOverrides is! Map<String, dynamic>) {
      throw const FormatException('writingRuleOverrides must be an object.');
    }

    final overrides = <String, Iterable<String>>{};
    for (final entry in rawOverrides.entries) {
      _validateLanguageId(
        entry.key,
        fieldName: 'writingRuleOverrides language',
      );
      final rawRuleIds = entry.value;
      if (rawRuleIds is! List<dynamic>) {
        throw FormatException(
          'writingRuleOverrides.${entry.key} must be an array.',
        );
      }

      final ruleIds = <String>{};
      for (final value in rawRuleIds) {
        if (value is! String) {
          throw FormatException(
            'writingRuleOverrides.${entry.key} must contain only rule IDs.',
          );
        }
        _validateRuleId(value);
        ruleIds.add(value);
      }
      overrides[entry.key] = ruleIds;
    }

    return SpellCheckerSettingsDocument(
      languageId: languageId,
      suggestionLimit: suggestionLimit,
      writingRuleOverrides: overrides,
    );
  }

  static void _validateLanguageId(
    String languageId, {
    required String fieldName,
  }) {
    if (!SpellLanguageRegistry.contains(languageId)) {
      throw FormatException('$fieldName is unsupported: $languageId.');
    }
  }

  static void _validateSuggestionLimit(int value) {
    if (value < minSuggestionLimit || value > maxSuggestionLimit) {
      throw const FormatException(
        'suggestionLimit must be between $minSuggestionLimit and '
        '$maxSuggestionLimit.',
      );
    }
  }

  static void _validateRuleId(String value) {
    if (value != value.trim() || !_ruleIdPattern.hasMatch(value)) {
      throw FormatException('Invalid writing-rule ID: $value.');
    }
  }
}
