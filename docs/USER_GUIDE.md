# User Guide

## Opening SpellChecker

Run the Flutter application and open the SpellChecker editor.

The main screen contains:

- Editor panel.
- Check spelling button.
- Clear button.
- Word/character/sentence statistics.
- Results panel.
- Session reset action.
- About action.

## Check text

1. Type or paste text into the Editor panel.
2. Select **Check spelling**.
3. Review the Results panel.

Each unknown occurrence shows:

- The original word.
- Character position.
- Ranked suggestions when available.
- **Add word** action.
- **Ignore** action.

## Replace a word

Select one of the suggestion chips under an issue. SpellChecker replaces only that checked occurrence and then runs the check again.

Replacement attempts to preserve common capitalization patterns:

- `helo` → `hello`
- `Helo` → `Hello`
- `HELO` → `HELLO`

## Add a word

Select **Add word** when a legitimate word is missing from the bundled dictionary.

The word is added to the current in-memory personal dictionary and immediately stops being reported.

Version 1.0 does not persist personal words after the app process ends.

## Ignore a word

Select **Ignore** to stop reporting that normalized word during the current session.

Use this for temporary names, codes, or vocabulary that you do not want to add to the personal dictionary.

## Reset session words

Use the reset icon in the app bar to clear:

- Personal dictionary additions.
- Ignored words.

The text itself is not cleared by this action.

## Clear text

Select **Clear** to empty the editor and reset displayed results/statistics. This does not clear the session dictionary; use the session reset action for that.

## Statistics

SpellChecker displays:

- Word count.
- Character count.
- Sentence count.

These are lightweight writing statistics and are not intended as linguistic analysis.

## Privacy

Spelling checks run locally. Version 1.0 does not send editor text to a cloud spelling service and does not include analytics or advertising SDKs.

For details, read [PRIVACY.md](PRIVACY.md).

## Dictionary limitations

Version 1.0 ships with a starter English dictionary. Correct but uncommon words may be reported as unknown. Add them to the session dictionary or contribute improvements to the project.

SpellChecker does not currently provide grammar checking or automatic language detection.
