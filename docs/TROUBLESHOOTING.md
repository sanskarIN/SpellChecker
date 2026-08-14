# Troubleshooting

## `flutter` command not found

Install Flutter and ensure its `bin` directory is on `PATH`.

```bash
flutter doctor
```

## Dependencies fail to resolve

```bash
flutter clean
flutter pub get
```

Confirm the Dart SDK satisfies `pubspec.yaml` and Flutter stable is installed.

SpellChecker 2.9 keeps the small runtime dependency surface: Flutter plus `shared_preferences` for local settings.

## Analyzer reports formatting or lint issues

```bash
dart format lib test
flutter analyze
```

Fix source/test findings rather than suppressing lints only to make CI green.

# Writing insights

## Writing insights reports something intentional

The built-in rules are optional deterministic checks, not universal style judgments.

Disable the corresponding rule in Writing insights. In V2.1 that choice is saved locally for the selected language when storage is available.

## Writing rule switches reset after restart

This is **not expected in V2.1** when local preference storage is available.

Check:

1. The switch visibly changed before closing Writing insights.
2. No local-storage warning appeared.
3. The same language is selected after restart.
4. Browser/profile/app storage has not been cleared.
5. Private/incognito restrictions are not discarding application preferences.

Rule preferences are language-specific. A choice made in `en-US` does not automatically change `en-GB`.

## All writing rules are disabled after restart

An explicitly empty rule set is a valid V2.1 preference. If every switch was turned off, SpellChecker preserves that choice instead of restoring defaults.

Re-enable the desired switches in Writing insights. If no rule preference has ever been stored for a language, SpellChecker uses the current built-in defaults.

## A new built-in rule is not enabled after upgrade

If you already have an explicit stored rule set for that language, SpellChecker respects your stored IDs rather than automatically adding every future rule.

Users with **no stored writing-rule preference** receive the current default rule set. This protects explicit choices from being overwritten by upgrades.

## Writing-rule choices differ between US and UK

Expected. V2.1 stores rule IDs per language namespace.

Example keys:

```text
spellchecker.writing_rule_ids.v1.en-US
spellchecker.writing_rule_ids.v1.en-GB
```

Configure each language separately.

## Apply safe fix refuses to change text

The current editor source no longer matches the exact source range that produced the finding. This can happen after editing while a finding is open.

SpellChecker refuses the stale mutation. Close/reopen Writing insights for a fresh analysis.

## Apply all safe fixes applied fewer fixes than the button count

The button count represents findings with automatic replacements at analysis time. At application time SpellChecker performs safety checks again.

A finding can be skipped because:

- It became stale.
- Its range is invalid for current text.
- It overlaps an earlier accepted automatic fix.
- It is advisory/no longer has a usable automatic replacement in the supplied result set.

The editor reports applied/skipped counts after the batch.

## Two writing fixes overlap

V2.1 uses a deterministic conservative policy:

1. Sort by source start.
2. Then source end.
3. Then rule ID.
4. Accept the earliest safe finding.
5. Skip later overlaps.

The application does not attempt to merge ambiguous transformations.

Run Writing insights again after the batch if another finding may still be relevant to the resulting text.

## Apply all safe fixes changed text in an unexpected order

Accepted replacements are applied from the end of the document toward the beginning. This is intentional because earlier source offsets remain valid even when a later replacement changes string length.

The **selection** of accepted fixes is still determined in forward source order; only physical mutation occurs from end to start.

## Undo after a writing batch restores everything

Expected. **Apply all safe fixes** is intentionally one correction-history entry.

One **Undo correction** restores the exact editor state from immediately before the batch.

## Ctrl+Shift+Enter / Command+Shift+Enter does not open Writing insights

Try the visible Writing insights app-bar button first.

If the button works but the shortcut does not:

- The browser/OS may intercept the key combination.
- Verify both modifier keys are actually sent to the Flutter app.
- Report platform/browser and the exact combination.

The shortcut is supplementary; the visible control remains authoritative.

## Writing insights says “No matching findings”

