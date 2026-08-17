# V3.0 Cross-Platform Foundation

## Release identity

- Package: `spellchecker`
- Version: `3.0.0+22`
- User-facing version: `3.0.0`
- Stable reverse-domain native identity: `in.sanskar.spellchecker` where applicable
- User-facing application name: `SpellChecker`

## Purpose

V3.0 converts SpellChecker from a repository with only a committed web runner into a repository-supported Flutter application across Android, iOS, Linux, macOS, Web, and Windows while preserving the privacy-first deterministic spelling/writing architecture established through V2.16.

## Platform foundation

Flutter stable generated the native runner families from the existing application source. The project-owned web shell was preserved. The committed `.metadata` file tracks all six platform families so later Flutter migrations have a template baseline.

The V3 branch contains:

- `android/`
- `ios/`
- `linux/`
- `macos/`
- `web/`
- `windows/`

Platform presentation metadata uses `SpellChecker`; stable binary/package identifiers remain intentionally machine-friendly and should not be changed casually after release.

## Cross-platform CI contract

`.github/workflows/cross-platform.yml` runs shared quality gates once, then release-mode target builds on appropriate GitHub-hosted systems:

```text
Web      ubuntu-latest   flutter build web --release
Android  ubuntu-latest   flutter build apk --release
Linux    ubuntu-latest   flutter build linux --release
Windows  windows-latest  flutter build windows --release
macOS    macos-latest    flutter build macos --release
iOS      macos-latest    flutter build ios --release --no-codesign
```

The shared quality gate remains canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke.

## Release workflow contract

`.github/workflows/release.yml` mirrors six-target build coverage for `v*` tags and manual dispatch. Build outputs are uploaded as GitHub Actions artifacts. The workflow deliberately does not commit or synthesize private signing material.

## Signing and distribution boundary

Repository-supported and CI-buildable do not automatically mean store-ready. Production distribution still requires channel-specific work such as Android release signing, Apple provisioning, macOS notarization, optional Windows signing/installer packaging, and a chosen Linux package/distribution format.

No private keystore, certificate private key, provisioning credential, store secret, or notarization secret belongs in Git history.

## Privacy and runtime behavior

V3.0 does not add cloud spelling/grammar, generative rewriting, telemetry, accounts, document upload, or automatic document persistence. Existing local preference behavior continues through `shared_preferences` implementations for each target.

Platform-specific storage backends, clipboard policy, keyboard interception, and accessibility stacks differ by operating system; these differences are documented in `PLATFORM_SUPPORT.md` and must be part of manual distribution validation.

## Regression protection

Repository tests now require representative committed runner files for all six targets and require `.metadata` to list each platform. The executable inventory test treats Flutter-generated platform roots as managed runner trees while continuing to protect project-owned files and cross-platform workflow controls.

## Validation criteria

A V3.0 candidate is acceptable only when:

1. canonical Dart formatting is clean;
2. `flutter analyze` is clean;
3. the complete Flutter test suite passes;
4. deterministic benchmark smoke passes;
5. Web release build succeeds;
6. Android release APK build succeeds;
7. Linux release bundle build succeeds;
8. Windows release bundle build succeeds;
9. macOS release app build succeeds;
10. iOS release no-codesign build succeeds;
11. README/platform/release/build documentation matches those claims;
12. no production signing secret is committed.

## Follow-up phases

V3.0 establishes buildable platform coverage. Later phases can add permanent GitHub Release creation, public web deployment, store/installer packaging, signing/notarization workflows using repository/environment secrets, platform-specific branding assets, and broader manual device/accessibility matrices.
