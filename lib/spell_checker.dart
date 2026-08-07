class SpellIssue {
  const SpellIssue({required this.word, required this.start, required this.end});

  final String word;
  final int start;
  final int end;
}

class SpellCheckerEngine {
  SpellCheckerEngine({Set<String>? dictionary})
      : _dictionary = dictionary ?? _defaultDictionary;

  final Set<String> _dictionary;

  List<SpellIssue> check(String text) {
    final issues = <SpellIssue>[];
    final matches = RegExp(r"[A-Za-z']+").allMatches(text);

    for (final match in matches) {
      final word = match.group(0)!;
      final normalized = word.toLowerCase();
      if (!_dictionary.contains(normalized)) {
        issues.add(
          SpellIssue(word: word, start: match.start, end: match.end),
        );
      }
    }

    return issues;
  }

  bool isCorrect(String word) => _dictionary.contains(word.toLowerCase());

  static const Set<String> _defaultDictionary = {
    'a', 'about', 'after', 'all', 'also', 'an', 'and', 'are', 'as', 'at',
    'be', 'because', 'been', 'but', 'by', 'can', 'check', 'checker', 'correct',
    'day', 'do', 'document', 'each', 'english', 'for', 'from', 'good', 'had',
    'has', 'have', 'he', 'hello', 'help', 'her', 'here', 'him', 'his', 'how',
    'i', 'if', 'in', 'into', 'is', 'it', 'its', 'language', 'me', 'more',
    'my', 'new', 'no', 'not', 'of', 'on', 'one', 'open', 'or', 'our', 'project',
    'she', 'simple', 'so', 'software', 'spell', 'text', 'that', 'the', 'their',
    'them', 'there', 'they', 'this', 'to', 'use', 'was', 'we', 'were', 'what',
    'when', 'which', 'who', 'will', 'with', 'word', 'words', 'world', 'write',
    'writing', 'you', 'your'
  };
}