The enabled rules have findings, but your current V2.2 search/category/automatic-fix filters hide them.

Use **Clear review filters**, clear the search field, deselect category chips, or turn off **Automatic fixes only**. Review filters disappear automatically when the dialog closes.

## Apply visible safe fixes changed fewer items than the total finding count

Expected. With an active review filter, V2.2 sends only **visible automatic findings** into the existing safe batch pipeline. Hidden findings are outside the requested batch scope; stale/advisory/overlapping visible findings can still be skipped by V2.1 safety rules.

## Reset rules to defaults is different from turning every switch on

Expected. Reset clears the selected language's saved rule-ID override so the language returns to the **unset/default** state. Turning switches on creates/updates an explicit stored list instead.

If reset reports a storage failure, defaults are active for the current session but the previous saved override may return after restart because the key could not be removed.

# Language behavior

## US/UK spelling changes after switching language

Expected. The packs deliberately differ on variants such as:

```text
color / colour
center / centre
theater / theatre
```

Changing language invalidates old spelling issue state and re-checks current non-blank text.

## A saved word exists in one language but not another

Expected. Personal dictionaries are isolated per language.

Save/import the word independently for the intended language.

## A version-2 dictionary import asks me to switch language

Version-2 exports contain a language ID. SpellChecker prevents silently merging tagged vocabulary into a different selected language.

Switch to the export's language and retry.

Legacy version-1/JSON-array/plain-list imports have no language metadata and are interpreted using the currently selected language.

# Spelling and highlighting

## A correct word is reported as misspelled

The bundled dictionaries are curated, not complete linguistic databases.

Options:

- **Save word** for persistent legitimate vocabulary in the selected language.
- **Ignore once** for a temporary session exception.
- Add the word through **Manage personal dictionary**.
- Contribute a broadly useful dictionary entry.

## Inline underlines disappear when I type

Expected. Spelling ranges belong to the exact checked text snapshot. Manual edits invalidate that snapshot, so old highlights/results are cleared.

Run **Check spelling** again or press `Ctrl/Command+Enter`.

## A current highlight looks missing

The editing controller skips invalid/stale/overlapping highlight ranges rather than rendering an incorrect span or throwing.

If a valid issue is missing without any intervening edit, file a bug using minimal synthetic text.

## F7 does not move to an issue

Check:

1. Text contains an unknown word.
2. Run a spelling check or press F7 on non-blank text so the page can attempt one.
3. Confirm the browser/OS has not captured F7.
4. Try visible previous/next controls.

`F7` moves forward; `Shift+F7` moves backward; navigation wraps.

## Ctrl+Enter / Command+Enter does not check spelling

Try **Check spelling** first.

If the button works, the platform/browser may be intercepting the shortcut.

## Replace all is not shown

**Replace all…** requires:

- More than one current checked case-insensitive occurrence of the same unknown word.
- At least one suggestion for that issue.

Correct or unchecked occurrences are not included.

## Replace all changed fewer spelling occurrences than expected

Spelling replace-all mutates only still-current checked issue ranges. It is not unrestricted find/replace.

If text changed since checking, stale ranges can be skipped/refreshed for safety.

## A spelling replacement does not happen

The current source substring no longer equals the checked issue word. SpellChecker refreshes results instead of applying a stale edit.

# Correction undo

## Undo correction is disabled

The shared correction stack is cleared when:

- No programmatic correction has been applied yet.
- The user manually edits text after corrections.
- The editor is cleared.
- The application session ends.

The stack is not a persistent document history system.

## The active spelling issue changes after Undo

Undo restores the previous `TextEditingValue`, including caret/selection, then runs a fresh spelling check. Active issue selection can legitimately favor an issue near the restored caret rather than always issue 1.

## Snackbar Undo disappeared

The snackbar is temporary. **Undo correction** remains available while the correction stack still contains an entry.

Manual typing intentionally clears that stack.

# Local storage

## Storage warning appears

SpellChecker could not load/write one or more local preferences.

Session spelling/writing analysis remains usable.

Possible causes:

