import 'package:flutter/material.dart';

import '../../core/spell_language_pack.dart';
import '../../writing/writing_analyzer.dart';
import '../../writing/writing_issue.dart';
import '../../writing/writing_rule.dart';

class WritingInsightsDialogResult {
  WritingInsightsDialogResult({
    required Iterable<String> enabledRuleIds,
    this.issueToFix,
  }) : enabledRuleIds = Set<String>.unmodifiable(enabledRuleIds);

  final Set<String> enabledRuleIds;
  final WritingIssue? issueToFix;
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
  late Set<String> _enabledRuleIds;

  @override
  void initState() {
    super.initState();
    _enabledRuleIds = Set<String>.from(widget.initialEnabledRuleIds);
  }

  WritingAnalysisResult get _analysis => widget.analyzer.analyze(
        widget.text,
        languagePack: widget.languagePack,
        enabledRuleIds: _enabledRuleIds,
      );

  List<WritingRule> get _supportedRules => widget.analyzer.rules
      .where((WritingRule rule) => rule.supports(widget.languagePack))
      .toList(growable: false);

  void _toggleRule(String ruleId, bool enabled) {
    setState(() {
      if (enabled) {
        _enabledRuleIds.add(ruleId);
      } else {
        _enabledRuleIds.remove(ruleId);
      }
    });
  }

  void _close({WritingIssue? issueToFix}) {
    Navigator.of(context).pop(
      WritingInsightsDialogResult(
        enabledRuleIds: _enabledRuleIds,
        issueToFix: issueToFix,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;
    final rules = _supportedRules;

    return AlertDialog(
      title: Row(
        children: <Widget>[
          const Icon(Icons.auto_fix_high_outlined),
          const SizedBox(width: 10),
          const Expanded(child: Text('Writing insights')),
        ],
      ),
      content: SizedBox(
        width: 620,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 620),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Text(
                '${widget.languagePack.displayName} • Local rules only',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Writing rules run on the current editor text in memory. Disable any rule you do not want to use for this session.',
              ),
              const SizedBox(height: 16),
              Text('Rules', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              for (final rule in rules)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(rule.displayName),
                  subtitle: Text(rule.description),
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
                  Badge(
                    label: Text('${analysis.issues.length}'),
                    child: const Icon(Icons.fact_check_outlined),
                  ),
                ],
              ),
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
                  message: 'No local writing rule reported an issue in this text.',
                )
              else
                for (var index = 0; index < analysis.issues.length; index++)
                  _WritingIssueTile(
                    issue: analysis.issues[index],
                    index: index,
                    total: analysis.issues.length,
                    onFix: analysis.issues[index].hasAutomaticFix
                        ? () => _close(issueToFix: analysis.issues[index])
                        : null,
                  ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => _close(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _WritingIssueTile extends StatelessWidget {
  const _WritingIssueTile({
    required this.issue,
    required this.index,
    required this.total,
    required this.onFix,
  });

  final WritingIssue issue;
  final int index;
  final int total;
  final VoidCallback? onFix;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Writing finding ${index + 1} of $total. ${issue.ruleName}. ${issue.message}',
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
