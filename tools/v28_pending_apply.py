# commit-message: docs: add Buy Me a Coffee support links
from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text()
    if old not in text:
        raise SystemExit(f"expected marker not found in {path}: {old[:100]!r}")
    if text.count(old) != 1:
        raise SystemExit(f"expected one marker in {path}, found {text.count(old)}")
    p.write_text(text.replace(old, new, 1))


readme = Path("README.md")
readme_text = readme.read_text()
readme_badge_line = "[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-sanskarIN-FFDD00?logo=buymeacoffee&logoColor=000000)](https://buymeacoffee.com/sanskarIN)"
if readme_badge_line not in readme_text:
    license_badge = "[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)\n"
    if license_badge not in readme_text:
        raise SystemExit("README license badge marker not found")
    readme_text = readme_text.replace(
        license_badge,
        license_badge + readme_badge_line + "\n",
        1,
    )

if "## Support development\n" not in readme_text:
    readme_security = """## Security

Do not publish exploitable security details in normal public issues. Follow [SECURITY.md](SECURITY.md) for responsible reporting guidance.

## License
"""
    readme_support = """## Security

Do not publish exploitable security details in normal public issues. Follow [SECURITY.md](SECURITY.md) for responsible reporting guidance.

## Support development

If SpellChecker is useful to you and you want to support its open-source development, you can [buy Sanskar a coffee](https://buymeacoffee.com/sanskarIN). Financial support is optional and does not change access to the MIT-licensed project, issue handling, or contribution review.

## License
"""
    if readme_security not in readme_text:
        raise SystemExit("README Security/License marker not found")
    readme_text = readme_text.replace(readme_security, readme_support, 1)
readme.write_text(readme_text)

support = Path("SUPPORT.md")
support_text = support.read_text()
if "# Support the project\n" not in support_text:
    support_marker = """# Security reports

Do not use normal public issues for vulnerabilities. Follow [SECURITY.md](SECURITY.md).
"""
    support_replacement = support_marker + """

# Support the project

SpellChecker is free and open source. If the project is useful to you and you would like to support continued development, you can [buy Sanskar a coffee](https://buymeacoffee.com/sanskarIN).

Financial support is optional. It does not provide privileged access to security reports, issue triage, roadmap decisions, releases, or contribution review.
"""
    if support_marker not in support_text:
        raise SystemExit("SUPPORT security marker not found")
    support_text = support_text.replace(support_marker, support_replacement, 1)
support.write_text(support_text)

contrib = Path("CONTRIBUTING.md")
contrib_text = contrib.read_text()
if "# Support development\n" not in contrib_text:
    contrib_marker = """# License

By contributing, you agree that your contribution may be distributed under the repository's [MIT License](LICENSE).
"""
    contrib_replacement = """# Support development

Code, documentation, testing, issue triage, accessibility feedback, and careful bug reports are all valuable contributions. If you also want to support the maintainer financially, the optional project support link is [Buy Me a Coffee](https://buymeacoffee.com/sanskarIN).

Financial support does not change code-review standards, project governance, roadmap priority, security handling, or access to the MIT-licensed source.

# License

By contributing, you agree that your contribution may be distributed under the repository's [MIT License](LICENSE).
"""
    if contrib_marker not in contrib_text:
        raise SystemExit("CONTRIBUTING License marker not found")
    contrib_text = contrib_text.replace(contrib_marker, contrib_replacement, 1)
contrib.write_text(contrib_text)
