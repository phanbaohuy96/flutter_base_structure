# Skill Index

One-line index of every skill under [`./skills/`](./skills/).

## Core

| Skill | Purpose | When to use |
|---|---|---|
| [`behavioral-guardrails`](./skills/behavioral-guardrails/SKILL.md) | Clarify, simplify, make surgical changes, verify | Planning, implementing, reviewing, or refactoring |
| [`module-scaffold`](./skills/module-scaffold/SKILL.md) | Scaffold a feature module | Starting a new screen / feature |
| [`bloc-pattern`](./skills/bloc-pattern/SKILL.md) | `AppBlocBase` + `_StateData` + `_factories` | Adding or modifying state management |
| [`bus-event`](./skills/bus-event/SKILL.md) | Cross-feature event synchronization | Publishing or listening to `BusEvent` updates |
| [`extension-action`](./skills/extension-action/SKILL.md) | `*.action.dart` for screen handlers | Splitting handlers out of a bloated screen |
| [`route-config`](./skills/route-config/SKILL.md) | `IRoute` + `CustomRouter` + coordinator | Wiring navigation |
| [`theme-usage`](./skills/theme-usage/SKILL.md) | `context.themeColor` + `context.textTheme` | Styling a widget |
| [`data-layer`](./skills/data-layer/SKILL.md) | Freezed DTO + Retrofit + repo | Talking to an API or local store |
| [`error-handling`](./skills/error-handling/SKILL.md) | `CoreBlocBase.onError` + `ErrorType` router | Deciding what to do with a thrown error |
| [`localization`](./skills/localization/SKILL.md) | CSV → ARB → `AppLocalizations` | Adding translations |
| [`code-generation`](./skills/code-generation/SKILL.md) | `make gen_all` and friends | After editing freezed/retrofit/injectable |
| [`testing`](./skills/testing/SKILL.md) | bloc_test + mocktail + widget tests | Writing or running tests |

## Review

| Skill | Purpose | When to use |
|---|---|---|
| [`data-reviewer`](./skills/data-reviewer/SKILL.md) | Data-layer review checklist | Reviewing a diff under `data/` |
| [`flutter-reviewer`](./skills/flutter-reviewer/SKILL.md) | UI-layer review checklist | Reviewing a diff under `presentation/` |

## Decision shortcuts

```
Any non-trivial change?        → behavioral-guardrails
Starting a feature?            → module-scaffold → bloc-pattern → route-config
Cleaning up a screen?          → extension-action
Adding a network endpoint?     → data-layer → bloc-pattern
Syncing state across features? → bus-event
After editing annotated code?  → code-generation
Adding user-facing strings?    → localization
Writing tests?                 → testing
Reviewing data-layer PR?       → data-reviewer
Reviewing UI PR?               → flutter-reviewer
Custom error UX?               → error-handling
Styling questions?             → theme-usage
```

## Related

- [`README.md`](./README.md) — overview and skill template
- [`ONBOARDING.md`](./ONBOARDING.md) — orientation for new collaborators
- [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md) — common failure modes
- [`teams/development-team.yaml`](./teams/development-team.yaml) — agent roles
