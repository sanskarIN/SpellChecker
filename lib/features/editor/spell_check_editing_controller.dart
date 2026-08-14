import 'package:flutter/material.dart';

import '../../core/spell_issue.dart';

class SpellCheckEditingController extends TextEditingController {
  SpellCheckEditingController({super.text});

  List<SpellIssue> _issues = const <SpellIssue>[];
  int _activeIssueIndex = -1;

  List<SpellIssue> get issues => List<SpellIssue>.unmodifiable(_issues);
  int get activeIssueIndex => _activeIssueIndex;

  void setIssues(List<SpellIssue> issues, {int activeIssueIndex = -1}) {
    _issues = List<SpellIssue>.unmodifiable(issues);
    _activeIssueIndex = _normalizeActiveIndex(activeIssueIndex, _issues.length);
    notifyListeners();
  }

  void setActiveIssue(int index) {
    final normalized = _normalizeActiveIndex(index, _issues.length);
    if (normalized == _activeIssueIndex) {
      return;
    }
    _activeIssueIndex = normalized;
    notifyListeners();
  }

  void clearIssues() {
    if (_issues.isEmpty && _activeIssueIndex == -1) {
      return;
    }
    _issues = const <SpellIssue>[];
    _activeIssueIndex = -1;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (_issues.isEmpty ||
        text.isEmpty ||
        _hasActiveComposingRange(withComposing)) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final baseStyle = style ?? const TextStyle();
    final colorScheme = Theme.of(context).colorScheme;
    final issueStyle = baseStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: colorScheme.error,
      decorationStyle: TextDecorationStyle.wavy,
      decorationThickness: 1.5,
    );
    final activeStyle = issueStyle.copyWith(
      color: colorScheme.onErrorContainer,
      backgroundColor: colorScheme.errorContainer,
      fontWeight: FontWeight.w600,
    );

    final sorted =
        <_IndexedSpellIssue>[
          for (var index = 0; index < _issues.length; index++)
            _IndexedSpellIssue(index: index, issue: _issues[index]),
        ]..sort(
          (_IndexedSpellIssue a, _IndexedSpellIssue b) =>
              a.issue.start.compareTo(b.issue.start),
        );

    final children = <InlineSpan>[];
    var cursor = 0;

    for (final entry in sorted) {
      final issue = entry.issue;
      if (!_isValidIssue(issue, cursor)) {
        continue;
      }

      if (issue.start > cursor) {
        children.add(TextSpan(text: text.substring(cursor, issue.start)));
      }

      children.add(
        TextSpan(
          text: text.substring(issue.start, issue.end),
          style: entry.index == _activeIssueIndex ? activeStyle : issueStyle,
        ),
      );
      cursor = issue.end;
    }

    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor)));
    }

    return TextSpan(style: baseStyle, children: children);
  }

  bool _hasActiveComposingRange(bool withComposing) {
    final composing = value.composing;
    return withComposing &&
        composing.isValid &&
        !composing.isCollapsed &&
        composing.start >= 0 &&
        composing.end <= text.length;
  }

  bool _isValidIssue(SpellIssue issue, int cursor) {
    return issue.start >= cursor &&
        issue.start >= 0 &&
        issue.end > issue.start &&
        issue.end <= text.length &&
        text.substring(issue.start, issue.end) == issue.word;
  }

  static int _normalizeActiveIndex(int index, int length) {
    if (length == 0 || index < 0 || index >= length) {
      return -1;
    }
    return index;
  }
}

class _IndexedSpellIssue {
  const _IndexedSpellIssue({required this.index, required this.issue});

  final int index;
  final SpellIssue issue;
}
