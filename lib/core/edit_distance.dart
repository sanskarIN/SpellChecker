int damerauLevenshteinDistance(String source, String target) {
  if (source == target) {
    return 0;
  }
  if (source.isEmpty) {
    return target.length;
  }
  if (target.isEmpty) {
    return source.length;
  }

  final rows = source.length + 1;
  final columns = target.length + 1;
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
      final cost = source[row - 1] == target[column - 1] ? 0 : 1;
      final deletion = matrix[row - 1][column] + 1;
      final insertion = matrix[row][column - 1] + 1;
      final substitution = matrix[row - 1][column - 1] + cost;

      var best = _min3(deletion, insertion, substitution);

      if (row > 1 &&
          column > 1 &&
          source[row - 1] == target[column - 2] &&
          source[row - 2] == target[column - 1]) {
        final transposition = matrix[row - 2][column - 2] + 1;
        if (transposition < best) {
          best = transposition;
        }
      }

      matrix[row][column] = best;
    }
  }

  return matrix[source.length][target.length];
}

int _min3(int a, int b, int c) {
  var result = a < b ? a : b;
  if (c < result) {
    result = c;
  }
  return result;
}
