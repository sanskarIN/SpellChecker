from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text()


def write(path: str, text: str) -> None:
    Path(path).write_text(text)


def replace_once(path: str, old: str, new: str) -> None:
    text = read(path)
    count = text.count(old)
    if count != 1:
        raise RuntimeError(
            f'{path}: expected exactly one replacement match, found {count}: {old[:100]!r}'
        )
    write(path, text.replace(old, new, 1))


def insert_before_once(path: str, marker: str, block: str, sentinel: str) -> None:
    text = read(path)
    if sentinel in text:
        return
    count = text.count(marker)
    if count != 1:
        raise RuntimeError(
            f'{path}: expected exactly one insertion marker, found {count}: {marker!r}'
        )
    write(path, text.replace(marker, block + '\n\n' + marker, 1))


def insert_after_once(path: str, marker: str, block: str, sentinel: str) -> None:
    text = read(path)
    if sentinel in text:
        return
    count = text.count(marker)
    if count != 1:
        raise RuntimeError(
            f'{path}: expected exactly one insertion marker, found {count}: {marker!r}'
        )
    write(path, text.replace(marker, marker + '\n\n' + block, 1))


# README ---------------------------------------------------------------------
replace_once('README.md', '`2.1.0+6`', '`2.2.0+7`')
replace_once(
    'README.md',
    'Version 2.1 is the Writing Workflow Quality release. It keeps the V2.0 local writing-rule foundation and adds durable per-language rule choices, safe batch correction with deterministic overlap handling, one-step batch undo, and the `Ctrl/⌘+Shift+Enter` Writing insights shortcut. Existing V1.3 language-pack behavior and V1.2 spelling/editor workflows remain compatible.',
    'Version 2.2 is the Writing Review & Rule Management release. It keeps V2.1 persistence, batch-safety, one-step undo, and keyboard workflows while adding reusable rule categories, transient search/category/automatic-fix review filters, filtered batch application, and a true per-language **Reset rules to defaults** action that removes the stored override instead of freezing today\'s defaults. Existing V2.1, V1.3, and V1.2 behavior remains compatible.',
)
insert_after_once(
    'README.md',
    '- Optional local **Writing insights** with configurable deterministic rules.',
    '''- Writing-rule categories with source-compatible **Mechanics** default and built-in **Clarity** review.
- Temporary Writing insights search, category filters, and **Automatic fixes only** review.
- **Apply visible safe fixes (N)** when review filters are active.
- **Reset rules to defaults** clears the selected language's stored override so future registry defaults can evolve.''',
    'Temporary Writing insights search',
)
insert_before_once(
    'README.md',
    '### Persistent rule choices',
    '''### Review filters — V2.2

Writing insights can now narrow both rule management and findings without persisting review text/state:

- Search rules and findings by rule ID/name/description/category, finding message/source text, or suggested replacement.
- Filter by **Mechanics** and/or **Clarity**.
- Enable **Automatic fixes only** to hide advisory findings.
- Use **Clear review filters** to return to the complete enabled-rule review.
- Rule and finding headers show visible/total counts.

Search text, selected categories, and the automatic-fix filter live only inside the open Writing insights dialog. They are not stored in `shared_preferences` and disappear when the dialog closes.

When filters are active, the batch action becomes **Apply visible safe fixes (N)** and passes only currently visible automatic findings to the same V2.1 `WritingCorrection.applyAll` safety/overlap/undo pipeline.

### Reset rules to defaults — V2.2

**Reset rules to defaults** differs from enabling every current switch. It clears the selected language's persisted writing-rule override key, resolves the current registry defaults in memory, and closes the dialog. This returns that language to the **unset/default** preference state so future default-rule changes can be picked up normally.

If clearing the local override fails, built-in defaults remain active for the current session while SpellChecker reports that the saved override could not be removed; the old override may therefore reappear after restart until storage succeeds.''',
    '### Review filters — V2.2',
)
replace_once(
    'README.md',
    '│   ├── writing_preferences_test.dart\n│   ├── writing_rules_test.dart',
    '│   ├── writing_preferences_test.dart\n│   ├── writing_review_query_test.dart\n│   ├── writing_rules_test.dart',
)

