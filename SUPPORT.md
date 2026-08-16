# Support

<p align="center">
  <a href="https://buymeacoffee.com/sanskarIN">
    <img alt="Buy Me a Coffee — Support SpellChecker" src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Support%20SpellChecker-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=000000">
  </a>
</p>

> SpellChecker is free and open source. Financial support is optional; bug reports, security reports, feature requests, and contributions do not depend on funding.

This page explains how to get help with SpellChecker `2.16.0+21` and what information makes a report useful without exposing private documents.

## Start here

Before opening an issue:

1. read the [documentation hub](docs/README.md);
2. check the [FAQ](docs/FAQ.md);
3. follow [Troubleshooting](docs/TROUBLESHOOTING.md);
4. search existing GitHub issues/pull requests;
5. reproduce with the smallest synthetic input possible.

## Security vulnerabilities

Do **not** report a security vulnerability as a normal public bug when disclosure could put users/data at risk.

Follow [SECURITY.md](SECURITY.md) and use GitHub private security reporting when available.

## What to include in a normal bug report

Include:

- SpellChecker version/commit;
- platform/browser;
- Flutter/Dart version when development/tooling related;
- selected language (`en-US` or `en-GB`);
- exact feature/workflow;
- minimal synthetic input;
- expected behavior;
- actual behavior;
- whether local preferences finished loading;
- whether a storage warning appeared;
- whether the result was limited/truncated;
- steps that reproduce consistently.

Screenshots can help with layout/accessibility problems, but remove/redact private text/account information first.

## Privacy-sensitive reporting

Never post unnecessarily:

- private documents;
- credentials/secrets/tokens;
- account information;
- personal messages;
- sensitive personal vocabulary;
- real correction-history snapshots;
- private writing findings/source excerpts;
- private Portable settings/dictionary exports containing sensitive custom content.

Use artificial strings such as:

```text
Helo world
hello  world!!
word word
```

## Spelling problem report

Useful fields:

- selected language;
- exact unknown word/synthetic sentence;
- whether the word is base, personal, or ignored;
- suggestion limit;
- returned suggestion order;
- whether behavior changes after switching `en-US`/`en-GB`;
- whether the issue appears only after dictionary import/restart;
- whether the spelling result is limited to the first 200 issues.

For suggestion-ranking bugs, include the expected/actual ordered candidate words and whether a custom `SpellSuggestionRanker` is involved.

## Unicode/source-range problem report

Include the exact synthetic Unicode string and say whether it uses:

- non-BMP characters;
- combining marks/decomposed accents;
- curly/straight apostrophes;
- Unicode hyphens;
- quote/bracket boundaries.

Source offsets in SpellChecker APIs are UTF-16 code-unit offsets. If reporting a wrong range, include the expected substring and `start/end` rather than describing only visible character positions.

## Personal dictionary problem report

Include:

- selected language;
- add/remove/clear/import/export action;
- synthetic word(s);
- whether a storage error appeared;
- whether the problem survives restart;
- import format/version if relevant;
- whether version-2 document language matches the selected language.

For import bugs, minimize the JSON/plain list to the smallest failing document. Do not post a real sensitive vocabulary list.

## Portable settings problem report

Include:

- whether failure occurs during decode/validation or persistence/application;
- selected language before import;
- suggestion count before/after;
- explicit rule override states involved;
- a minimized synthetic settings JSON document;
- whether the UI reported rollback/restoration of prior durable settings.

Portable settings should never contain editor text or personal vocabulary. If a report appears to show that, treat it as a serious correctness/privacy bug.

## Writing insights problem report

Include:

- selected language;
- synthetic text;
- enabled writing-rule IDs;
- current review preset;
- search/category/Automatic fixes only filters;
- captured finding count;
- exact total when shown;
- whether result is complete/limited;
- whether the finding is advisory or automatically fixable;
- whether the text changed after analysis;
- expected/actual source range and replacement when relevant.

If filters or source text changed, reopen Writing insights before comparing a fresh result.

## Writing batch correction problem

Include:

- synthetic text before correction;
- exact findings involved (rule IDs and source ranges, not private excerpts);
- which findings had replacements;
- applied/skipped counts;
- resulting text;
- whether one-step Undo correction restored the pre-batch value.

Remember that advisory, stale, invalid, and later-overlapping findings are deliberately skipped.

## Diagnostic summary

For writing-analysis count/ordering issues, copy the built-in metadata-only diagnostic summary when safe.

It includes counts/rule/language metadata and excludes editor text, source excerpts, messages, replacements, and offsets.

If exact totals are unavailable, note whether the `WritingAnalysisResult` was manually/directly constructed rather than returned by `WritingAnalyzer.analyze()`.

## Large-document / first-200 reports

For spelling:

- captured issue count;
- `SpellCheckReport.truncated`/`scannedTokenCount` when using API;
- configured `maxIssues` when applicable;
- suggestion count.

For writing:

- captured count;
- exact total;
- uncaptured count;
- `maxIssues`;
- enabled rules;
- active filters;
- whether the action operated only on captured findings.

Use repeated synthetic text instead of attaching a private large document.

## Keyboard/accessibility problem report

Include:

- platform/browser;
- assistive technology/version if used;
- control with focus;
- key combination;
- whether browser/OS intercepted it;
- expected/actual focus/result;
- wide/narrow layout;
- text scale/zoom if relevant.

For Writing insights, specify whether the first Escape was expected to clear an active query and whether a subsequent Escape closed.

See [Accessibility](docs/ACCESSIBILITY.md).

## Storage problem report

Include:

- browser/platform;
- private/incognito mode or enterprise policy if relevant;
- operation being saved/loaded;
- exact displayed storage warning;
- whether current session behavior still worked;
- whether previous durable state returned after restart.

Do not attach raw host preference files containing sensitive vocabulary unless absolutely necessary and safe.

## Benchmark/performance report

Include:

- exact benchmark command;
- commit SHA;
- Flutter/Dart versions;
- OS/hardware;
- repeats/warmup/iterations;
- spelling/writing capture limits;
- suggestion count;
- language;
- JSON report when appropriate.

Use the built-in synthetic scenario. Raw timings from unrelated machines are not directly comparable.

See [Performance](docs/PERFORMANCE.md).

## Build/CI problem report

Include:

- failing command/step;
- Flutter/Dart versions;
- exact analyzer/test/build error;
- whether the failure reproduces locally after `flutter pub get`;
- changed files/area.

Canonical local gate:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
```

Release issues should also include the `flutter build web --release` result.

## Feature requests

A useful feature request explains:

- user/developer problem;
- desired behavior;
- why current behavior/workaround is insufficient;
- privacy/security impact;
- API/persistence/platform impact;
- deterministic/local feasibility where relevant;
- scope/non-goals.

The roadmap lists optional future directions but is not a guarantee. See [Roadmap](docs/ROADMAP.md).

## Documentation problems

For missing/stale/incorrect docs, identify:

- page/section;
- current code behavior/source when known;
- expected correction;
- whether the statement is evergreen or intentionally historical.

Historical release files may correctly describe old rule counts/version behavior; use [Release history](docs/RELEASE_HISTORY.md) to distinguish them from current docs.

## Response expectations

This open-source project does not guarantee a specific response time. Clear, reproducible, privacy-safe reports are easier to investigate.

Do not repeatedly post the same issue across multiple threads to seek priority.

## Optional funding

If you want to support continued development, use [Buy Me a Coffee](https://buymeacoffee.com/sanskarIN).

Funding is not required for support, issue triage, security handling, roadmap consideration, or contribution review.
