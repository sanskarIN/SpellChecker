# commit-message: feat: show exact Writing insights diagnostic totals
from pathlib import Path

path = Path('lib/features/editor/writing_insights_dialog.dart')
text = path.read_text()

old_auto = '''    final visibleAutomaticIssues = visibleIssues
        .where((WritingIssue issue) => issue.hasAutomaticFix)
        .toList(growable: false);

    return AlertDialog(
'''
new_auto = '''    final visibleAutomaticIssues = visibleIssues
        .where((WritingIssue issue) => issue.hasAutomaticFix)
        .toList(growable: false);

    String ruleSubtitle(WritingRule rule) {
      final base = '${rule.category.displayName} • ${rule.description}';
      final total = analysis.totalIssueCountByRule?[rule.id];
      if (!_enabledRuleIds.contains(rule.id) || total == null) {
        return base;
      }
      return '$base • Total findings: $total';
    }

    return AlertDialog(
'''
if text.count(old_auto) != 1:
    raise SystemExit('Expected one visibleAutomaticIssues marker.')
text = text.replace(old_auto, new_auto)

old_subtitle = '''                    subtitle: Text(
                      '${rule.category.displayName} • ${rule.description}',
                    ),
'''
new_subtitle = '''                    subtitle: Text(ruleSubtitle(rule)),
'''
if text.count(old_subtitle) != 1:
    raise SystemExit('Expected one rule subtitle marker.')
text = text.replace(old_subtitle, new_subtitle)

old_counts = '''                  Text(
                    '${visibleIssues.length}/${analysis.capturedIssueCount}${analysis.isTruncated ? '+' : ''}',
                  ),
                  const SizedBox(width: 8),
                  Badge(
                    label: Text(
                      analysis.isTruncated && query.isEmpty
                          ? '${analysis.capturedIssueCount}+'
                          : '${visibleIssues.length}',
                    ),
                    child: const Icon(Icons.fact_check_outlined),
                  ),
'''
new_counts = '''                  Text(
                    analysis.isTruncated
                        ? '${visibleIssues.length}/${analysis.capturedIssueCount} captured'
                        : '${visibleIssues.length}/${analysis.capturedIssueCount}',
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: analysis.isTruncated &&
                            analysis.totalIssueCount != null
                        ? '${analysis.capturedIssueCount} captured of ${analysis.totalIssueCount} total findings'
                        : '${visibleIssues.length} visible findings',
                    child: Badge(
                      label: Text(
                        analysis.isTruncated && query.isEmpty
                            ? analysis.totalIssueCount == null
                                  ? '${analysis.capturedIssueCount}+'
                                  : '${analysis.capturedIssueCount}/${analysis.totalIssueCount}'
                            : '${visibleIssues.length}',
                      ),
                      child: const Icon(Icons.fact_check_outlined),
                    ),
                  ),
'''
if text.count(old_counts) != 1:
    raise SystemExit('Expected one findings count block.')
text = text.replace(old_counts, new_counts)

old_notice_call = '''                _WritingAnalysisLimitNotice(
                  capturedCount: analysis.capturedIssueCount,
                  issueLimit: analysis.issueLimit!,
                ),
'''
new_notice_call = '''                _WritingAnalysisLimitNotice(
                  capturedCount: analysis.capturedIssueCount,
                  issueLimit: analysis.issueLimit!,
                  totalIssueCount: analysis.totalIssueCount,
                ),
'''
if text.count(old_notice_call) != 1:
    raise SystemExit('Expected one limit notice call.')
text = text.replace(old_notice_call, new_notice_call)

old_empty = '''                  message: analysis.isTruncated
                      ? 'None of the captured findings match the current review filters. Additional uncaptured findings may exist.'
                      : 'The enabled rules have findings, but none match the current review filters.',
'''
new_empty = '''                  message: analysis.isTruncated
                      ? analysis.uncapturedIssueCount == null
                            ? 'None of the captured findings match the current review filters. Additional uncaptured findings may exist.'
                            : 'None of the captured findings match the current review filters. ${analysis.uncapturedIssueCount} uncaptured findings were not searched.'
                      : 'The enabled rules have findings, but none match the current review filters.',
'''
if text.count(old_empty) != 1:
    raise SystemExit('Expected one limited empty-state message.')
text = text.replace(old_empty, new_empty)

old_notice = '''class _WritingAnalysisLimitNotice extends StatelessWidget {
  const _WritingAnalysisLimitNotice({
    required this.capturedCount,
    required this.issueLimit,
  });

  final int capturedCount;
  final int issueLimit;

  @override
  Widget build(BuildContext context) {
    final message =
        'Showing the first $capturedCount findings in review order. More findings exist beyond the $issueLimit-finding capture limit. Review filters and batch actions use captured findings only.';

'''
new_notice = '''class _WritingAnalysisLimitNotice extends StatelessWidget {
  const _WritingAnalysisLimitNotice({
    required this.capturedCount,
    required this.issueLimit,
    required this.totalIssueCount,
  });

  final int capturedCount;
  final int issueLimit;
  final int? totalIssueCount;

  @override
  Widget build(BuildContext context) {
    final total = totalIssueCount;
    final uncaptured = total == null ? null : total - capturedCount;
    final omittedLabel = uncaptured == null
        ? null
        : uncaptured == 1
        ? '1 additional finding is'
        : '$uncaptured additional findings are';
    final message = total == null
        ? 'Showing the first $capturedCount findings in review order. More findings exist beyond the $issueLimit-finding capture limit. Review filters and batch actions use captured findings only.'
        : 'Showing the first $capturedCount of $total findings in review order. $omittedLabel not retained by the $issueLimit-finding capture limit. Review filters and batch actions use captured findings only.';

'''
if text.count(old_notice) != 1:
    raise SystemExit('Expected one WritingAnalysisLimitNotice block.')
text = text.replace(old_notice, new_notice)

path.write_text(text)