# Changelog ------------------------------------------------------------------
insert_before_once(
    'CHANGELOG.md',
    '## [2.1.0] - 2026-08-08',
    '''## [2.2.0] - 2026-08-08

### Added

- Public `WritingRuleCategory` review metadata with **Mechanics** and **Clarity** categories.
- Source-compatible default `WritingRule.category` implementation so existing V2 external rules continue compiling and default to Mechanics.
- Built-in repeated-word rule classified as Clarity; existing mechanics-oriented built-ins retain the source-compatible Mechanics default.
- Public `WritingReviewQuery` for reusable search, category, and automatic-fix filtering outside Flutter widgets.
- Writing insights search field covering rule metadata and finding text/replacement metadata.
- Mechanics/Clarity `FilterChip` review controls.
- **Automatic fixes only** review toggle.
- **Clear review filters** action.
- Visible/total rule and finding counts.
- Category labels in rule descriptions and finding semantics/cards.
- **Apply visible safe fixes (N)** when review filters are active.
- **Reset rules to defaults** action that returns the selected language to the unset/default rule-preference state.
- `writing_review_query_test.dart` and expanded Writing insights widget tests for categories, search, filtered batch/undo, and reset-to-defaults.

### Changed

- Package version advances to `2.2.0+7`.
- About/web metadata describes categorized review and reset-to-default behavior.
- Filtered batch correction reuses the V2.1 stale/advisory/overlap/end-to-start safety contract and remains one undo entry.
- Finding category lookup uses the dialog's actual `WritingAnalyzer` rule set so custom analyzers preserve custom rule categories.
- Review filters are dialog-local and do not alter per-language persisted rule preferences.

### Persistence, security, and privacy

- Search text, selected categories, automatic-fixes-only state, visible finding sets, and review counts are not persisted.
- Resetting rules clears `spellchecker.writing_rule_ids.v1.<language-id>` instead of storing a copy of current defaults.
- A reset persistence failure keeps current-session defaults active while reporting that the saved override could not be cleared.
- No editor text, finding source excerpts, review queries, filtered batch plans, analytics, telemetry, cloud grammar service, or new runtime dependency was added.''',
    '## [2.2.0] - 2026-08-08',
)

# Roadmap --------------------------------------------------------------------
insert_before_once(
    'docs/ROADMAP.md',
    '## Future 2.x direction',
    '''## 2.2 — Writing review and rule management

Status: implemented.

- [x] Public writing-rule categories.
- [x] Source-compatible category default for existing V2 rule implementations.
- [x] Clarity classification for repeated-word review.
- [x] Public reusable `WritingReviewQuery`.
- [x] Rule/finding text search.
- [x] Mechanics/Clarity category filters.
- [x] Automatic-fixes-only finding filter.
- [x] Clear-review-filters workflow.
- [x] Visible/total rule and finding counts.
- [x] Category labels in Writing insights findings and rule metadata.
- [x] Apply-visible-safe-fixes workflow using V2.1 batch safety and one-step undo.
- [x] True reset-to-defaults that clears the per-language stored override.
- [x] Transient/non-persisted review-filter privacy boundary.
- [x] Query/filter/reset/filtered-batch regression tests.
- [x] Complete V2.2 documentation and release metadata.''',
    '## 2.2 — Writing review and rule management',
)

