# Platform Support

This page distinguishes **portable Flutter source**, **committed platform runners**, **automated target builds**, and **distribution-ready signed artifacts**. Those are different support levels and should not be conflated.

For build commands, packaging, signing boundaries, artifact verification, troubleshooting, and release procedures, see [Executable builds and packaging](EXECUTABLE_BUILDS.md). Android-specific setup, signing, Play packaging, privacy, and device-testing guidance is in [Android support](../android/README.md).

## Current V3 repository state

The V3 cross-platform foundation commits official Flutter runners for:

- Android;
- iOS;
- Linux desktop;
- macOS;
- Web;
- Windows.

The application package/bundle identity is based on `in.sanskar.spellchecker` where the platform uses reverse-domain application identifiers. User-facing application branding is `SpellChecker`.

The runners were generated with Flutter stable and are tracked by the repository `.metadata` file so future Flutter migrations can reason about their template origin.

## Support matrix

| Target | Portable source | Runner committed | Automated release-mode build | CI artifact | Store/distribution signing |
| --- | --- | --- | --- | --- | --- |
| Web | yes | yes | yes + Chrome widget smoke | yes | not applicable |
| Android | yes | yes | yes, APK + AAB | yes | production signing path supported; private upload key remains external |
| iOS | yes | yes | yes, `--no-codesign` | yes, permission-preserving archive | Apple signing/provisioning still required |
| Linux desktop | yes | yes | yes | yes, permission-preserving archive | packaging policy remains distribution-specific |
| macOS | yes | yes | yes | yes, permission-preserving archive | signing/notarization still required for public distribution |
| Windows | yes | yes | yes | yes | optional/required code signing depends on distribution channel |

The cross-platform CI workflow is `.github/workflows/cross-platform.yml`. It runs source quality gates once and then validates every target on the operating system required by Flutter.

## What cross-platform CI validates

The workflow first runs on Ubuntu:

```text
flutter pub get
dart format lib test tool + clean-diff check
flutter analyze
flutter test --reporter expanded
benchmark CLI smoke
```

After the common quality job succeeds, target jobs run in parallel:

```text
Web      ubuntu-latest   flutter test --platform chrome test/widget_test.dart
                         flutter build web --release
Android  ubuntu-latest   flutter build apk --release
                         flutter build appbundle --release
Linux    ubuntu-latest   flutter build linux --release
Windows  windows-latest  flutter build windows --release
macOS    macos-latest    flutter build macos --release
iOS      macos-latest    flutter build ios --release --no-codesign
```

The Web job runs the existing app-level widget workflow in Chrome before packaging, then verifies that the built install shell contains its manifest and required install icons. This complements the normal Flutter VM widget suite with a browser-runtime smoke path.

The Android job also checks the production manifest privacy boundary before packaging: cloud backup and cleartext traffic must remain disabled, and the main manifest must not request the Internet permission.

Linux, macOS, and iOS jobs wrap their native output in `.tar.gz` archives before GitHub artifact upload. This preserves Unix executable permission bits and native bundle structure across artifact transport. Windows, Web, APK, and AAB outputs use their existing directory/file packaging because they do not require the same Unix permission preservation.

Each build uploads a short-lived GitHub Actions artifact so build output can be inspected. These CI artifacts prove buildability and repository packaging compatibility; they are not automatically permanent GitHub Releases or store-ready signed packages.

## Local run/build commands

Resolve dependencies first:

```bash
flutter pub get
```

Then use the target supported by the current development machine.

### Web

```bash
flutter run -d chrome
flutter test --platform chrome test/widget_test.dart
flutter build web --release
```

### Android

```bash
flutter run -d <android-device-id>
flutter build apk --release
flutter build appbundle --release
```

The Android runner uses `flutter.compileSdkVersion`, `flutter.targetSdkVersion`, and `flutter.minSdkVersion` so it follows Flutter stable's supported Android SDK baseline. Current Flutter stable targets Android 16 / API 36, matching the Google Play target requirement that takes effect on August 31, 2026.

For a production-signed Android artifact, create private `android/key.properties` from `android/key.properties.example` and point it at the private upload keystore. The repository ignores `key.properties`, `*.jks`, and `*.keystore` files. When release credentials are absent, CI/local release-mode validation uses the generated debug key only to prove buildability; that validation artifact is not a store release.

See [Android support](../android/README.md) for the complete Android contract.

### iOS

Requires macOS/Xcode:

```bash
flutter run -d <ios-device-or-simulator-id>
flutter build ios --release --no-codesign
```

A distributable iOS package requires Apple signing/provisioning outside the repository.

### Linux

```bash
flutter run -d linux
flutter build linux --release
```

### macOS

```bash
flutter run -d macos
flutter build macos --release
```

### Windows

```powershell
flutter run -d windows
flutter build windows --release
```

Use `flutter doctor -v` to verify the platform toolchain before diagnosing project code.

## Application identity

The native foundation intentionally separates stable machine identity from presentation branding.

