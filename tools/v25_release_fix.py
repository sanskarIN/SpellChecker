from pathlib import Path

path = Path('lib/features/editor/spell_checker_page.dart')
text = path.read_text()

old = '''            if (widget.resultsTruncated) ...<Widget>[
              const SizedBox(height: 8),
              _ResultLimitNotice(issueLimit: widget.issueLimit),
            ],
            const SizedBox(height: 10),
            Expanded(child: _buildContent(context)),
'''
new = '''            const SizedBox(height: 10),
            Expanded(child: _buildContent(context)),
'''
if text.count(old) != 1:
    raise RuntimeError('Expected one fixed-height result notice block')
text = text.replace(old, new, 1)

old = '''    return ListView.separated(
      itemCount: widget.issues.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final issue = widget.issues[index];
        final isActive = index == widget.activeIssueIndex;
        return KeyedSubtree(
          key: _keyFor(issue),
          child: _IssueTile(
            issue: issue,
            index: index,
            totalIssues: widget.issues.length,
            occurrenceCount: widget.occurrenceCount(issue),
            allowReplaceAll: !widget.resultsTruncated,
            isActive: isActive,
            onActivate: () => widget.onActivate(index),
            onReplace: (String suggestion) =>
                widget.onReplace(issue, suggestion),
            onReplaceAll: (String suggestion) =>
                widget.onReplaceAll(issue, suggestion),
            onAddToDictionary: () => widget.onAddToDictionary(issue),
            onIgnore: () => widget.onIgnore(issue),
          ),
        );
      },
    );
'''
new = '''    final resultOffset = widget.resultsTruncated ? 1 : 0;
    return ListView.separated(
      itemCount: widget.issues.length + resultOffset,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        if (widget.resultsTruncated && index == 0) {
          return _ResultLimitNotice(issueLimit: widget.issueLimit);
        }

        final issueIndex = index - resultOffset;
        final issue = widget.issues[issueIndex];
        final isActive = issueIndex == widget.activeIssueIndex;
        return KeyedSubtree(
          key: _keyFor(issue),
          child: _IssueTile(
            issue: issue,
            index: issueIndex,
            totalIssues: widget.issues.length,
            occurrenceCount: widget.occurrenceCount(issue),
            allowReplaceAll: !widget.resultsTruncated,
            isActive: isActive,
            onActivate: () => widget.onActivate(issueIndex),
            onReplace: (String suggestion) =>
                widget.onReplace(issue, suggestion),
            onReplaceAll: (String suggestion) =>
                widget.onReplaceAll(issue, suggestion),
            onAddToDictionary: () => widget.onAddToDictionary(issue),
            onIgnore: () => widget.onIgnore(issue),
          ),
        );
      },
    );
'''
if text.count(old) != 1:
    raise RuntimeError('Expected one transformed spelling issue ListView block')
text = text.replace(old, new, 1)

path.write_text(text)
print('V2.5 limited-results list layout repaired successfully.')