# Writing rules --------------------------------------------------------------
insert_before_once(
    'docs/WRITING_RULES.md',
    '## Tests',
    '''## V2.2 rule categories

`WritingRuleCategory` is public review metadata:

```dart
enum WritingRuleCategory {
  mechanics('Mechanics'),
  clarity('Clarity');
}
```

`WritingRule.category` has a concrete default of `WritingRuleCategory.mechanics`. This is intentionally source-compatible with 2.0/2.1 external rule implementations that implemented the original abstract contract before categories existed.

Rules should override the getter only when another category is a clearer user-facing fit. The built-in `repeated-word` rule is categorized as **Clarity**; the other current built-ins inherit **Mechanics**.

Category names are review organization, not severity. `WritingIssueSeverity` remains a separate finding property.

## V2.2 reusable review query

`WritingReviewQuery` keeps review filtering outside Flutter widgets:

```dart
final query = WritingReviewQuery(
  search: 'clarity',
  categories: <WritingRuleCategory>{WritingRuleCategory.clarity},
  automaticFixesOnly: true,
);

final visibleRules = query.filterRules(analyzer.rules);
final visibleIssues = query.filterIssues(
  analysis.issues,
  rules: analyzer.rules,
);
```

Search is trimmed/lowercased and can match rule ID/name/description/category plus finding rule metadata, message, exact finding source text, and suggested replacement.

When a category filter is active, a finding whose rule is unavailable in the supplied rule collection is excluded instead of being guessed into a category. Writing insights passes its actual analyzer's supported rule set so custom analyzers retain their own category metadata.

`automaticFixesOnly` filters findings only; it does not hide rule switches. Users can still manage rule enablement while reviewing only automatically fixable findings.

## V2.2 transient review state

Writing insights review filters are intentionally not application preferences:

```text
search text                memory-only dialog state
selected categories        memory-only dialog state
automatic-fixes-only       memory-only dialog state
visible counts/results     derived memory-only state
```

Closing Writing insights discards these filters. Only enabled writing-rule IDs remain persisted per language.

## Filtered batch correction

When review filters are inactive, Writing insights displays **Apply all safe fixes (N)**. When any review filter is active it displays **Apply visible safe fixes (N)** and sends only visible automatic findings to `WritingCorrection.applyAll`.

This does not create a second correction algorithm. V2.1 batch invariants remain authoritative: current-source validation, advisory skipping, deterministic overlap handling, end-to-start accepted mutation, applied/skipped counts, and one-step undo.

A hidden finding is simply not part of that user-requested filtered batch. Reopen/clear filters to review or apply other findings.

## Reset rules to defaults — V2.2

Writing insights can return `resetRulePreferences: true`. The page then:

1. Resolves current registry defaults for the selected language.
2. Activates those defaults for the current session.
3. Calls `DictionaryPreferences.clearWritingRuleIds(languageId: ...)`.
4. Leaves the language in the **missing key / registry defaults** state after a successful clear.
5. Does not apply an individual/batch finding as part of the reset action.

This is deliberately different from storing today's default rule IDs. A future release can evolve `WritingRuleRegistry.defaultEnabledRuleIds`, and a user who chose Reset will receive that new default because no explicit override remains.

If clearing fails, the current-session defaults remain active but the application reports that the saved override could not be removed; the old override may return on restart.''',
    '## V2.2 rule categories',
)

# API ------------------------------------------------------------------------
insert_before_once(
    'docs/API.md',
    '# Application persistence boundary',
    '''# V2.2 writing review APIs

## `WritingRuleCategory`

Public review categories currently include:

```dart
WritingRuleCategory.mechanics
WritingRuleCategory.clarity
```

Each category exposes `displayName`.

`WritingRule.category` is a concrete getter defaulting to Mechanics so rules written against the original V2.0 contract remain source-compatible. Rules can override the getter.

## `WritingReviewQuery`

```dart
final query = WritingReviewQuery(
  search: 'space',
  categories: <WritingRuleCategory>{WritingRuleCategory.mechanics},
  automaticFixesOnly: true,
);
```

Public fields:

```text
search
categories
automaticFixesOnly
isEmpty
```

Methods:

```dart
List<WritingRule> filterRules(Iterable<WritingRule> rules)

List<WritingIssue> filterIssues(
  Iterable<WritingIssue> issues, {
  required Iterable<WritingRule> rules,
})
```

Search is case-insensitive after trimming/lowercasing and covers rule/finding metadata. Category filtering requires a matching supplied rule. `automaticFixesOnly` affects findings and leaves the rule list available for management.

Review queries have no persistence/network behavior. The Flutter dialog stores search/categories/automatic-only state in memory only.

## Reset-to-default application contract

`WritingInsightsDialog` is internal UI, but its V2.2 user-visible contract is documented: **Reset rules to defaults** clears the selected language's stored rule-ID override through `DictionaryPreferences.clearWritingRuleIds` and resolves current registry defaults instead of storing a concrete default list.

This preserves the application persistence distinction between missing/unset and explicit stored values.''',
    '# V2.2 writing review APIs',
)

