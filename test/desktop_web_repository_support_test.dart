import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

({int width, int height}) _pngDimensions(String path) {
  final bytes = File(path).readAsBytesSync();
  const signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];

  expect(
    bytes.length,
    greaterThanOrEqualTo(24),
    reason: '$path must contain a complete PNG header.',
  );
  expect(
    bytes.take(signature.length).toList(growable: false),
    signature,
    reason: '$path must be a PNG file.',
  );
  expect(
    ascii.decode(bytes.sublist(12, 16)),
    'IHDR',
    reason: '$path must start with the PNG IHDR chunk.',
  );

  final data = ByteData.sublistView(bytes);
  return (
    width: data.getUint32(16, Endian.big),
    height: data.getUint32(20, Endian.big),
  );
}

void main() {
  group('Desktop and Web repository support', () {
    test('Web install manifest is structurally stable and icons are valid', () {
      final manifest = jsonDecode(File('web/manifest.json').readAsStringSync());
      expect(manifest, isA<Map<String, dynamic>>());
      final map = manifest as Map<String, dynamic>;

      expect(map['name'], 'SpellChecker');
      expect(map['short_name'], 'SpellChecker');
      expect(map['id'], '.');
      expect(map['start_url'], '.');
      expect(map['scope'], '.');
      expect(map['display'], 'standalone');
      expect(map['orientation'], 'any');
      expect(map['lang'], 'en');
      expect(map['categories'], containsAll(<String>['productivity', 'utilities']));

      final icons = (map['icons'] as List<dynamic>).cast<Map<String, dynamic>>();
      final expected = <String, int>{
        'icons/Icon-192.png': 192,
        'icons/Icon-512.png': 512,
      };
      for (final entry in expected.entries) {
        final icon = icons.singleWhere((item) => item['src'] == entry.key);
        expect(icon['sizes'], '${entry.value}x${entry.value}');
        expect(icon['type'], 'image/png');
        expect(icon['purpose'], contains('maskable'));

        final dimensions = _pngDimensions('web/${entry.key}');
        expect(dimensions.width, entry.value);
        expect(dimensions.height, entry.value);
      }
    });

    test('Linux keeps stable identity, relocatable runtime, and strict build flags', () {
      final cmake = File('linux/CMakeLists.txt').readAsStringSync();
      final runner = File('linux/runner/my_application.cc').readAsStringSync();

      expect(cmake, contains('set(BINARY_NAME "spellchecker")'));
      expect(cmake, contains('set(APPLICATION_ID "in.sanskar.spellchecker")'));
      expect(cmake, contains('target_compile_features(\${TARGET} PUBLIC cxx_std_14)'));
      expect(cmake, contains('target_compile_options(\${TARGET} PRIVATE -Wall -Werror)'));
      expect(cmake, contains(r'set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")'));
      expect(runner, contains('gtk_header_bar_set_title(header_bar, "SpellChecker")'));
      expect(runner, contains('gtk_window_set_title(window, "SpellChecker")'));
      expect(runner, contains('g_set_prgname(APPLICATION_ID)'));
      expect(runner, contains('"application-id", APPLICATION_ID'));
    });

    test('Windows keeps stable executable identity and strict native metadata', () {
      final cmake = File('windows/CMakeLists.txt').readAsStringSync();
      final resource = File('windows/runner/Runner.rc').readAsStringSync();

      expect(cmake, contains('project(spellchecker LANGUAGES CXX)'));
      expect(cmake, contains('set(BINARY_NAME "spellchecker")'));
      expect(cmake, contains('target_compile_features(\${TARGET} PUBLIC cxx_std_17)'));
      expect(cmake, contains('target_compile_options(\${TARGET} PRIVATE /W4 /WX'));
      expect(resource, contains('FLUTTER_VERSION_MAJOR'));
      expect(resource, contains('FLUTTER_VERSION_BUILD'));
      expect(resource, contains('VALUE "CompanyName", "Sanskar"'));
      expect(resource, contains('VALUE "FileDescription", "SpellChecker"'));
      expect(resource, contains('VALUE "OriginalFilename", "spellchecker.exe"'));
      expect(resource, contains('VALUE "ProductName", "SpellChecker"'));
      expect(resource, contains('resources\\\\app_icon.ico'));
      expect(File('windows/runner/resources/app_icon.ico').existsSync(), isTrue);
    });

    test('normal and release CI validate built Web and desktop artifacts', () {
      for (final path in const <String>[
        '.github/workflows/cross-platform.yml',
        '.github/workflows/release.yml',
      ]) {
        final workflow = File(path).readAsStringSync();

        for (final marker in const <String>[
          'flutter_bootstrap.js',
          'main.dart.js',
          'Verify Linux release bundle contents',
          'ldd "$binary_path"',
          'Verify Windows release bundle metadata',
          'VersionInfo',
          'spellchecker.exe',
          'flutter_windows.dll',
        ]) {
          expect(
            workflow,
            contains(marker),
            reason: '$path must retain artifact validation marker: $marker',
          );
        }
      }
    });
  });
}
