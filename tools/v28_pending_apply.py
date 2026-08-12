# commit-message: docs: document V2.8 user-facing diagnostics behavior
from pathlib import Path


def append_section(path: str, heading: str, body: str) -> None:
    p = Path(path)
    text = p.read_text()
    if heading in text:
        raise SystemExit(f"section already present in {path}: {heading}")
    p.write_text(text.rstrip() + "\n\n" + body.strip() + "\n")


append_section(
    "docs/USER_GUIDE.md",
    "## V2.8 exact Writing insights totals",
    r'''
## V2.8 exact Writing insights totals

When Writing insights has more findings than its built-in 200-finding capture limit, V2.8 can show the exact relationship between the retained review set and all findings observed during the local analysis.

For example:

```text
Showing the first 200 of 1437 findings in review order.
1237 additional findings are not retained by the 200-finding capture limit.
```

The findings badge can display `200/1437`, meaning 200 findings are retained for review while 1,437 findings were observed in total.

### Per-rule totals

Enabled rule rows can also show `Total findings: N`. This is the exact number of findings produced by that enabled/supported rule during the current analysis, even when only some of those findings fit in the retained 200-finding review set.

A rule's total is informational. It is not a button and does not mean all of that rule's findings are currently available for correction.

### Filters and fixes remain captured-only

Search, review presets, category filters, automatic-fixes-only review, individual safe fixes, and batch safe fixes still operate on retained findings when analysis is limited.

Exact totals do not cause SpellChecker to reconstruct or modify findings that were not retained. This preserves the same stale-range and batch-correction safety contract as V2.7.

If filters hide every retained finding while the analysis is limited, the empty state reports the exact uncaptured quantity, for example:

```text
17 uncaptured findings were not searched.
```

### Re-run after editing or changing language

Diagnostics describe one analysis snapshot. After changing editor text, language, or enabled writing rules, reopen/re-run Writing insights to obtain current totals. Do not treat an old total as describing the modified document.
''',
)

append_section(
    "docs/ACCESSIBILITY.md",
    "## V2.8 exact limited-result diagnostics",
    r'''
## V2.8 exact limited-result diagnostics

V2.8 strengthens the accessible meaning of limited Writing insights results.

When exact totals are available, the limited-analysis explanation communicates both the retained count and total observed count instead of only an ambiguous `N+` state. The wording also states the exact number of findings not retained by the capture limit.

The findings badge is wrapped in descriptive semantics/tooltip behavior and has a stable widget key for regression testing. The visual `captured/total` value is not the only source of meaning: the nearby explanatory text provides the same relationship in full language.

Per-rule rows can expose exact `Total findings: N` metadata. Users should not need color alone to determine whether a rule produced findings or whether the overall result is limited.

### Lazy dialog behavior

Writing insights remains a scrollable lazy list. Keyboard and assistive-technology users may need to navigate through rule management before reaching the findings header/limited-result notice, just as sighted touch/mouse users scroll the dialog.

Testing must preserve this real interaction model rather than making every off-screen control permanently mounted. Changes should continue to avoid focus traps and maintain visible alternatives for keyboard shortcuts.

### Live changes

Review search/filter changes operate on retained findings. When a filtered limited result becomes empty, the empty-state explanation includes the exact uncaptured count when available so assistive-technology users are not told that the whole document has no matching findings.
''',
)

append_section(
    "docs/TROUBLESHOOTING.md",
    "## V2.8 exact writing-diagnostics troubleshooting",
    r'''
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
''',
)

append_section(
    "docs/LANGUAGE_PACKS.md",
    "## V2.8 diagnostics and language selection",
    r'''
## V2.8 diagnostics and language selection

Writing-analysis diagnostics are scoped to the active `SpellLanguagePack` and the rules that support it.

When `WritingAnalyzer` runs, only enabled rules whose language eligibility matches the active pack contribute to `totalIssueCount` and `totalIssueCountByRule`. A disabled or unsupported rule contributes no count to that analysis.

Changing from English (US) to English (UK), or vice versa, can therefore change exact writing totals because language-specific normalization, persisted per-language rule choices, and rule eligibility are resolved again for the selected pack.

Diagnostics are not persisted per language. They are computed from the current in-memory text/rule configuration and discarded with the analysis result. Per-language personal vocabulary and writing-rule preference storage remain unchanged.

Portable settings still transfer durable non-document preferences only; V2.8 exact finding counts are deliberately excluded.
''',
)