# Architecture ---------------------------------------------------------------
insert_before_once(
    'docs/ARCHITECTURE.md',
    '# Writing insights flow',
    '''# V2.2 writing review organization

`WritingReviewQuery` is part of reusable `lib/writing/`, not the Flutter dialog. This keeps search/category/fix-only matching deterministic and unit-testable.

The Writing insights dialog owns only transient review controls:

```text
search controller
selected rule categories
automatic-fixes-only toggle
```

Those values derive a query and visible rule/finding sets on each rebuild. They are discarded when the dialog closes and are never written to `DictionaryPreferences`.

Finding category labels are resolved from the dialog's actual analyzer-supported rules rather than the global built-in registry, preserving custom analyzer metadata.

## Filtered batch flow

```text
Writing insights filters
   │
   ▼
WritingReviewQuery.filterIssues
   │
   ├── visible findings
   └── visible automatic findings
            │
            ▼
Apply visible safe fixes
            │
            ▼
WritingCorrection.applyAll
            │
            └── same V2.1 stale/overlap/end-to-start/undo contract
```

Filtering selects the user's batch scope; it does not weaken correction validation.

## Reset-to-defaults flow

```text
Reset rules to defaults
   │
   ▼
WritingInsightsDialogResult(resetRulePreferences: true)
   │
   ▼
SpellCheckerPage
   ├── resolve _effectiveWritingRuleIds(null, active pack)
   ├── activate defaults in memory
   ├── clear language-specific stored rule-ID key
   └── report persistence failure without discarding session defaults
```

A successful reset leaves the preference **unset**, not explicitly equal to the current default set.''',
    '# V2.2 writing review organization',
)

# User guide -----------------------------------------------------------------
insert_before_once(
    'docs/USER_GUIDE.md',
    '## Built-in writing rules',
    '''## Review search and filters — V2.2

Writing insights can narrow the current review without changing your saved rule choices:

- **Search rules and findings** searches rule metadata plus visible finding text/replacement metadata.
- **Mechanics** and **Clarity** chips filter rules/findings by category.
- **Automatic fixes only** hides advisory findings that have no deterministic replacement.
- **Clear review filters** restores the full enabled-rule review.
- Rule and finding headers show visible/total counts.

These review filters are temporary. Closing the dialog clears them; they are not saved locally and do not travel between languages.

When any filter is active, the batch button reads **Apply visible safe fixes (N)** and applies only currently visible automatic findings using the same V2.1 stale/overlap safety and one-step undo behavior.

## Reset rules to defaults — V2.2

Use **Reset rules to defaults** when you want the selected language to follow the application's built-in default rule set again.

This is different from manually turning every current rule on. Reset removes the saved per-language override key. After a successful reset, future releases can change built-in defaults and that language can receive the new defaults normally.

If local storage cannot clear the override, current-session defaults still become active and SpellChecker reports the persistence problem; the old saved override may return after restart until storage succeeds.''',
    '## Review search and filters — V2.2',
)

