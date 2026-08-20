import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Apple repository support', () {
    test('iOS keeps stable identity, devices, and deployment baseline', () {
      final project = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();
      final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(
        project,
        contains('PRODUCT_BUNDLE_IDENTIFIER = in.sanskar.spellchecker;'),
      );
      expect(project, contains('IPHONEOS_DEPLOYMENT_TARGET = 15.0;'));
      expect(project, contains('TARGETED_DEVICE_FAMILY = "1,2";'));
      expect(infoPlist, contains('<string>SpellChecker</string>'));
      expect(infoPlist, contains('$(FLUTTER_BUILD_NAME)'));
      expect(infoPlist, contains('$(FLUTTER_BUILD_NUMBER)'));
    });

    test('iOS keeps an explicit offline-first transport policy', () {
      final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(infoPlist, contains('<key>NSAppTransportSecurity</key>'));
      expect(infoPlist, contains('<key>NSAllowsArbitraryLoads</key>'));
      expect(
        infoPlist,
        isNot(contains('<key>NSAllowsArbitraryLoads</key>\n\t<true/>')),
      );
      expect(
        infoPlist,
        contains('<key>NSAllowsArbitraryLoadsInWebContent</key>'),
      );
      expect(infoPlist, contains('<key>NSAllowsLocalNetworking</key>'));
    });

    test('macOS release is sandboxed without network entitlements', () {
      final appInfo = File(
        'macos/Runner/Configs/AppInfo.xcconfig',
      ).readAsStringSync();
      final releaseEntitlements = File(
        'macos/Runner/Release.entitlements',
      ).readAsStringSync();

      expect(appInfo, contains('PRODUCT_NAME = SpellChecker'));
      expect(
        appInfo,
        contains('PRODUCT_BUNDLE_IDENTIFIER = in.sanskar.spellchecker'),
      );
      expect(releaseEntitlements, contains('com.apple.security.app-sandbox'));
      expect(releaseEntitlements, contains('<true/>'));
      expect(
        releaseEntitlements,
        isNot(contains('com.apple.security.network.client')),
      );
      expect(
        releaseEntitlements,
        isNot(contains('com.apple.security.network.server')),
      );
      expect(
        releaseEntitlements,
        isNot(contains('com.apple.security.cs.allow-jit')),
      );
    });

    test('Apple builds retain the privacy-manifest dependency contract', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final lockfile = File('pubspec.lock').readAsStringSync();

      expect(pubspec, contains('shared_preferences:'));
      expect(lockfile, contains('shared_preferences_foundation:'));
    });

    test('normal and release CI validate built Apple app metadata', () {
      for (final path in const <String>[
        '.github/workflows/cross-platform.yml',
        '.github/workflows/release.yml',
      ]) {
        final workflow = File(path).readAsStringSync();

        expect(
          workflow,
          contains('flutter build macos --release'),
          reason: '$path must validate macOS release packaging.',
        );
        expect(
          workflow,
          contains('flutter build ios --release --no-codesign'),
          reason: '$path must validate iOS release packaging without secrets.',
        );
        expect(
          workflow,
          contains('CFBundleIdentifier'),
          reason: '$path must verify the built Apple bundle identity.',
        );
        expect(
          workflow,
          contains('PrivacyInfo.xcprivacy'),
          reason: '$path must verify an Apple privacy manifest is embedded.',
        );
      }
    });
  });
}
