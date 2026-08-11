# commit-message: docs: publish V2.7 README and web metadata
from pathlib import Path
import json

readme = Path('README.md')
text = readme.read_text()
highlight = '- Bounded large-document spelling analysis with an explicit first-200 issue UI policy and safe limited-result messaging.\n'
if text.count(highlight) != 1:
    raise SystemExit('Expected one bounded-spelling highlight.')
text = text.replace(
    highlight,
    highlight + '- Bounded Writing insights analysis with an explicit first-200 finding policy and captured-only limited-review wording.\n',
)
old_release = '''## Current release

`2.6.0+11`

Version 2.6 is the **Deterministic Writing Rule Expansion** release. It keeps the V2.5 bounded spelling contract and every existing persistence/correction safety guarantee while expanding the built-in English Writing insights catalogue with **Punctuation spacing** and **Trailing whitespace**. The specialized spacing rules own punctuation-adjacent and line/document-end whitespace ranges so batch correction does not produce conflicting collapse-versus-remove fixes. No persistence format, network behavior, or runtime dependency changes in V2.6.
'''
new_release = '''## Current release

`2.7.0+12`

Version 2.7 is the **Bounded Writing Analysis & Large-Document Review Safety** release. It keeps the V2.6 six-rule catalogue, V2.5 bounded spelling behavior, and every existing persistence/correction contract while adding optional bounded writing-result capture and a truthful 200-finding Writing insights policy. Limited review filters and batch actions operate on captured findings only. No persistence format, network behavior, or runtime dependency changes in V2.7.
'''
if text.count(old_release) != 1:
    raise SystemExit('Expected exactly one V2.6 current-release block.')
text = text.replace(old_release, new_release)
marker = '## Large-document spelling checks — V2.5\n'
if text.count(marker) != 1:
    raise SystemExit('Expected large-document spelling section marker.')
section = '''## Large-document Writing insights — V2.7

`WritingAnalyzer.analyze()` now accepts an optional positive `maxIssues` argument. Omitting it keeps the historical unbounded behavior. A bounded `WritingAnalysisResult` reports `issueLimit`, `isTruncated`, `isComplete`, and `capturedIssueCount`.

Bounded results keep the same earliest review-order prefix as unbounded analysis even when a later rule yields an earlier source range. Reaching the numerical cap alone is not truncation: `isTruncated` becomes true only after another finding is observed.

The built-in Writing insights dialog captures at most 200 findings. When overflow is proven it displays a limited notice, uses `200+`-style count semantics, and states that search/presets/category/fix filters operate on captured findings only. Batch labels become **Apply captured safe fixes (N)** or **Apply visible captured safe fixes (N)** so a partial result is never presented as a complete whole-document finding set.

Rules are still executed across the supplied text so the globally earliest captured prefix remains correct. The bound limits retained finding objects/dialog workload; it is not a CPU-time or maximum-document-size promise. See [Performance and large-document behavior](docs/PERFORMANCE.md).

'''
text = text.replace(marker, section + marker)
readme.write_text(text)

index = Path('web/index.html')
index_text = index.read_text()
old_index = 'portable non-document preferences, bounded large-document spelling results, filtered batch-safe local fixes'
new_index = 'portable non-document preferences, bounded large-document spelling and Writing insights results, captured-aware filtered batch-safe local fixes'
if index_text.count(old_index) != 1:
    raise SystemExit('Expected one web index description marker.')
index.write_text(index_text.replace(old_index, new_index))

manifest = Path('web/manifest.json')
manifest_text = manifest.read_text()
old_manifest = 'portable non-document preferences, bounded large-document spelling results, filtered batch-safe local fixes'
new_manifest = 'portable non-document preferences, bounded large-document spelling and Writing insights results, captured-aware filtered batch-safe local fixes'
if manifest_text.count(old_manifest) != 1:
    raise SystemExit('Expected one web manifest description marker.')
manifest_text = manifest_text.replace(old_manifest, new_manifest)
json.loads(manifest_text)
manifest.write_text(manifest_text)
