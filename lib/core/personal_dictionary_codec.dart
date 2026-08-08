import 'dart:convert';

class PersonalDictionaryCodec {
  const PersonalDictionaryCodec._();

  static const int currentVersion = 1;

  static String encode(Iterable<String> words) {
    final normalized = words
        .map(normalizeWord)
        .where((String word) => word.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return const JsonEncoder.withIndent('  ').convert(<String, Object>{
      'version': currentVersion,
      'words': normalized,
    });
  }

  static Set<String> decode(String source) {
    final trimmed = source.trim();
    if (trimmed.isEmpty) {
      return <String>{};
    }

    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
      return _normalizeCollection(trimmed.split(RegExp(r'[\r\n,]+')));
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException catch (error) {
      throw FormatException('The dictionary data is not valid JSON: ${error.message}');
    }

    if (decoded is List<dynamic>) {
      return _normalizeCollection(decoded);
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Dictionary data must be a JSON object, JSON array, or plain word list.');
    }

    final version = decoded['version'];
    if (version != null && version != currentVersion) {
      throw FormatException('Unsupported dictionary format version: $version.');
    }

    final words = decoded['words'];
    if (words is! List<dynamic>) {
      throw const FormatException('Dictionary JSON must contain a "words" array.');
    }

    return _normalizeCollection(words);
  }

  static String normalizeWord(Object? value) {
    if (value is! String) {
      return '';
    }

    final normalized = value.trim().toLowerCase().replaceAll('’', "'");
    if (normalized.isEmpty) {
      return '';
    }

    final valid = RegExp(r"^[a-z]+(?:['-][a-z]+)*$").hasMatch(normalized);
    return valid ? normalized : '';
  }

  static Set<String> _normalizeCollection(Iterable<dynamic> values) {
    final result = <String>{};
    final invalid = <Object?>[];

    for (final value in values) {
      final normalized = normalizeWord(value);
      if (normalized.isEmpty) {
        if (value is String && value.trim().isEmpty) {
          continue;
        }
        invalid.add(value);
        continue;
      }
      result.add(normalized);
    }

    if (invalid.isNotEmpty) {
      throw FormatException('Dictionary contains invalid word entries: ${invalid.take(3).join(', ')}.');
    }

    return result;
  }
}
