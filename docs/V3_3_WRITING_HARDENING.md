# V3.3 Writing Hardening

SpellChecker `3.3.0+26` extends the deterministic local writing subsystem without changing its privacy model, correction-safety contract, preference storage format, or Portable settings format.

## Scope

V3.3 adds one built-in English writing rule, `missing-colon-space`, and strengthens repository documentation validation.

The release intentionally does not add cloud analysis, generative rewriting, automatic language detection, document persistence, or untrusted dynamic plugin execution.

## New rule: `missing-colon-space`

The rule detects a colon between Unicode letter clusters when the following word starts immediately after the colon.

Examples within scope:

```text
Topic:details
Résumé:details
Label :value
```

The finding owns only the colon source range and proposes `: ` as its replacement. Whitespace before the colon remains owned by `punctuation-spacing`.

That ownership makes the two fixes adjacent rather than overlapping. For `Label :value`, deterministic batch correction can remove the preceding space and add the following space in one batch, producing `Label: value` with no overlap skip.

## Conservative exclusions

The rule requires a Unicode letter immediately after the colon. It therefore does not report common numeric, URL, double-colon, or already-spaced structures such as:

```text
12:30
https://example.com
key::value
Topic: details
```

This is a bounded mechanics rule, not a general parser for prose, source code, URLs, templates, or structured data.

## Registry and defaults

`WritingRuleRegistry.builtIns` now contains eleven rules. `missing-colon-space` is enabled by default when no explicit per-language writing-rule override exists and the selected language pack is English-compatible.

Existing explicit rule sets remain explicit. A stored V3.2 ten-rule override does not silently gain the V3.3 rule. Using **Reset rules to defaults** removes the override and adopts the current eleven-rule registry defaults.

## Persistence and transfer compatibility

No persistence migration is required.

- writing-rule preference key format remains `spellchecker.writing_rule_ids.v1.<languageId>`;
- Portable settings remains `spellchecker-settings` version 1;
- unknown future rule IDs remain round-trippable under the existing codec contract;
- explicit empty and explicit non-empty rule-set semantics are unchanged.

## Bounded analysis

The new rule participates in the existing bounded analyzer contract. Analyzer-produced results continue to retain at most the requested finding limit while calculating exact overall and per-rule totals across all analyzed findings.

Regression coverage verifies that truncated colon analysis reports both retained counts and exact `totalIssueCountByRule` metadata.

## Documentation hardening

V3.3 adds executable repository checks that:

- validate relative Markdown links between documentation files;
- compare current language documentation against `SpellLanguageRegistry.builtIns`;
- compare current writing-rule documentation against `WritingRuleRegistry.builtIns`.

This reduces reliance on manually duplicated registry lists when languages or writing rules change.

## Compatibility validation

V3.3 regression coverage includes:

- direct rule detection and correction;
- Unicode letter-cluster behavior;
- conservative exclusions;
- adjacent source-range ownership with `punctuation-spacing`;
- independent rule disabling;
- bounded-analysis exact totals;
- per-language preference persistence;
- V3.2 explicit-rule override behavior in the Writing insights UI;
- Portable settings round-trip behavior;
- documentation-to-registry consistency.

## Privacy and security

The new rule executes entirely in local process memory against caller-supplied text. It adds no network request, telemetry, account, remote logging, dynamic code download, or persistent editor-text storage.

## Release checklist

Before merging V3.3, the branch should satisfy the existing repository gates:

- formatting/static analysis;
- complete Flutter test suite;
- documentation repository checks;
- deterministic benchmark smoke where configured;
- tracked-file inventory synchronization;
- current-version documentation synchronization.

## Related documentation

- [Feature reference](FEATURES.md)
- [Writing rules](WRITING_RULES.md)
- [Configuration](CONFIGURATION.md)
- [Testing](TESTING.md)
- [Release history](RELEASE_HISTORY.md)
- [Roadmap](ROADMAP.md)
