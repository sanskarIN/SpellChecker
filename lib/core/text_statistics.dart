class TextStatistics {
  const TextStatistics({
    required this.characters,
    required this.words,
    required this.sentences,
  });

  final int characters;
  final int words;
  final int sentences;

  factory TextStatistics.fromText(String text) {
    final wordMatches = RegExp(
      r"(?:\p{L}\p{M}*)+(?:['’\-‐‑](?:\p{L}\p{M}*)+)*",
      unicode: true,
    ).allMatches(text);
    final trimmed = text.trim();
    final sentenceBoundaryMatches = RegExp(r'''[.!?]+["'’”\)\]]*(?=\s|$)''')
        .allMatches(trimmed)
        .toList(growable: false);

    var sentenceCount = 0;
    if (trimmed.isNotEmpty) {
      sentenceCount = sentenceBoundaryMatches.length;
      final trailingText = sentenceBoundaryMatches.isEmpty
          ? trimmed
          : trimmed.substring(sentenceBoundaryMatches.last.end).trim();
      if (trailingText.isNotEmpty) {
        sentenceCount += 1;
      }
    }

    return TextStatistics(
      characters: text.length,
      words: wordMatches.length,
      sentences: sentenceCount,
    );
  }
}
