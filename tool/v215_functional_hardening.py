from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    target = Path(path)
    text = target.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{path}: expected one occurrence of {old!r}, found {count}')
    target.write_text(text.replace(old, new, 1))


replace_once(
    'test/writing_widget_test.dart',
    'for (var index = 0; index < 24 && target.evaluate().isEmpty; index++) {',
    'for (var index = 0; index < 40 && target.evaluate().isEmpty; index++) {',
)
replace_once(
    'test/v214_settings_transfer_rule_compatibility_test.dart',
    "test('unset portable override remains unset for nine-rule defaults', () {",
    "test('unset portable override remains unset as defaults evolve', () {",
)
replace_once(
    'test/v214_rule_preference_compatibility_widget_test.dart',
    "testWidgets('reset clears V2.13 override and adopts nine-rule defaults', (",
    "testWidgets('reset clears V2.13 override and adopts current defaults', (",
)
