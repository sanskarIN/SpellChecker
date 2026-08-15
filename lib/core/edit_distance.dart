int damerauLevenshteinDistance(String source, String target) {
  if (source == target) {
    return 0;
  }

  final sourceRunes = source.runes.toList(growable: false);
  final targetRunes = target.runes.toList(growable: false);
  if (sourceRunes.isEmpty) {
    return targetRunes.length;
  }
  if (targetRunes.isEmpty) {
    return sourceRunes.length;
  }

  final sourceLength = sourceRunes.length;
  final targetLength = targetRunes.length;
  final maximumDistance = sourceLength + targetLength;
  final matrix = List<List<int>>.generate(
    sourceLength + 2,
    (_) => List<int>.filled(targetLength + 2, 0),
  );

  matrix[0][0] = maximumDistance;
  for (var row = 0; row <= sourceLength; row++) {
    matrix[row + 1][0] = maximumDistance;
    matrix[row + 1][1] = row;
  }
  for (var column = 0; column <= targetLength; column++) {
    matrix[0][column + 1] = maximumDistance;
    matrix[1][column + 1] = column;
  }

  final lastSourceRowByRune = <int, int>{};
  for (var row = 1; row <= sourceLength; row++) {
    var lastMatchingTargetColumn = 0;
    final sourceRune = sourceRunes[row - 1];

    for (var column = 1; column <= targetLength; column++) {
      final targetRune = targetRunes[column - 1];
      final previousSourceRow = lastSourceRowByRune[targetRune] ?? 0;
      final previousTargetColumn = lastMatchingTargetColumn;

      var substitutionCost = 1;
      if (sourceRune == targetRune) {
        substitutionCost = 0;
        lastMatchingTargetColumn = column;
      }

      final substitution = matrix[row][column] + substitutionCost;
      final insertion = matrix[row + 1][column] + 1;
      final deletion = matrix[row][column + 1] + 1;
      final transposition =
          matrix[previousSourceRow][previousTargetColumn] +
          (row - previousSourceRow - 1) +
          1 +
          (column - previousTargetColumn - 1);

      matrix[row + 1][column + 1] = _min4(
        substitution,
        insertion,
        deletion,
        transposition,
      );
    }

    lastSourceRowByRune[sourceRune] = row;
  }

  return matrix[sourceLength + 1][targetLength + 1];
}

int _min4(int a, int b, int c, int d) {
  var result = a < b ? a : b;
  if (c < result) {
    result = c;
  }
  if (d < result) {
    result = d;
  }
  return result;
}