- Browser/profile storage restrictions.
- Private/incognito policies.
- Platform plugin/storage unavailability.
- App/browser data restrictions.

The warning does not indicate editor text was uploaded.

## Writing-rule switch worked but was not saved

V2.1 applies the switch to the current session immediately. If persistence then fails, the session choice remains active but the app reports that it may not survive restart.

This avoids falsely undoing the user's current interaction while still avoiding a false durability claim.

## A saved personal word disappears after restart

Check:

1. You used **Save word**, not **Ignore once**.
2. The correct language is selected.
3. The dictionary manager lists the word before restart.
4. Local application storage is allowed.
5. App/browser data was not cleared.

Personal vocabulary is local; there is no cloud account synchronization.

## Ignored words return after restart

Expected. **Ignore once** is session-only by design.

# Personal dictionary import/export

## Import is rejected

Current supported forms include:

- Version-2 language-tagged SpellChecker JSON.
- Legacy version-1 SpellChecker JSON.
- JSON arrays.
- Plain line/comma-separated word lists.

Malformed entries, unsupported versions/languages, and incompatible tagged-language imports are rejected rather than guessed.

Version-2 example:

```json
{
  "version": 2,
  "language": "en-US",
  "words": ["flutter", "open-source"]
}
```

## Export does not create a file

Expected. **Copy export** writes JSON to the local clipboard. It does not upload data or create a filesystem file.

Clipboard access can be affected by platform/browser permissions.

# Suggestions and language forms

## Suggestion count is unexpected

Open **Manage personal dictionary** and inspect **Suggestions per spelling issue**.

Supported persisted values are 1–10. Out-of-range stored values are normalized into that range.

## Suggestion ordering changed

Ranking considers edit distance, first-character agreement, approximate frequency rank, candidate length, then alphabetical order.

Dictionary/frequency improvements can change tie ordering without changing edit-distance behavior.

## A possessive/contraction is reported unexpectedly

Current English packs support several regular suffixes from known stems, including:

```text
's
're
've
'll
'd
'm
n't
```

Irregular forms may require direct dictionary coverage.

## No suggestions are shown

Very distant unknown words can fall outside the pack's suggestion distance threshold.

Also verify the persisted suggestion-count preference.

# Widget/development troubleshooting

## Tests fail only when tapping an issue action

Flutter widget tests have a bounded surface. A valid control can exist in a scrollable list but be outside the hit-test viewport.

Use:

```dart
final control = find.text('Save word');
await tester.ensureVisible(control);
await tester.pumpAndSettle();
await tester.tap(control);
```

Do not shrink production UI solely for test hit-testing.

## Writing widget tests cannot find a finding

Writing insights uses a lazy `ListView`. Findings below the rule-switch section might not be built until the list is scrolled.

Drag the dialog list and settle before asserting the finding.

## Web build fails

```bash
flutter doctor
flutter clean
flutter pub get
flutter build web --release
```

If a Flutter-generated host template is implicated, regenerate locally with the supported stable Flutter version and review diffs before committing.

## CI fails but local tests pass