# Development ----------------------------------------------------------------
insert_before_once(
    'docs/DEVELOPMENT.md',
    '# Changing writing rules',
    '''# Changing V2.2 writing review metadata/query

`WritingRuleCategory` and `WritingReviewQuery` are public APIs under `lib/writing/`.

Category changes must preserve source compatibility where practical. The concrete `WritingRule.category` Mechanics default exists so pre-V2.2 external rules do not become uncompilable just because categories were added.

Review-query changes belong in `writing_review_query.dart`, not `WritingInsightsDialog`. Add/update `test/writing_review_query_test.dart` for search, category, automatic-fix, unknown-rule, and source-compatibility behavior.

Review filters are transient UI state. Do not add them to `DictionaryPreferences` without an explicit product/privacy decision.

Filtered batch actions must pass only the intended visible automatic issues to `WritingCorrection.applyAll`; do not create a separate filtering-specific correction implementation.

`Reset rules to defaults` must clear the stored language-specific rule override. Do not implement reset by saving `WritingRuleRegistry.defaultEnabledRuleIds`, because that would freeze today's defaults into an explicit preference.''',
    '# Changing V2.2 writing review metadata/query',
)

# Testing --------------------------------------------------------------------
insert_before_once(
    'docs/TESTING.md',
    '## Writing-rule coverage',
    '''## V2.2 writing review query coverage

`test/writing_review_query_test.dart` protects:

- Empty-query semantics.
- Source-compatible Mechanics category default.
- Repeated-word Clarity categorization.
- Rule search by ID/name/description/category.
- Finding search by message/source/replacement metadata.
- Category filtering consistency between rules and findings.
- Automatic-fixes-only advisory exclusion.
- Unknown-rule handling under active category filters.

## V2.2 writing widget coverage

Expanded `test/writing_widget_test.dart` protects:

- Mechanics-only filtered batch applying only visible automatic fixes.
- Filtered batch remaining one undo entry.
- Search through category metadata.
- Reset-to-defaults clearing the stored language override key.
- Reopened Writing insights resolving registry defaults after reset.

Review-filter tests should use the real lazy dialog/list and scroll/ensure visibility rather than changing production layout. Search/category/automatic-only state must not be asserted in persistent preferences because it is intentionally transient.''',
    '## V2.2 writing review query coverage',
)

# Accessibility --------------------------------------------------------------
insert_before_once(
    'docs/ACCESSIBILITY.md',
    '## Writing insights',
    '''## V2.2 review-management controls

Writing insights adds standard accessible controls for review organization:

- Labeled search `TextField`.
- Mechanics/Clarity `FilterChip` controls with selected state.
- Labeled **Automatic fixes only** switch.
- Labeled **Clear review filters** action.
- Visible/total rule and finding counts.
- Category text in rule/finding content and finding semantics.
- Labeled **Reset rules to defaults** action.

Filters must remain keyboard reachable and must not make hidden findings indistinguishable from “no findings at all”; the dialog exposes a dedicated **No matching findings** state when enabled rules have findings that the current review filters hide.

When filters are active, **Apply visible safe fixes (N)** includes the visible automatic-fix count in its label. Resetting rules closes the dialog and reports persistence failure textually if the override could not be cleared.''',
    '## V2.2 review-management controls',
)

# Troubleshooting ------------------------------------------------------------
insert_before_once(
    'docs/TROUBLESHOOTING.md',
    '# Language behavior',
    '''## Writing insights says “No matching findings”

The enabled rules have findings, but your current V2.2 search/category/automatic-fix filters hide them.

Use **Clear review filters**, clear the search field, deselect category chips, or turn off **Automatic fixes only**. Review filters disappear automatically when the dialog closes.

## Apply visible safe fixes changed fewer items than the total finding count

Expected. With an active review filter, V2.2 sends only **visible automatic findings** into the existing safe batch pipeline. Hidden findings are outside the requested batch scope; stale/advisory/overlapping visible findings can still be skipped by V2.1 safety rules.

## Reset rules to defaults is different from turning every switch on

Expected. Reset clears the selected language's saved rule-ID override so the language returns to the **unset/default** state. Turning switches on creates/updates an explicit stored list instead.

If reset reports a storage failure, defaults are active for the current session but the previous saved override may return after restart because the key could not be removed.''',
    '## Writing insights says “No matching findings”',
)

