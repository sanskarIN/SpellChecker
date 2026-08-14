import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/spell_language_pack.dart';
import '../../writing/writing_analysis_diagnostic_summary.dart';
import '../../writing/writing_analyzer.dart';
import '../../writing/writing_issue.dart';
import '../../writing/writing_review_preset.dart';
import '../../writing/writing_review_query.dart';
import '../../writing/writing_rule.dart';
import '../../writing/writing_rule_category.dart';

class WritingInsightsDialogResult {
  WritingInsightsDialogResult({
    required Iterable<String> enabledRuleIds,
    this.issueToFix,
    Iterable<WritingIssue> issuesToFix = const <WritingIssue>[],
    this.resetRulePreferences = false,
  }) : enabledRuleIds = Set<String>.unmodifiable(enabledRuleIds),
       issuesToFix = List<WritingIssue>.unmodifiable(issuesToFix);

  final Set<String> enabledRuleIds;
  final WritingIssue? issueToFix;
  final List<WritingIssue> issuesToFix;
  final bool resetRulePreferences;
}

class WritingInsightsDialog extends StatefulWidget {
  WritingInsightsDialog({
    super.key,
    required this.text,
    required this.languagePack,
    required this.analyzer,
    required this.initialEnabledRuleIds,
    int maxIssues = defaultMaxIssues,
  }) : maxIssues = _validateMaxIssues(maxIssues);

  static const int defaultMaxIssues = 200;

  static int _validateMaxIssues(int value) {
    if (value <= 0) {
      throw ArgumentError.value(value, 'maxIssues', 'must be positive');
    }
    return value;
  }

  final String text;
  final SpellLanguagePack languagePack;
  final WritingAnalyzer analyzer;
  final Set<String> initialEnabledRuleIds;
  final int maxIssues;

  @override
  State<WritingInsightsDialog> createState() => _WritingInsightsDialogState();
}