Run:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Also run release checks when preparing a release:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter build web --release
```

Compare Flutter/Dart versions with CI output.

# Clear behavior

## Clearing editor text did not clear settings

Expected. **Clear** removes current editor text/results/statistics/highlights and current correction history.

It does **not** delete:

- Selected language.
- Personal vocabulary.
- Suggestion-count preference.
- Writing-rule preferences.

Use the relevant settings controls for persistent data.

## Portable settings import problems — V2.3

If a portable settings document is rejected, verify `format` is `spellchecker-settings`, `version` is `1`, `languageId` and every override key are supported built-in language IDs, `suggestionLimit` is 1–10, override values are arrays, and rule IDs use the documented lowercase stable-ID form. If storage fails during import, SpellChecker keeps the live editor on its previous state and attempts to restore the previous durable portable preferences; because local preference storage is not transactional, recovery is best effort. Personal vocabulary is not part of the portable document, so missing personal words should be investigated through the language-specific personal dictionary instead of the settings JSON.

## Results show 200+ — V2.5

`200+` means SpellChecker captured 200 spelling issues and then found at least one additional unknown word later in the text.

This is not a crash or storage problem. Single fixes and captured-issue navigation still work. Replace all is hidden because the checked occurrence set is incomplete.

If you need to review later portions, fix/ignore/save some early issues and check again, or temporarily check a smaller section of the document. Do not interpret the 200 captured issues as the total number of issues in the document.

If fewer than 200 issues are shown without `+`, the result completed normally.

## V2.6 spacing rules are missing or inactive

If **Punctuation spacing** or **Trailing whitespace** is not enabled after upgrading, check whether the language has an explicit saved writing-rule override. V2.6 preserves explicit non-empty and explicit empty sets. Use **Reset rules to defaults** to clear that override and opt back into the current registry defaults. The two rules are currently eligible for the built-in English (US) and English (UK) packs only.

## Writing insights says results are limited

The built-in V2.7 Writing insights dialog captures at most 200 findings. A limited notice means at least one additional finding exists beyond that captured prefix.

This does not mean analysis failed. Review the captured findings, apply safe captured fixes if desired, edit the text, and open Writing insights again for a fresh analysis. Search and filters only inspect the captured findings while the result is limited.

The limit controls retained finding objects and dialog workload; it is not a hard maximum document length or a promise that rule execution stops after 200 matches.

## V2.8 exact writing-diagnostics troubleshooting

### The badge says `200/900`. Why can I review only 200 findings?

The first number is the retained Writing insights review set. The second is the exact number of findings observed by all enabled/supported rules during that analysis. The built-in dialog intentionally retains at most 200 findings.

Filters and fixes operate only on the retained set when the result is limited.

### A rule says `Total findings: N`, but fewer of that rule's cards are visible

The rule total describes all findings yielded by that rule. The retained 200-finding list is selected by global review order across every enabled rule, so some findings from that rule may fall outside the retained prefix.

Active search/category/fix filters can further reduce the visible subset.

### Totals changed after I switched language or rule settings

That is expected. Exact counts depend on:

- current editor text;
- active language pack;
- enabled writing-rule IDs;
- language eligibility of each rule.

Re-run/reopen Writing insights after those inputs change.

### Totals appear inconsistent

Use a short synthetic example and record:

- selected language;
- enabled rule IDs;
- configured `maxIssues` if using the library API;
- retained count;
- exact overall total;
- exact per-rule totals;
- whether the result is complete/truncated;
- any active review filters.

The per-rule exact totals should sum to the exact overall total for analyzer-produced results. Do not attach a private document solely to demonstrate a count mismatch.

## V2.9 diagnostic-summary troubleshooting

### A diagnostic summary says `unavailable` for exact totals

This is expected for a directly constructed compatibility `WritingAnalysisResult` that omitted the optional V2.8 exact-total fields. V2.9 does not invent totals. Analyzer-produced results provide exact totals and therefore normally render numeric total/uncaptured values.

### A diagnostic summary contains a rule ID instead of a friendly rule name

Pass the relevant configured `WritingRule` values to `WritingAnalysisDiagnosticSummary.fromResult(..., rules: ...)`. Unknown rule IDs intentionally fall back to their stable ID rather than guessing a display label.

### I need to report a diagnostics bug

Prefer the V2.9 metadata-only summary or a synthetic minimal example. Do not attach a private document, raw finding excerpts, personal vocabulary, or correction history unless a private security/support channel explicitly requires and authorizes it.

## V2.10 benchmark troubleshooting

If the benchmark command rejects an option, run `dart run tool/benchmark_large_document.dart --help` and use the documented `--name=value` forms. Repeated options are rejected deliberately, numeric bounds/iteration counts must satisfy their positive/non-negative contracts, and language IDs are limited to the built-in `en-US` / `en-GB` packs.

If analysis outcomes differ between measured samples, treat that as a determinism defect and report the exact commit/command using synthetic data. If only elapsed times differ, first compare Flutter/Dart versions, hardware, runtime load, build/runtime mode, options, and commit; timing variation alone is expected and is not a normal correctness failure.