# Releasing ------------------------------------------------------------------
replace_once('docs/RELEASING.md', 'Current V2.1 release:', 'Current V2.2 release:')
replace_once('docs/RELEASING.md', '2.1.0+6', '2.2.0+7')
insert_before_once(
    'docs/RELEASING.md',
    '# V2.1 smoke test',
    '''# V2.2 review-management smoke additions

1. Open Writing insights and verify rule categories/visible counts.
2. Search `clarity` and confirm repeated-word review remains while Mechanics rules are hidden.
3. Clear filters and confirm the complete enabled-rule review returns.
4. Select Mechanics only on synthetic text containing Mechanics and Clarity findings.
5. Use **Apply visible safe fixes** and verify only visible automatic fixes are applied.
6. Undo once and verify the exact pre-batch document returns.
7. Disable a rule so a language-specific override exists.
8. Use **Reset rules to defaults**.
9. Verify the rule preference key is removed/unset rather than stored as a concrete list.
10. Reopen Writing insights and verify current registry defaults are active.
11. Verify review search/chips/automatic-only state do not persist after closing/reopening the dialog.
12. Exercise a reset storage-failure test/path and verify session defaults remain active while durability failure is reported.''',
    '# V2.2 review-management smoke additions',
)
replace_once(
    'docs/RELEASING.md',
    'git tag -a v2.1.0 -m "SpellChecker v2.1.0"\ngit push origin v2.1.0',
    'git tag -a v2.2.0 -m "SpellChecker v2.2.0"\ngit push origin v2.2.0',
)
replace_once(
    'docs/RELEASING.md',
    'Highlight V2.1 persisted per-language rule choices, batch safe fixes, one-step batch undo, and Writing insights shortcut.',
    'Highlight V2.2 review categories/search/filters, filtered batch fixes, reset-to-defaults semantics, plus the retained V2.1 persistence/batch/undo/shortcut foundation.',
)

# Privacy --------------------------------------------------------------------
insert_before_once(
    'docs/PRIVACY.md',
    '## Language selection and vocabulary',
    '''## Review filters — V2.2

Writing insights search text, selected rule categories, the automatic-fixes-only switch, visible counts, and the filtered visible finding set are dialog-local memory state.

SpellChecker does not persist or upload:

- Review search queries.
- Selected review categories.
- Automatic-fixes-only state.
- Visible/hidden finding lists.
- Filtered batch plans.

Closing the dialog discards the review filters.

## Reset-to-defaults privacy behavior

Resetting writing rules clears the selected language's local `spellchecker.writing_rule_ids.v1.<language-id>` override. It does not create a document log or send a reset event to a remote service.

If local storage removal fails, built-in defaults stay active for the current session while the existing persisted override can remain on the device/profile and may reappear after restart.''',
    '## Review filters — V2.2',
)

# Language packs -------------------------------------------------------------
insert_before_once(
    'docs/LANGUAGE_PACKS.md',
    '# Writing-rule eligibility',
    '''## Resetting language-specific writing rules — V2.2

**Reset rules to defaults** removes the active language's `spellchecker.writing_rule_ids.v1.<language-id>` key and resolves current registry defaults for that pack. It does not write a copy of today's default IDs.

That distinction preserves language isolation and forward-compatible defaults:

```text
en-US override cleared -> en-US follows registry defaults
en-GB override remains -> en-GB keeps its explicit choices
```

Review search/category/automatic-only filters are not language preferences and are never stored in either namespace.''',
    '## Resetting language-specific writing rules — V2.2',
)

# Contributing ---------------------------------------------------------------
insert_before_once(
    'CONTRIBUTING.md',
    '# Writing-rule preference compatibility',
    '''# V2.2 review management compatibility

`WritingRule.category` is public API with a source-compatible Mechanics default. New category behavior should not force existing V2 external rules to implement a new abstract member unless a deliberate breaking release documents that change.

`WritingReviewQuery` is the reusable filtering authority. Search/category/fix-only matching should not be duplicated inside widgets.

Review filters are temporary and must not be persisted without explicit privacy/product review.

Filtered batch fixes must reuse `WritingCorrection.applyAll` and preserve V2.1 stale/advisory/overlap/end-to-start/one-step-undo behavior.

**Reset rules to defaults** must clear the current language's stored override rather than save the registry's current default set. Add tests proving the key becomes missing/unset and defaults are resolved on the next dialog/session.''',
    '# V2.2 review management compatibility',
)

