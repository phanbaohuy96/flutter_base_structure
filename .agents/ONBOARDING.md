# Onboarding

Welcome. This template ships project-local skills under `.agents/skills/`
that AI agents auto-discover. You don't have to do anything to install
them — clone the repo, open it in your agent of choice, and start
working.

## Quick start

```bash
git clone <repo>
cd <repo>
cp apps/main/.env.example apps/main/.env
cp apps/main/android/keystores/keystore.properties.example \
   apps/main/android/keystores/keystore.properties
# Fill in placeholder values in both.

make pub_get
make gen_all
make lang
```

Then run the app:

```bash
cd apps/main
flutter run --flavor dev -t lib/main_dev.dart \
  --dart-define-from-file=./.env
```

## Activating an agent role

Mention an agent name in your message — the team yaml in
[`teams/development-team.yaml`](./teams/development-team.yaml) declares
the available roles:

| Agent | Use for |
|---|---|
| `@orchestrator` | Plan and delegate complex tasks |
| `@explorer` | Find files, patterns, code |
| `@oracle` | Architecture / design review |
| `@security-auditor` | Spot vulnerabilities |
| `@researcher` | API / package documentation |
| `@designer` | UI / UX |
| `@fixer` | Implement, fix, refactor |
| `@git-master` | Commits, rebasing, history |

## Letting skills auto-load

Just describe what you want. The agent picks the right skill from
[`INDEX.md`](./INDEX.md):

```
"Add a farm-registration feature with a list and detail screen."
→ agent loads module-scaffold, then bloc-pattern, then route-config
```

You can also call a skill explicitly:

```
"Use bloc-pattern to wire up the form submission flow."
```

## Common workflows

### New feature

1. `module-scaffold` — generate the module via `make run_module_generator`
2. `bloc-pattern` — author events, `_StateData`, state classes
3. `route-config` — register the route, expose a coordinator
4. `theme-usage` — style with `context.themeColor` / `context.textTheme`
5. `localization` — add strings to `apps/main/lib/l10n/localizations.csv`
6. `code-generation` — `make gen_all` (and `make lang` if strings changed)
7. `testing` — bloc + widget tests

### API integration

1. `data-layer` — Freezed DTO + Retrofit client + repository
2. `code-generation` — `make gen_all`
3. `bloc-pattern` — wire the repo through a usecase into a bloc
4. `error-handling` — only if you need behavior beyond the default UI router
5. `testing` — repository + bloc tests with mocktail

### Bug fix

1. `@explorer` — locate the failing path
2. `@oracle` — agree on the root cause
3. `@fixer` — implement the fix
4. `testing` — pin it with a regression test
5. `@git-master` — atomic commit

### PR review

- `data-reviewer` for changes under `data/`
- `flutter-reviewer` for changes under `presentation/`

## Conventions in one screen

- Clean architecture: `presentation/` → `domain/` → `data/`.
- Bloc: extends `AppBlocBase<E, S>`; abstract state hierarchy with a
  freezed `_StateData` and a `_factories` map.
- Screens: `StateBase<T>`, wrapped in `ScreenForm` / `MainPageForm`,
  always with a `static String routeName` and a `*.action.dart` partner.
- Routes: `IRoute` returning `List<CustomRouter>`; navigation via a
  `BuildContext` coordinator extension using `PushBehavior`.
- Theming: `context.themeColor.*` for colors, Material 3 typography
  slots plus the `AppTextTheme` extras (`titleTiny`, `inputTitle`, …).
- Localization: edit `localizations.csv`, run `make lang`. Use
  `trans.<key>` or `context.l10n.<key>`.
- Codegen: `make gen_all` after touching `@freezed`, `@RestApi`,
  `@Injectable`, `@HiveType`, `_StateData`, etc.

## Reference docs

- [`INDEX.md`](./INDEX.md) — skill index
- [`README.md`](./README.md) — skill system overview
- [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md) — when things break
- Repo-level `README.md` and `makefile` for build/run details
