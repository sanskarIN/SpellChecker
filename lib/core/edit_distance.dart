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

  final rows = sourceRunes.length + 1;
  final columns = targetRunes.length + 1;
  final matrix = List<List<int>>.generate(
    rows,
    (row) => List<int>.filled(columns, 0),
  );

  for (var row = 0; row < rows; row++) {
    matrix[row][0] = row;
  }
  for (var column = 0; column < columns; column++) {
    matrix[0][column] = column;
  }

  for (var row = 1; row < rows; row++) {
    for (var column = 1; column < columns; column++) {
      final cost = sourceRunes[row - 1] == targetRunes[column - 1] ? 0 : 1;
      final deletion = matrix[row - 1][column] + 1;
      final insertion = matrix[row][column - 1] + 1;
      final substitution = matrix[row - 1][column - 1] + cost;

      var best = _min3(deletion, insertion, substitution);

      if (row > 1 &&
          column > 1 &&
          sourceRunes[row - 1] == targetRunes[column - 2] &&
          sourceRunes[row - 2] == targetRunes[column - 1]) {
        final transposition = matrix[row - 2][column - 2] + 1;
        if (transposition < best) {
          best = transposition;
        }
      }

      matrix[row][column] = best;
    }
  }

  return matrix[sourceRunes.length][targetRunes.length];
}

int _min3(int a, int b, int c) {
  var result = a < b ? a : b;
  if (c < result) {
    result = c;
  }
  return result;
}
