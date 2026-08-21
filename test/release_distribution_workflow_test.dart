import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tagged release workflow publishes verifiable permanent assets', () {
    final workflow = File(
      '.github/workflows/release.yml',
    ).readAsStringSync();

    const requiredMarkers = <String>[
      "github.event_name == 'push' && startsWith(github.ref, 'refs/tags/v')",
      'actions/download-artifact@v8',
      'actions/attest-build-provenance@v4',
      'contents: write',
      'id-token: write',
      'attestations: write',
      'sha256sum',
      'gh release create',
      '--verify-tag',
      '--generate-notes',
      'spellchecker-web-',
      'spellchecker-android-validation-',
      'spellchecker-linux-',
      'spellchecker-windows-',
      'spellchecker-macos-unsigned-',
      'spellchecker-ios-no-codesign-',
      'SHA256SUMS.txt',
    ];

    for (final marker in requiredMarkers) {
      expect(
        workflow,
        contains(marker),
        reason: '.github/workflows/release.yml must keep: $marker',
      );
    }
  });

  test('manual release-candidate runs do not publish GitHub Releases', () {
    final workflow = File(
      '.github/workflows/release.yml',
    ).readAsStringSync();

    expect(workflow, contains('workflow_dispatch:'));
    expect(
      workflow,
      contains(
        "if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/v')",
      ),
    );
  });

  test('release asset names preserve signing and validation boundaries', () {
    final workflow = File(
      '.github/workflows/release.yml',
    ).readAsStringSync();

    expect(workflow, contains('android-validation'));
    expect(workflow, contains('macos-unsigned'));
    expect(workflow, contains('ios-no-codesign'));
    expect(
      workflow,
      contains('CI validation builds that use the repository fallback signing path'),
    );
  });
}
