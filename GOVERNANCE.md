# Governance

SpellChecker is currently a maintainer-led open-source project.

## Maintainer responsibilities

Maintainers are responsible for:

- Reviewing pull requests and issues.
- Protecting release quality and project security.
- Maintaining project direction and architecture.
- Enforcing the Code of Conduct.
- Publishing releases.
- Keeping documentation aligned with behavior.

## Decision making

Routine fixes and small improvements can be accepted through normal pull-request review. Larger decisions should be discussed in an issue before implementation, especially changes involving:

- Public APIs.
- Persistent user data.
- Network access.
- Analytics or telemetry.
- New language/dictionary formats.
- Major dependencies.
- Licensing.
- Breaking changes.

The maintainer makes the final decision when consensus is not reached.

## Becoming a contributor

Anyone may contribute through issues, documentation, tests, dictionary improvements, bug fixes, and features. Consistent high-quality participation may lead to broader review or maintenance responsibilities in the future.

## Releases

Releases are cut from `main` after required checks pass. The release process is documented in [docs/RELEASING.md](docs/RELEASING.md).
