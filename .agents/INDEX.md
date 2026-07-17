# Skill Index

One-line index of every skill under [`./skills/`](./skills/).

## Core

| Skill | Purpose | When to use |
|---|---|---|
| [`fl-behavioral-guardrails`](./skills/fl-behavioral-guardrails/SKILL.md) | Clarify, simplify, make surgical changes, verify | Planning, implementing, reviewing, or refactoring |
| [`fl-module-scaffold`](./skills/fl-module-scaffold/SKILL.md) | Scaffold a feature module | Starting a new screen / feature |
| [`fl-bloc-pattern`](./skills/fl-bloc-pattern/SKILL.md) | `CoreBlocBase` + `_StateData` + `_factories` | Adding or modifying state management |
| [`fl-bus-event`](./skills/fl-bus-event/SKILL.md) | Cross-feature event synchronization | Publishing or listening to `BusEvent` updates |
| [`fl-extension-action`](./skills/fl-extension-action/SKILL.md) | `*.action.dart` for screen handlers | Splitting handlers out of a bloated screen |
| [`fl-route-config`](./skills/fl-route-config/SKILL.md) | `IRoute` + `CustomRouter` + optional coordinator | Wiring navigation |
| [`fl-theme-usage`](./skills/fl-theme-usage/SKILL.md) | `context.themeColor` + `context.textTheme` | Styling a widget |
| [`fl-ui-components`](./skills/fl-ui-components/SKILL.md) | Awareness index of reusable widgets in `fl_ui`/`fl_theme`/`fl_media`/`common_widget` | Before writing any new widget |
| [`fl-widget-preview`](./skills/fl-widget-preview/SKILL.md) | Official `@Preview` / `flutter widget-preview` workflow | Previewing or showcasing Flutter widgets |
| [`fl-data-layer`](./skills/fl-data-layer/SKILL.md) | Freezed DTO + Retrofit + storage seam + repo (Hive optional) | Talking to an API or local store |
| [`fl-dependency-injection`](./skills/fl-dependency-injection/SKILL.md) | Injectable + GetIt composition boundaries and DI review | Wiring or reviewing dependencies |
| [`fl-error-handling`](./skills/fl-error-handling/SKILL.md) | `CoreBlocBase.onError` + `ErrorType` router | Deciding what to do with a thrown error |
| [`fl-localization`](./skills/fl-localization/SKILL.md) | CSV → ARB → `AppLocalizations` | Adding translations |
| [`fl-code-generation`](./skills/fl-code-generation/SKILL.md) | `make gen_all` and friends | After editing freezed/retrofit/injectable |
| [`fl-testing`](./skills/fl-testing/SKILL.md) | bloc_test + mocktail + widget tests | Writing or running tests |

## Review

| Skill | Purpose | When to use |
|---|---|---|
| [`fl-data-reviewer`](./skills/fl-data-reviewer/SKILL.md) | Data-layer review checklist | Reviewing a diff under `data/` |
| [`fl-reviewer`](./skills/fl-reviewer/SKILL.md) | UI-layer review checklist | Reviewing a diff under `presentation/` |

## Decision shortcuts

```
Any non-trivial change?        → fl-behavioral-guardrails
Starting a feature?            → fl-module-scaffold → fl-bloc-pattern → fl-route-config
Cleaning up a screen?          → fl-extension-action
Adding a network endpoint?     → fl-data-layer → fl-dependency-injection → fl-bloc-pattern
Syncing state across features? → fl-bus-event
After editing annotated code?  → fl-code-generation
Adding user-facing strings?    → fl-localization
Writing tests?                 → fl-testing
Reviewing data-layer PR?       → fl-data-reviewer
Reviewing UI PR?               → fl-reviewer
Custom error UX?               → fl-error-handling
Styling questions?             → fl-theme-usage
Previewing a widget?           → fl-widget-preview → fl-theme-usage
Building UI?                   → fl-ui-components → fl-theme-usage
```

## Related

- [`README.md`](./README.md) — overview and skill template
- [`ONBOARDING.md`](./ONBOARDING.md) — orientation for new collaborators
- [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md) — common failure modes
- [`teams/development-team.yaml`](./teams/development-team.yaml) — agent roles
