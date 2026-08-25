# UI localization

SpellChecker V3.3 introduces Flutter source-generated localization as a presentation-layer concern. It is deliberately independent from the spelling/document language selected in the editor.

## Current V3.3 foundation

- `lib/l10n/app_en.arb` is the English source-of-truth bundle.
- `l10n.yaml` generates `AppLocalizations` into `lib/l10n`, inside the application source tree rather than through a synthetic package.
- `flutter_localizations` supplies Flutter widget localizations and `intl` follows the version pinned by the Flutter SDK.
- The application shell keyboard-help surface and the searchable spelling-language picker consume generated strings.
- English is the only supported UI locale while extraction of the complete user-facing surface is still in progress.
- Changing spelling language never changes UI locale, personal-dictionary ownership, writing-rule preferences, or deterministic analysis behavior.

## Adding the first non-English UI locale

Do not add a locale merely to demonstrate translation plumbing. A locale becomes supported only after the chosen user-facing release scope is completely translated, reviewed for meaning, exercised at narrow widths and large text scale, and covered by locale-resolution/widget tests.

A new locale must preserve stable spelling-language IDs, writing-rule IDs, Portable settings, personal-dictionary formats, and the local/offline privacy boundary. UI translation must never imply cloud translation, document upload, telemetry, or automatic document-language detection.

## Contributor workflow

After changing an ARB resource, run `flutter pub get` and `flutter gen-l10n`, then format/analyze/test the project. Generated source belongs in `lib/l10n` and must stay synchronized with its ARB inputs.