# Security -------------------------------------------------------------------
insert_before_once(
    'SECURITY.md',
    '## Writing-rule preference integrity',
    '''## V2.2 review-query security/privacy boundary

Review search/category/automatic-only controls operate only on already-local rule metadata and in-memory findings. They do not trigger remote search, external rule loading, or background document indexing.

Search text can contain words copied from a finding/document, so it must remain memory-only and must not be added to preference keys, logs, analytics, crash metadata, or network requests.

Filtered batch actions still pass through `WritingCorrection.applyAll`; filtering does not grant permission to bypass stale-range or overlap checks.

**Reset rules to defaults** removes only the selected language's writing-rule preference key. It must not clear unrelated language vocabulary/settings or execute/load rules based on untrusted stored IDs.''',
    '## V2.2 review-query security/privacy boundary',
)

# Support --------------------------------------------------------------------
insert_before_once(
    'SUPPORT.md',
    '# Language-pack reports',
    '''# V2.2 review-management reports

For search/filter problems include synthetic text plus:

- Search query (synthetic/non-sensitive).
- Selected category chips.
- Automatic-fixes-only state.
- Visible/total finding counts.
- Whether **Clear review filters** restores the expected finding.
- Whether the problem affects rule switches, findings, or both.

For **Apply visible safe fixes** bugs include expected/actual synthetic final text, visible automatic finding count, applied/skipped feedback, and whether one Undo restores the exact pre-batch text.

For **Reset rules to defaults** bugs state the selected language, prior enabled rule IDs, whether the stored per-language rule key was removed, whether defaults became active immediately, and whether an old override reappeared after restart. Do not post private editor text or a full preference dump.''',
    '# V2.2 review-management reports',
)

# Issue/feature/PR templates -------------------------------------------------
insert_before_once(
    '.github/ISSUE_TEMPLATE/bug_report.yml',
    '        - Writing shortcut (Ctrl/Command+Shift+Enter)',
    '''        - Writing review search / category filters
        - Writing automatic-fixes-only filter
        - Writing apply-visible batch fix
        - Writing reset rules to defaults''',
    'Writing review search / category filters',
)
insert_before_once(
    '.github/ISSUE_TEMPLATE/feature_request.yml',
    '        - Writing batch correction / conflict handling',
    '''        - Writing review search / categories / filters
        - Writing rule reset/default management''',
    'Writing review search / categories / filters',
)
insert_before_once(
    '.github/pull_request_template.md',
    '## Batch correction safety',
    '''## Writing review management

- [ ] Writing-rule categories preserve intended public/source compatibility.
- [ ] Search/category/automatic-fix filtering is implemented in reusable query code rather than duplicated in widgets.
- [ ] Review filter state remains transient unless persistence is explicitly reviewed/documented.
- [ ] Filtered batches still use the shared writing-correction safety/undo contract.
- [ ] Reset-to-defaults clears the language override rather than storing today's defaults.
- [ ] Query/filter/reset behavior has unit/widget regression tests.''',
    '## Writing review management',
)

# Web metadata ---------------------------------------------------------------
replace_once(
    'web/index.html',
    'persistent per-language vocabulary and writing-rule choices, batch-safe local writing fixes, keyboard workflows, and one-step undo.',
    'persistent per-language vocabulary and writing-rule choices, categorized searchable writing review, filtered batch-safe local fixes, reset-to-default rule management, keyboard workflows, and one-step undo.',
)
replace_once(
    'web/manifest.json',
    'persistent per-language vocabulary and writing-rule choices, batch-safe local writing fixes, keyboard workflows, and undo-friendly corrections.',
    'persistent per-language vocabulary and writing-rule choices, categorized searchable writing review, filtered batch-safe local fixes, reset-to-default rule management, keyboard workflows, and undo-friendly corrections.',
)

print('V2.2 documentation/repository metadata transform applied successfully.')
