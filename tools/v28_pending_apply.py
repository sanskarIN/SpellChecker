# commit-message: fix: pluralize exact uncaptured finding message
from pathlib import Path

path = Path('lib/features/editor/writing_insights_dialog.dart')
text = path.read_text()
old = """                  message: analysis.isTruncated
                      ? analysis.uncapturedIssueCount == null
                            ? 'None of the captured findings match the current review filters. Additional uncaptured findings may exist.'
                            : 'None of the captured findings match the current review filters. ${analysis.uncapturedIssueCount} uncaptured findings were not searched.'
                      : 'The enabled rules have findings, but none match the current review filters.',
"""
new = """                  message: analysis.isTruncated
                      ? analysis.uncapturedIssueCount == null
                            ? 'None of the captured findings match the current review filters. Additional uncaptured findings may exist.'
                            : analysis.uncapturedIssueCount == 1
                            ? 'None of the captured findings match the current review filters. 1 uncaptured finding was not searched.'
                            : 'None of the captured findings match the current review filters. ${analysis.uncapturedIssueCount} uncaptured findings were not searched.'
                      : 'The enabled rules have findings, but none match the current review filters.',
"""
if text.count(old) != 1:
    raise SystemExit('Expected exactly one V2.8 filtered empty-state block.')
path.write_text(text.replace(old, new))
