# V2.16 Final Bug Audit

SpellChecker V2.16 is the repository's final stabilization milestone. This record is regression-led: release identity remains at V2.15 until the corrected functional candidate passes permanent CI.

## Reproducible defects fixed in the functional candidate

1. **Unicode edit distance used UTF-16 code units.** Astral Unicode scalar insertion, deletion, substitution, and transposition could receive inflated edit costs. The public Damerau-Levenshtein implementation now operates on Unicode scalar values.
2. **Suggestion eligibility used UTF-16 lengths.** Maximum-distance selection and candidate length-difference filtering now use scalar lengths consistently with edit distance; prefix metadata also compares complete scalars.
3. **Decomposed combining-mark words were split.** Built-in English tokenization now keeps a letter plus following combining marks in one word cluster.
4. **Common decomposed Latin loanwords did not match precomposed bundled words.** The English normalizer deterministically composes the common Latin accent sequences covered by the bundled vocabulary without adding a runtime dependency.
5. **Text statistics split decomposed words.** Word counting now uses the same letter-plus-combining-mark boundary.
6. **Malformed personal-dictionary version metadata could be interpreted as legacy V1.** A present non-integer version is now rejected while a genuinely omitted version retains legacy compatibility.
7. **Portable Settings silently deduplicated duplicate writing-rule IDs.** Duplicate external IDs now fail closed with a format error.
8. **Preference writes ignored the platform success result.** Language, vocabulary, writing-rule, suggestion-limit, removal, and migration writes now throw when local preference storage reports failure, allowing existing UI recovery/error paths to remain truthful.
9. **An early spelling check could remain based on temporary defaults after saved preferences loaded.** Checked results are refreshed after successful preference restoration, and Writing Insights cannot mutate rule state while restoration is pending.
10. **Case-preserving correction split surrogate pairs and could misclassify uncased text.** Case matching now operates on complete Unicode scalars and only applies uppercase/title behavior when actual cased characters support it.
11. **The public Damerau-Levenshtein function implemented the restricted optimal-string-alignment recurrence.** Its name promises unrestricted Damerau-Levenshtein distance, where interacting edits may reuse characters. The implementation now uses the unrestricted last-seen-row/column recurrence and locks the canonical `CA` → `ABC` distance of 2, including Unicode-scalar coverage.
12. **Ignore-once could mutate the temporary startup engine.** An early spelling check could expose an Ignore action before durable preferences finished restoring; the ignored word would then disappear when the real engine replaced the temporary one. Ignore-once now refuses to mutate session state until restoration completes and reports the shared loading status instead.

## Audited stable behavior intentionally unchanged

- Writing-analysis per-rule exact-total maps remain sparse for zero-finding rules; diagnostic summaries already reconstruct analyzed zero rows. Existing tests define this as intentional behavior.
- Portable Settings remains document/vocabulary-free and version 1.
- Personal dictionary V1 missing-version compatibility remains accepted deliberately.
- Direct runtime dependencies remain Flutter and `shared_preferences`; V2.16 has not added a Unicode normalization package or network service.

## Release blockers still required

The candidate must pass canonical formatting, `flutter analyze`, the complete Flutter test suite, benchmark smoke, continued repository-wide defect review, synchronized release/documentation metadata including `what_changed.md`, removal of the temporary working scope and all disposable helpers, an independent release-mode web build/audit, normal history-preserving merge, and final default-branch CI.
