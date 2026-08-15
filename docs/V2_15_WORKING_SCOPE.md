# V2.15 Working Scope

This temporary branch-only scope record defines the functional acceptance boundary while V2.15 is under active implementation. It must be removed before the permanent release diff is merged.

## Milestone

V2.15 adds a tenth built-in writing rule, `UnmatchedCurlyBraceRule`, with stable ID `unmatched-curly-brace`.

## Required behavior

- Balance literal `{` and `}` characters iteratively and deterministically.
- Support nested balanced pairs.
- Report unmatched opening and closing braces in source order.
- Own exactly one UTF-16 code unit for each ASCII brace finding.
- Preserve correct UTF-16 offsets around non-BMP text.
- Remain advisory-only with warning severity and no guessed replacement.
- Keep parenthesis, square-bracket, and curly-brace ownership independent.
- Support both built-in English variants.

## Integration boundary

- Publicly export the rule through `package:spellchecker/writing.dart`.
- Register it as the tenth built-in/default writing rule.
- Preserve explicit V2.14 nine-rule overrides without silently adding V2.15.
- Let unset/reset preferences adopt the ten-rule default registry.
- Preserve Portable-settings format/version and old explicit override semantics.
- Integrate with bounded exact totals, diagnostic summaries, benchmark identity, review filters, and the editor.
- Keep automatic-fixes-only behavior truthful by excluding the advisory finding.
- Keep batch correction safe by skipping the rule while applying independent deterministic fixes.

## Release boundary

Before merge, this working-scope file must be replaced by permanent behavior/final-validation documentation, package/About identity must advance to `2.15.0+20` / `2.15.0`, `what_changed.md` and all release surfaces must be synchronized, package-aware formatting must be clean, permanent CI must pass, an independent release-mode web gate must pass, all disposable V2.15 helpers must be absent from the permanent diff, and the implementation must merge normally so granular history is preserved.
