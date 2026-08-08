import 'package:flutter/material.dart';

import '../../core/spell_language_pack.dart';
import '../../writing/writing_analyzer.dart';
import '../../writing/writing_issue.dart';
import '../../writing/writing_review_query.dart';
import '../../writing/writing_rule.dart';
import '../../writing/writing_rule_category.dart';

class WritingInsightsDialogResult {
  WritingInsightsDialogResult({
    required Iterable<String> enabledRuleIds,
    this.issueToFix,
    Iterable<WritingIssue> issuesToFix = const <WritingIssue>[],
    this.resetRulePreferences = false,
  })  : enabledRuleIds = Set<String>.unmodifiable(enabledRuleIds),
        issuesToFix = List<WritingIssue>.unmodifiable(issuesToFix);

  final Set<String> enabledRuleIds;
  final WritingIssue? issueToFix;
  final List<WritingIssue> issuesToFix;
  final bool resetRulePreferences;
}

class WritingInsightsDialog extends StatefulWidget {
  const WritingInsightsDialog({
    super.key,
    required this.text,
    required this.languagePack,
    required this.analyzer,
    required this.initialEnabledRuleIds,
  });

  final String text;
  final SpellLanguagePack languagePack;
  final WritingAnalyzer analyzer;
  final Set<String> initialEnabledRuleIds;

  @override
  State<WritingInsightsDialog> createState() => _WritingInsightsDialogState();
}

class _WritingInsightsDialogState extends State<WritingInsightsDialog> {
  final TextEditingController _searchController = TextEditingController();

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
    super.dispose();
  }

  WritingAnalysisResult get _analysis => widget.analyzer.analyze(
        widget.text,
        languagePack: widget.languagePack,
        enabledRuleIds: _enabledRuleIds,
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

    return AlertDialog(
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
                'Writing rules run on the current editor text in memory. Rule choices are stored locally for the selected language; review filters are temporary.',
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey<String>('writing-review-search'),
                controller: _searchController,
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
                    key: const ValueKey<String>('clear-writing-review-filters'),
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
                  Text('${visibleRules.length}/${supportedRules.length}'),
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
                    subtitle: Text(
                      '${rule.category.displayName} • ${rule.description}',
                    ),
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
                  Text('${visibleIssues.length}/${analysis.issues.length}'),
                  const SizedBox(width: 8),
                  Badge(
                    label: Text('${visibleIssues.length}'),
                    child: const Icon(Icons.fact_check_outlined),
                  ),
                ],
              ),
              if (visibleAutomaticIssues.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  key: const ValueKey<String>('apply-all-writing-fixes'),
                  onPressed: () =>
                      _close(issuesToFix: visibleAutomaticIssues),
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(
                    query.isEmpty
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
                const _WritingEmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: 'No matching findings',
                  message:
                      'The enabled rules have findings, but none match the current review filters.',
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
