# Android Support

SpellChecker treats Android as a first-class Flutter target. The committed runner uses the stable application ID `in.sanskar.spellchecker`, Flutter's supported Android SDK defaults, Java 17, AGP 9, AndroidX, release-mode CI builds, and a production signing path that keeps private credentials out of Git.

## Current Android baseline

- Application ID: `in.sanskar.spellchecker`
- Display name: `SpellChecker`
- Flutter embedding: v2
- Java bytecode target: 17
- Kotlin JVM target: 17
- AndroidX: enabled
- Compile SDK: `flutter.compileSdkVersion`
- Target SDK: `flutter.targetSdkVersion`
- Minimum SDK: `flutter.minSdkVersion`
- Current Flutter stable Android compile/target baseline: API 36 (Android 16)
- Production manifest Internet permission: none
- Android cloud backup: disabled for local SpellChecker preferences
- Cleartext network traffic: disabled in the production manifest

Using Flutter's SDK properties instead of freezing old API constants lets supported Flutter upgrades carry Android SDK requirements forward. As of August 31, 2026, Google Play requires new apps and updates to target Android 16 / API 36 or newer; the current Flutter stable baseline satisfies that requirement.

Official references:

- [Flutter Android release guide](https://docs.flutter.dev/deployment/android)
- [Google Play target API requirements](https://developer.android.com/google/play/requirements/target-sdk)
- [Android app signing](https://developer.android.com/studio/publish/app-signing)

## Development setup

Install Flutter stable and an Android SDK/toolchain, then verify the host:

```bash
flutter doctor -v
flutter devices
flutter pub get
```

Run on an emulator or connected device:

```bash
flutter run -d <android-device-id>
```

For an Android-only clean rebuild:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Release artifacts

SpellChecker supports both common Android release outputs.

### APK

Use an APK for direct installation, device testing, and distribution channels that accept APK files:

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/
```

### Android App Bundle

Use an Android App Bundle for Google Play distribution:

```bash
flutter build appbundle --release
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Google Play prefers the App Bundle format. CI validates both APK and AAB packaging so Android support cannot regress to only one artifact type.

## Production signing

Android requires release artifacts to be signed. The repository never stores a private keystore or its passwords.

1. Create or obtain the private upload keystore using the standard Android/Flutter release process.
2. Copy the public template:

```bash
cp android/key.properties.example android/key.properties
```

3. Replace every placeholder with the private release-machine values.
4. Keep `android/key.properties`, `*.jks`, and `*.keystore` files out of Git.
5. Build the APK or AAB normally.

When `android/key.properties` exists, `android/app/build.gradle.kts` creates and uses the production `release` signing configuration. When it is absent, release-mode builds fall back to the generated debug key **only for local/CI buildability validation**. A debug-signed artifact must not be uploaded as an official store release.

The required `key.properties` fields are:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

If `key.properties` exists but any required field is missing, the build fails rather than silently producing an incorrectly configured release.

## Google Play release checklist

Before uploading an official Android release:

1. Run the full repository quality gates.
2. Confirm `flutter doctor -v` is healthy for Android.
3. Confirm the release version/build number in `pubspec.yaml`.
4. Confirm the application ID is still `in.sanskar.spellchecker`.
5. Confirm Flutter's target SDK meets the current Play requirement.
6. Supply the private upload keystore through `android/key.properties` on the release machine or equivalent secured CI environment.
7. Build `flutter build appbundle --release`.
8. Verify the generated `.aab` is signed with the intended upload certificate.
9. Test the corresponding release build on representative Android devices/emulators.
10. Upload through the intended Play Console release track and complete Play App Signing/store checks.

Do not change the application ID or signing identity casually. Android uses these values as part of application/update identity.

## Android privacy and permissions

SpellChecker's production Android manifest intentionally requests no Internet permission. The debug and profile manifests can request Internet access because Flutter development tooling requires it for debugging/hot reload; that permission is not part of the production main manifest.

The production application also sets:

```text
android:allowBackup="false"
android:usesCleartextTraffic="false"
```

Disabling Android cloud backup matters because SpellChecker stores selected language, suggestion settings, writing-rule preferences, and personal vocabulary through `shared_preferences`; Android Auto Backup can otherwise include shared preferences by default. Device-to-device migration behavior can still vary by Android version and device manufacturer.

No Android runtime permission is required for the core spelling/writing workflow.

## Device compatibility testing

A release candidate should be exercised on more than one form factor where practical. At minimum verify:

- app install, first launch, relaunch, and upgrade;
- text entry with the Android soft keyboard;
- spelling checks and correction application;
- Writing insights and batch fixes;
- all built-in language selections used with suitable input methods/fonts;
- personal dictionary persistence across relaunch;
- Portable settings and dictionary import/export flows;
- clipboard actions;
- rotation and window resizing where the device supports them;
- light/dark appearance;
- large font/display scaling;
- TalkBack navigation and semantic labels;
- back navigation;
- release-mode performance on a physical device where possible.

Build success proves package compatibility; device testing validates the actual Android interaction layer.

## CI contract

The Android job in `.github/workflows/cross-platform.yml` runs after the shared formatting, analyzer, tests, and benchmark gates. It builds and uploads both:

```text
release APK
release Android App Bundle
```

The release workflow mirrors both formats for release-tag/manual packaging validation.

These public CI artifacts use non-production signing when no private release key is supplied. Their purpose is reproducible build validation, not store publication.

## Troubleshooting

### Android toolchain unavailable

Run:

```bash
flutter doctor -v
```

Resolve Android SDK, command-line tools, licenses, Java, or device/emulator warnings before diagnosing application code.

### Signing configuration fails

Check that `android/key.properties` contains all four required fields and that `storeFile` points to an existing keystore. Never fix a signing failure by committing a private key or password.

### Store rejects the target SDK

Update Flutter stable and review the current Google Play target API requirement. The project deliberately uses `flutter.targetSdkVersion` and `flutter.compileSdkVersion` so supported Flutter upgrades can move the Android baseline forward.

### A release APK works but the App Bundle fails

Run both commands locally after `flutter clean` and `flutter pub get`. CI also builds both formats; a change that breaks only AAB packaging must be treated as an Android release regression.

## Repository files that define Android support

- `android/app/build.gradle.kts` — SDK, identity, Java/Kotlin compatibility, signing.
- `android/app/src/main/AndroidManifest.xml` — production Android component/privacy configuration.
- `android/app/src/debug/AndroidManifest.xml` — development-only Internet permission.
- `android/app/src/profile/AndroidManifest.xml` — profile tooling Internet permission.
- `android/settings.gradle.kts` — Flutter/AGP plugin loading.
- `android/gradle.properties` — AndroidX and Flutter AGP compatibility configuration.
- `android/gradle/wrapper/gradle-wrapper.properties` — Gradle distribution contract.
- `android/key.properties.example` — safe signing configuration template.
- `.github/workflows/cross-platform.yml` — normal Android build validation.
- `.github/workflows/release.yml` — release-candidate Android packaging validation.

For project-wide build policy, see [Executable builds and packaging](../docs/EXECUTABLE_BUILDS.md), [Platform support](../docs/PLATFORM_SUPPORT.md), [Privacy](../docs/PRIVACY.md), and [Security](../SECURITY.md).
