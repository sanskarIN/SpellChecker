from pathlib import Path

path = Path('test/writing_widget_test.dart')
text = path.read_text()
old = "await tester.drag(insightsList, const Offset(0, -900));"
new = "await tester.drag(insightsList, const Offset(0, -600));"
count = text.count(old)
if count != 1:
    raise RuntimeError(
        f'expected exactly one V2.2 writing insights scroll helper, found {count}'
    )
path.write_text(text.replace(old, new, 1))
print('V2.2 widget viewport scroll adjusted successfully.')
