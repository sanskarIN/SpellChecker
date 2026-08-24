import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android repository support', () {
    test('keeps stable identity and Flutter-managed SDK versions', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();

      expect(gradle, contains('namespace = "in.sanskar.spellchecker"'));
      expect(gradle, contains('applicationId = "in.sanskar.spellchecker"'));
      expect(gradle, contains('compileSdk = flutter.compileSdkVersion'));
      expect(gradle, contains('minSdk = flutter.minSdkVersion'));
      expect(gradle, contains('targetSdk = flutter.targetSdkVersion'));
      expect(gradle, contains('JavaVersion.VERSION_17'));
      expect(gradle, contains('JvmTarget.JVM_17'));
    });

    test('supports private production signing without committing secrets', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      final gitignore = File('android/.gitignore').readAsStringSync();
      final signingExample = File(
        'android/key.properties.example',
      ).readAsStringSync();

      expect(gradle, contains('rootProject.file("key.properties")'));
      expect(gradle, contains('hasReleaseSigning'));
      expect(gradle, contains('signingConfigs.getByName("release")'));
      expect(gradle, contains('signingConfigs.getByName("debug")'));

      for (final property in const <String>[
        'storePassword',
        'keyPassword',
        'keyAlias',
        'storeFile',
      ]) {
        expect(signingExample, contains('$property='));
      }

      expect(gitignore, contains('key.properties'));
      expect(gitignore, contains('**/*.keystore'));
      expect(gitignore, contains('**/*.jks'));
    });

    test('production manifest preserves Android privacy and navigation', () {
      final mainManifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      final debugManifest = File(
        'android/app/src/debug/AndroidManifest.xml',
      ).readAsStringSync();
      final profileManifest = File(
        'android/app/src/profile/AndroidManifest.xml',
      ).readAsStringSync();

      expect(mainManifest, contains('android:allowBackup="false"'));
      expect(
        mainManifest,
        contains('android:enableOnBackInvokedCallback="true"'),
      );
      expect(mainManifest, contains('android:supportsRtl="true"'));
      expect(mainManifest, contains('android:usesCleartextTraffic="false"'));
      expect(
        mainManifest,
        isNot(contains('android.permission.INTERNET')),
        reason: 'Production Android must stay offline by default.',
      );
      expect(debugManifest, contains('android.permission.INTERNET'));
      expect(profileManifest, contains('android.permission.INTERNET'));
    });

    test('normal and release CI validate APK and App Bundle packaging', () {
      for (final path in const <String>[
        '.github/workflows/cross-platform.yml',
        '.github/workflows/release.yml',
      ]) {
        final workflow = File(path).readAsStringSync();

        expect(
          workflow,
          contains('flutter build apk --release'),
          reason: '$path must validate Android APK packaging.',
        );
        expect(
          workflow,
          contains('flutter build appbundle --release'),
          reason: '$path must validate Android App Bundle packaging.',
        );
        expect(
          workflow,
          contains('build/app/outputs/bundle/release'),
          reason: '$path must inspect the Android App Bundle output directory.',
        );
        expect(
          workflow,
          contains('.aab'),
          reason: '$path must retain Android App Bundle artifact handling.',
        );
      }
    });

    test('tagged releases normalize Android validation artifact names', () {
      final release = File('.github/workflows/release.yml').readAsStringSync();

      expect(release, contains('Normalize Android validation asset names'));
      expect(release, contains('spellchecker-android-validation-'));
      expect(release, contains('apk_path='));
      expect(release, contains('aab_path='));
      expect(release, contains('cp "\$apk_path"'));
      expect(release, contains('cp "\$aab_path"'));
    });

    test('tagged release publishing keeps integrity safeguards', () {
      final release = File('.github/workflows/release.yml').readAsStringSync();
      final releasing = File('docs/RELEASING.md').readAsStringSync();
      final roadmap = File('docs/ROADMAP.md').readAsStringSync();

      for (final marker in const <String>[
        'publish-release:',
        "if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/v')",
        'actions/download-artifact@v8',
        'actions/attest-build-provenance@v4',
        'contents: write',
        'id-token: write',
        'attestations: write',
        'sha256sum',
        'Reject already-published release tags',
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
      ]) {
        expect(
          release,
          contains(marker),
          reason: '.github/workflows/release.yml must keep: $marker',
        );
      }

      expect(
        release,
        isNot(contains('--clobber')),
        reason: 'Published GitHub Release assets must not be silently replaced.',
      );
      expect(releasing, contains('permanent GitHub Release'));
      expect(releasing, contains('SHA-256'));
      expect(releasing, contains('build-provenance'));
      expect(
        roadmap,
        contains('Tagged release distribution hardening completed'),
      );
    });

    test('AGP 9 keeps the Flutter stable Kotlin compatibility path', () {
      final settings = File('android/settings.gradle.kts').readAsStringSync();
      final properties = File('android/gradle.properties').readAsStringSync();

      expect(settings, contains('com.android.application'));
      expect(settings, contains('org.jetbrains.kotlin.android'));
      expect(properties, contains('android.builtInKotlin=false'));
      expect(properties, contains('android.newDsl=false'));
      expect(properties, contains('android.useAndroidX=true'));
    });
  });
}
