import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('relative Markdown documentation links resolve to committed files', () {
    final markdownFiles = Directory('docs')
        .listSync(recursive: false)
        .whereType<File>()
        .where((file) => file.path.endsWith('.md'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    final failures = <String>[];
    final linkPattern = RegExp(r'\[[^\]]*\]\(([^)]+)\)');

    for (final file in markdownFiles) {
      final source = file.readAsStringSync();
      for (final match in linkPattern.allMatches(source)) {
        var destination = match.group(1)!.trim();
        if (destination.isEmpty ||
            destination.startsWith('#') ||
            destination.startsWith('http://') ||
            destination.startsWith('https://') ||
            destination.startsWith('mailto:')) {
          continue;
        }

        destination = destination.split(RegExp(r'\s+')).first;
        if (destination.startsWith('<') && destination.endsWith('>')) {
          destination = destination.substring(1, destination.length - 1);
        }

        final fragmentIndex = destination.indexOf('#');
        final target = fragmentIndex < 0
            ? destination
            : destination.substring(0, fragmentIndex);

        if (target.isEmpty || !target.toLowerCase().endsWith('.md')) {
          continue;
        }

        final resolved = File('${file.parent.path}/$target');
        if (!resolved.existsSync()) {
          failures.add('${file.path} -> $destination');
        }
      }
    }

    expect(
      failures,
      isEmpty,
      reason: 'Broken relative Markdown links: ${failures.join(', ')}',
    );
  });
}
