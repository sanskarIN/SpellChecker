from pathlib import Path

path = Path('test/writing_widget_test.dart')
text = path.read_text()
old = """    final applySafeFix = find.text('Apply safe fix').first;\n    await scrollUntilBuilt(tester, applySafeFix);\n\n    expect(find.text('Apply safe fix'), findsWidgets);\n    await tester.tap(applySafeFix);\n"""
new = """    final applySafeFixes = find.text('Apply safe fix');\n    await scrollUntilBuilt(tester, applySafeFixes);\n\n    expect(applySafeFixes, findsWidgets);\n    await tester.tap(applySafeFixes.first);\n"""
count = text.count(old)
if count != 1:
    raise SystemExit(f'expected exactly one eager first-finder block, found {count}')
path.write_text(text.replace(old, new, 1))
