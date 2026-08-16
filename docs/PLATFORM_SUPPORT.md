# Platform Support

This page distinguishes **portable Flutter source**, **committed platform runners**, **automated validation**, and **published build artifacts**. Those are different levels of support and should not be conflated.

For complete build commands, native-runner generation, packaging, signing boundaries, artifact verification, troubleshooting, and the machine-checked repository file inventory, see [Executable builds and packaging](EXECUTABLE_BUILDS.md).

## Current repository state

The repository currently commits:

- portable Flutter/Dart application and library source under `lib/`;
- a Flutter web host under `web/`;
- tests under `test/`;
- deterministic benchmark tooling under `tool/`.

It does **not** currently commit platform-runner directories for Android, iOS, Windows, macOS, or Linux.

## Support matrix

| Target | Portable Flutter source | Runner committed | Automated native/target build | Release artifact |
| --- | --- | --- | --- | --- |
| Web | yes | yes (`web/`) | yes, release workflow runs `flutter build web --release` | yes, uploaded web artifact |
| Android | source may be adapted with Flutter tooling | no | no | no |
| iOS | source may be adapted with Flutter tooling | no | no | no |
| Windows | source may be adapted with Flutter tooling | no | no | no |
| macOS | source may be adapted with Flutter tooling | no | no | no |
| Linux desktop | source may be adapted with Flutter tooling | no | no native desktop build | no |

This matrix documents what the repository validates today. It does not claim that Flutter itself cannot target the native platforms listed above.

## What CI validates

The primary CI workflow runs on `ubuntu-latest` and performs:

```text
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
benchmark CLI smoke
```

Those checks validate Dart/Flutter source behavior and tests. They do not build Android APK/AAB, iOS app bundles, Windows executables, macOS apps, or Linux desktop bundles.

The documentation test also verifies that the tracked-file inventory in [Executable builds and packaging](EXECUTABLE_BUILDS.md) matches `git ls-files`, so newly committed files cannot be silently omitted from executable/release documentation.

## What the release workflow validates

On `v*` tags or manual workflow dispatch, the release workflow performs the same dependency/format/analyze/test/benchmark-smoke gates and then runs:

```bash
flutter build web --release
```

It uploads `build/web` as a workflow artifact named from the tag/ref and retains that artifact according to the workflow configuration.

Therefore, the repository's automated release contract is currently **web release build**, not a native multi-platform release pipeline.

## Running the committed target locally

After cloning and resolving dependencies:

```bash
flutter run -d chrome
```

To build the same target used by release automation:

```bash
flutter build web --release
```

For the complete preflight and artifact verification procedure, use [Executable builds and packaging](EXECUTABLE_BUILDS.md).

## Using an additional Flutter target locally

The application source avoids target-specific business logic and is organized as portable Flutter code, but a target still needs the platform files and toolchain expected by Flutter.

If you choose to generate additional runner files locally:

- use the Flutter tooling version supported by your environment;
- work on a dedicated branch;
- review every generated file before committing it;
- avoid committing local signing credentials, provisioning profiles, keystores, secrets, or machine-specific paths;
- run the platform's relevant Flutter doctor checks;
- add target-specific tests/build CI before advertising the target as a repository-supported release platform;
- follow the target-specific generation/build/package procedure in [Executable builds and packaging](EXECUTABLE_BUILDS.md).

The project does not currently define a canonical generated native runner configuration, so generated native files should not be presented as official release support until they are reviewed and added intentionally.

## Storage behavior by platform

The application uses `shared_preferences` as its local preference abstraction. The exact backing store is platform/plugin-specific. SpellChecker treats it as local preference storage for selected language, suggestion count, per-language personal words, and per-language writing-rule overrides.

Do not rely on the physical storage file/location as part of the public SpellChecker API.

Before clearing browser/site/app data, export personal vocabulary and copy Portable settings if they are important.

## Clipboard behavior

The application uses Flutter clipboard APIs for explicit user actions such as:

- copying personal-dictionary export JSON;
- copying Portable settings JSON;
- copying the privacy-safe Writing insights diagnostic summary.

Clipboard behavior depends on the host platform/browser and its permissions/policies. SpellChecker does not automatically copy editor text.

## Keyboard differences

SpellChecker registers both Control and Meta variants for primary editor actions where appropriate:

- `Ctrl+Enter` / `Command+Enter` — spelling check;
- `Ctrl+Shift+Enter` / `Command+Shift+Enter` — Writing insights;
- `Ctrl+F` / `Command+F` inside Writing insights — focus search.

`F7`, `Shift+F7`, and Escape behavior may also depend on browser/OS-level shortcut interception. See [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md).

## Browser considerations

The committed web target relies on Flutter web and browser-provided storage/clipboard behavior. Browser private/incognito modes, storage policies, site-data clearing, enterprise policies, or clipboard restrictions can affect persistence and copy actions.

SpellChecker surfaces storage failures when the preference layer reports them, but it cannot override browser storage policies.

## What “cross-platform” should mean in project communication

Use precise language:

- **Portable Flutter source** means the application logic is written with Flutter/Dart abstractions and can be adapted to Flutter-supported targets.
- **Repository-supported target** means required runner files, build instructions, and relevant validation exist in the repository.
- **Release-supported target** means automated/manual release procedures produce a tested artifact for that target.

Today, only the web target satisfies all three levels in this repository.

## Adding official native support

A future native-support change should include, at minimum:

1. reviewed runner files generated from an agreed Flutter version;
2. package identifiers/application metadata;
3. platform icons/metadata where required;
4. documented local build/run commands;
5. storage/clipboard behavior validation;
6. keyboard/accessibility review where relevant;
7. target build CI;
8. release artifact/signing policy;
9. updates to README, this page, [Executable builds and packaging](EXECUTABLE_BUILDS.md), release docs, security/privacy docs, and the repository description if needed;
10. updates to the machine-checked tracked-file inventory for every new committed runner file.

Signing secrets must never be committed to the repository.

## Related documentation

- [Getting started](GETTING_STARTED.md)
- [Development](DEVELOPMENT.md)
- [Testing](TESTING.md)
- [Executable builds and packaging](EXECUTABLE_BUILDS.md)
- [Releasing](RELEASING.md)
- [Privacy](PRIVACY.md)
- [Security](../SECURITY.md)
