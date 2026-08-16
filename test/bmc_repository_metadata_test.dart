import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const buyMeACoffeeUrl = 'https://buymeacoffee.com/sanskarIN';

  test('repository keeps Buy Me a Coffee visible on support surfaces', () {
    final requiredSurfaces = <String>[
      'README.md',
      'SUPPORT.md',
      '.github/FUNDING.yml',
      '.github/ISSUE_TEMPLATE/config.yml',
    ];

    for (final path in requiredSurfaces) {
      expect(
        File(path).readAsStringSync(),
        contains(buyMeACoffeeUrl),
        reason: '$path must keep the Buy Me a Coffee URL visible.',
      );
    }
  });

  test('support documentation includes a prominent BMC image badge', () {
    final support = File('SUPPORT.md').readAsStringSync();

    expect(support, contains('Buy Me a Coffee — Support SpellChecker'));
    expect(support, contains('style=for-the-badge'));
  });
}