class _WritingInsightsDialogState extends State<WritingInsightsDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(
    debugLabel: 'writing-review-search',
  );

  late Set<String> _enabledRuleIds;
  final Set<WritingRuleCategory> _categories = <WritingRuleCategory>{};
  bool _automaticFixesOnly = false;

  @override
  void initState() {
    super.initState();
    _enabledRuleIds = Set<String>.from(widget.initialEnabledRuleIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  WritingAnalysisResult get _analysis => widget.analyzer.analyze(
    widget.text,
    languagePack: widget.languagePack,
    enabledRuleIds: _enabledRuleIds,
    maxIssues: widget.maxIssues,
  );

  List<WritingRule> get _supportedRules => widget.analyzer.rules
      .where((WritingRule rule) => rule.supports(widget.languagePack))
      .toList(growable: false);

  WritingReviewQuery get _query => WritingReviewQuery(
    search: _searchController.text,
    categories: _categories,
    automaticFixesOnly: _automaticFixesOnly,
  );

  void _toggleRule(String ruleId, bool enabled) {
    setState(() {
      if (enabled) {
        _enabledRuleIds.add(ruleId);
      } else {
        _enabledRuleIds.remove(ruleId);
      }
    });
  }

  bool _matchesPreset(WritingReviewPreset preset) {
    return _automaticFixesOnly == preset.automaticFixesOnly &&
        _categories.length == preset.categories.length &&
        _categories.containsAll(preset.categories);
  }

  void _applyPreset(WritingReviewPreset preset) {
    setState(() {
      _categories
        ..clear()
        ..addAll(preset.categories);
      _automaticFixesOnly = preset.automaticFixesOnly;
    });
  }

  void _toggleCategory(WritingRuleCategory category, bool selected) {
    setState(() {
      if (selected) {
        _categories.add(category);
      } else {
        _categories.remove(category);
      }
    });
  }

  void _clearReviewFilters() {
    _searchController.clear();
    setState(() {
      _categories.clear();
      _automaticFixesOnly = false;
    });
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
  }

  void _handleEscape() {
    if (!_query.isEmpty) {
      _clearReviewFilters();
      _searchFocusNode.requestFocus();
      return;
    }
    _close();
  }

  Future<void> _copyDiagnosticSummary() async {
    final summary = WritingAnalysisDiagnosticSummary.fromResult(
      _analysis,
      rules: _supportedRules,
    ).toPlainText();
    await Clipboard.setData(ClipboardData(text: summary));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Diagnostic summary copied. Editor text and finding excerpts were excluded.',
        ),
      ),
    );
  }

  void _close({
    WritingIssue? issueToFix,
    Iterable<WritingIssue> issuesToFix = const <WritingIssue>[],
    bool resetRulePreferences = false,
  }) {
    Navigator.of(context).pop(
      WritingInsightsDialogResult(
        enabledRuleIds: _enabledRuleIds,
        issueToFix: issueToFix,
        issuesToFix: issuesToFix,
        resetRulePreferences: resetRulePreferences,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;
    final supportedRules = _supportedRules;
    final ruleById = <String, WritingRule>{
      for (final rule in supportedRules) rule.id: rule,
    };
    final query = _query;
    final visibleRules = query.filterRules(supportedRules);
    final visibleIssues = query.filterIssues(
      analysis.issues,
      rules: supportedRules,
    );
    final visibleAutomaticIssues = visibleIssues
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

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _focusSearch,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
            _focusSearch,
        const SingleActivator(LogicalKeyboardKey.escape): _handleEscape,
      },
      child: Focus(
        autofocus: true,
        child: AlertDialog(
          title: const Row(
          children: <Widget>[
            Icon(Icons.auto_fix_high_outlined),
            SizedBox(width: 10),
            Expanded(child: Text('Writing insights')),
          ],
        ),
        content: SizedBox(
          width: 680,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 650),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  '${widget.languagePack.displayName} • Local rules only',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Writing rules run on the current editor text in memory. Rule choices are stored locally for the selected language; review presets, search, and filters are temporary.',
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey<String>('writing-review-search'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Search rules and findings',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear review search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Review preset',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final preset in WritingReviewPreset.values)
                      ChoiceChip(
                        key: ValueKey<String>('writing-preset-${preset.id}'),
                        label: Text(preset.displayName),
                        selected: _matchesPreset(preset),
                        onSelected: (_) => _applyPreset(preset),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final category in WritingRuleCategory.values)
                      FilterChip(
                        key: ValueKey<String>(
                          'writing-category-${category.name}',
                        ),
                        label: Text(category.displayName),
                        selected: _categories.contains(category),
                        onSelected: (bool selected) =>
                            _toggleCategory(category, selected),
                      ),
                  ],
                ),
                SwitchListTile(
                  key: const ValueKey<String>('automatic-fixes-only'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Automatic fixes only'),
                  subtitle: const Text(
                    'Hide advisory findings that have no deterministic replacement.',
                  ),
                  value: _automaticFixesOnly,
                  onChanged: (bool value) {
                    setState(() => _automaticFixesOnly = value);
                  },
                ),
                if (!query.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const ValueKey<String>(
                        'clear-writing-review-filters',
                      ),
                      onPressed: _clearReviewFilters,
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Clear review filters'),
                    ),
                  ),
                const Divider(height: 28),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Rules',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Semantics(
                      key: const ValueKey<String>(
                        'writing-rules-visible-count',
                      ),
                      liveRegion: true,
                      label:
                          '${visibleRules.length} visible rules of ${supportedRules.length}',
                      child: ExcludeSemantics(
                        child: Text(
                          '${visibleRules.length}/${supportedRules.length}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (visibleRules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No rules match the current review filters.'),
                  )
                else
                  for (final rule in visibleRules)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(rule.displayName),
                      subtitle: Text(ruleSubtitle(rule)),
                      value: _enabledRuleIds.contains(rule.id),
                      onChanged: (bool value) => _toggleRule(rule.id, value),
                    ),
                const Divider(height: 28),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Findings',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                      key: const ValueKey<String>('copy-writing-diagnostics'),
                      tooltip: 'Copy diagnostic summary',
                      onPressed: _copyDiagnosticSummary,
                      icon: const Icon(Icons.copy_all_outlined),
                    ),
                    Semantics(
                      key: const ValueKey<String>(
                        'writing-findings-visible-count',
                      ),
                      liveRegion: true,
                      label: analysis.isTruncated
                          ? analysis.totalIssueCount == null
                                ? '${visibleIssues.length} visible findings. ${analysis.capturedIssueCount} captured findings, with additional uncaptured findings.'
                                : '${visibleIssues.length} visible findings. ${analysis.capturedIssueCount} captured of ${analysis.totalIssueCount} total findings.'
                          : '${visibleIssues.length} visible findings of ${analysis.capturedIssueCount} captured findings.',
                      child: ExcludeSemantics(
                        child: Text(
                          analysis.isTruncated
                              ? '${visibleIssues.length}/${analysis.capturedIssueCount} captured'
                              : '${visibleIssues.length}/${analysis.capturedIssueCount}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message:
                          analysis.isTruncated &&
                              analysis.totalIssueCount != null
                          ? '${analysis.capturedIssueCount} captured of ${analysis.totalIssueCount} total findings'
                          : '${visibleIssues.length} visible findings',
                      child: Badge(
                        key: const ValueKey<String>(
                          'writing-findings-total-badge',
                        ),
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
                  ],
                ),
                if (analysis.isTruncated) ...<Widget>[
                  const SizedBox(height: 10),
                  _WritingAnalysisLimitNotice(
                    capturedCount: analysis.capturedIssueCount,
                    issueLimit: analysis.issueLimit!,
                    totalIssueCount: analysis.totalIssueCount,
                  ),
                ],
                if (visibleAutomaticIssues.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    key: const ValueKey<String>('apply-all-writing-fixes'),
                    onPressed: () =>
                        _close(issuesToFix: visibleAutomaticIssues),
                    icon: const Icon(Icons.auto_fix_high),
                    label: Text(
                      analysis.isTruncated
                          ? query.isEmpty
                                ? 'Apply captured safe fixes (${visibleAutomaticIssues.length})'
                                : 'Apply visible captured safe fixes (${visibleAutomaticIssues.length})'
                          : query.isEmpty
                          ? 'Apply all safe fixes (${visibleAutomaticIssues.length})'
                          : 'Apply visible safe fixes (${visibleAutomaticIssues.length})',
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (widget.text.trim().isEmpty)
                  const _WritingEmptyState(
                    icon: Icons.edit_note,
                    title: 'Nothing to analyse',
                    message: 'Add editor text before running writing insights.',
                  )
                else if (analysis.issues.isEmpty)
                  const _WritingEmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'No enabled-rule findings',
                    message:
                        'No local writing rule reported an issue in this text.',
                  )
                else if (visibleIssues.isEmpty)
                  _WritingEmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: analysis.isTruncated
                        ? 'No matching captured findings'
                        : 'No matching findings',
                    message: analysis.isTruncated
                        ? analysis.uncapturedIssueCount == null
                              ? 'None of the captured findings match the current review filters. Additional uncaptured findings may exist.'
                              : analysis.uncapturedIssueCount == 1
                              ? 'None of the captured findings match the current review filters. 1 uncaptured finding was not searched.'
                              : 'None of the captured findings match the current review filters. ${analysis.uncapturedIssueCount} uncaptured findings were not searched.'
                        : 'The enabled rules have findings, but none match the current review filters.',
                  )
                else
                  for (var index = 0; index < visibleIssues.length; index++)
                    _WritingIssueTile(
                      issue: visibleIssues[index],
                      index: index,
                      total: visibleIssues.length,
                      category:
                          ruleById[visibleIssues[index].ruleId]?.category ??
                          WritingRuleCategory.mechanics,
                      onFix: visibleIssues[index].hasAutomaticFix
                          ? () => _close(issueToFix: visibleIssues[index])
                          : null,
                    ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton.icon(
            key: const ValueKey<String>('reset-writing-rules'),
            onPressed: () => _close(resetRulePreferences: true),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset rules to defaults'),
          ),
          TextButton(onPressed: () => _close(), child: const Text('Close')),
        ],
        ),
      ),
    );
  }
}

class _WritingAnalysisLimitNotice extends StatelessWidget {
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

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Writing analysis limited. $message',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.info_outline),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WritingIssueTile extends StatelessWidget {
  const _WritingIssueTile({
    required this.issue,
    required this.index,
    required this.total,
    required this.category,
    required this.onFix,
  });

  final WritingIssue issue;
  final int index;
  final int total;
  final WritingRuleCategory category;
  final VoidCallback? onFix;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Writing finding ${index + 1} of $total. ${category.displayName}. ${issue.ruleName}. ${issue.message}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      issue.ruleName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(category.displayName),
                  const SizedBox(width: 8),
                  Text('${issue.start}–${issue.end}'),
                ],
              ),
              const SizedBox(height: 6),
              Text(issue.message),
              const SizedBox(height: 6),
              SelectableText(
                'Text: ${issue.originalText.replaceAll('\n', '↵')}',
              ),
              if (issue.replacement != null) ...<Widget>[
                const SizedBox(height: 8),
                Text('Suggested replacement: “${issue.replacement}”'),
              ],
              if (onFix != null) ...<Widget>[
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: onFix,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Apply safe fix'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WritingEmptyState extends StatelessWidget {
  const _WritingEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: '$title. $message',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 34),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
