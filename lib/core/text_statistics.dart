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
      r"[A-Za-z]+(?:['’-][A-Za-z]+)*",
    ).allMatches(text);
    final sentenceMatches = RegExp(r'[.!?]+(?:\s|$)').allMatches(text.trim());

    return TextStatistics(
      characters: text.length,
      words: wordMatches.length,
      sentences: text.trim().isEmpty
          ? 0
          : (sentenceMatches.isEmpty ? 1 : sentenceMatches.length),
    );
  }
}