- Reverse-domain application identity: `in.sanskar.spellchecker` where applicable.
- Android launcher label: `SpellChecker`.
- iOS display/bundle name: `SpellChecker`.
- Linux window title: `SpellChecker`.
- macOS product name: `SpellChecker`.
- Windows product/file description: `SpellChecker` while the executable filename remains stable as `spellchecker.exe`.
- Web application/install name: `SpellChecker`, with committed manifest icons, Apple touch icon metadata, and an explicit browser favicon.

Changing package/bundle identifiers later can break upgrades, preference continuity, store identity, deep links, or signing configuration. Treat such changes as migrations rather than cosmetic edits.

## Storage behavior by platform

The application uses `shared_preferences` as its local preference abstraction. Its physical backing store is platform/plugin-specific. SpellChecker treats it as local preference storage for selected language, suggestion count, per-language personal words, and per-language writing-rule overrides.

On Android, the production manifest explicitly disables Android cloud backup because shared preferences are normally eligible for Auto Backup. Direct device-to-device migration can still be controlled by Android/device-manufacturer behavior on modern Android versions. See [Privacy](PRIVACY.md) and [Android support](../android/README.md).

Do not rely on physical preference file/registry locations as part of the public SpellChecker API.

Before clearing browser/site/app data, export personal vocabulary and copy Portable settings if they are important.

## Clipboard behavior

The application uses Flutter clipboard APIs only for explicit user actions such as:

- copying personal-dictionary export JSON;
- copying Portable settings JSON;
- copying the privacy-safe Writing insights diagnostic summary.

Clipboard access can be affected by host platform, browser, sandbox, enterprise, or permission policies. SpellChecker does not automatically copy editor text.

## Keyboard behavior

SpellChecker registers Control and Meta variants for primary editor actions where appropriate:

- `Ctrl+Enter` / `Command+Enter` — spelling check;
- `Ctrl+Shift+Enter` / `Command+Shift+Enter` — Writing insights;
- `Ctrl+F` / `Command+F` inside Writing insights — focus search.

`F7`, `Shift+F7`, and Escape may also be intercepted by browser/OS/window-manager shortcuts. See [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md).

On Android phones/tablets, the same editor and review actions remain available through the touch UI even when a hardware keyboard is not attached.

## Accessibility

The shared Flutter UI uses the same semantic and keyboard contracts across targets, but native accessibility stacks differ. Automated build success does not replace manual checks with TalkBack, VoiceOver, Narrator, Orca, browser screen readers, high-contrast modes, large text, keyboard-only operation, and platform focus conventions.

Android release candidates should include TalkBack, large-font/display-scaling, soft-keyboard, rotation/window-resize, and back-navigation checks on representative devices/emulators.

See [Accessibility](ACCESSIBILITY.md) for the project-wide contract.

## Signing and distribution boundary

Cross-platform source and CI builds do **not** mean private signing credentials belong in Git.

Never commit:

- Android keystores or passwords;
- Apple signing certificates/private keys;
- Apple provisioning profiles containing sensitive distribution data;
- store API secrets;
- Windows/macOS code-signing private keys;
- notarization credentials.

Android is configured to consume a private upload keystore through ignored `android/key.properties`. Public CI deliberately uses non-production signing when credentials are absent so it can validate APK and AAB packaging without exposing secrets.

Unsigned/no-codesign CI is intentional where production credentials are unnecessary to prove that source compiles.

## Release support versus repository support

Use these terms precisely:

- **Repository-supported target** — runner files, build instructions, and automated build validation exist.
- **CI-artifact target** — CI uploads a successful build output for inspection.
- **Distribution-supported target** — signing, packaging, permanent release assets, and distribution procedures have also been completed for that channel.

V3 establishes repository-supported and CI-artifact coverage across Android, iOS, Linux, macOS, Web, and Windows. Android additionally has a committed production-signing configuration path and Play-compatible AAB build path, while the actual private upload key and Play Console release action remain external security/store operations.

## Regression protection

`test/documentation_repository_test.dart` positively requires all six Flutter target directories and representative runner files to remain committed. It also verifies that `.metadata` tracks every supported platform and protects representative platform identity/version/build workflow metadata.

Generated Flutter runner trees are treated as managed platform roots by the executable-documentation inventory check, while project-owned source, tests, workflows, and documentation remain explicitly controlled.

The Web job adds browser-runtime and install-shell regression protection. The Android CI job adds target-specific regression protection by checking production manifest privacy flags and compiling both APK and AAB release artifacts. Native Unix/Apple packaging steps fail before upload if their expected bundle/app cannot be located or archived.

## Related documentation

- [Android support](../android/README.md)
- [Getting started](GETTING_STARTED.md)
- [Development](DEVELOPMENT.md)
- [Testing](TESTING.md)
- [Executable builds and packaging](EXECUTABLE_BUILDS.md)
- [Releasing](RELEASING.md)
- [Privacy](PRIVACY.md)
- [Accessibility](ACCESSIBILITY.md)
- [Security](../SECURITY.md)
