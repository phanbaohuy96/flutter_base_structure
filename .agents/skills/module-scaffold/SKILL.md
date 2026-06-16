---
name: module-scaffold
description: Scaffolds a new feature module under apps/main/lib/presentation/modules using the bundled module generator
license: MIT
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: clean-architecture
---

# Module Scaffold Skill

## When to use

- Adding a new feature/screen to `apps/main/`.
- Creating the standard module quartet: `bloc/`, `views/`, `route`, `coordinator`.
- Spinning up a parallel data-layer model/repository/usecase for that feature.

## Preferred path: bundled module generator

The template ships an interactive generator that emits files matching the project's exact conventions. Always try this first.

```bash
make run_module_generator
# Choose: 1) common module  2) listing module  3) detail module
#         4) repository    5) usecase          6) model
```

Source: `tools/module_generator/`, templates in `tools/module_generator/lib/res/templates/`.

| Module type | What it scaffolds | Use for |
|---|---|---|
| `common module` | Bloc + screen + route + coordinator with no list/detail bias | Forms, single-action screens |
| `listing module` | List bloc with `items`, `canLoadMore`, refresh+load-more events | Browse/search screens |
| `detail module` | Detail bloc parameterised by `Args(initial, id)`, `Get<X>Event` | Item detail screens |
| `repository` | Repo + impl in `apps/main/lib/data/data_source/` | Wrap a Retrofit client |
| `usecase` | Usecase class in `apps/main/lib/domain/usecases/` | Wrap a repository |
| `model` | Freezed model template under `core/` or app | DTO between API and UI |

After generating, run `make gen_all` so freezed/injectable code is emitted, then register the new route.

## File layout (what the generator produces)

```
apps/main/lib/presentation/modules/<feature>/
├── <feature>.dart                # Barrel: exports route/bloc/screen (+ coordinator if compound)
├── <feature>_route.dart          # IRoute → CustomRouter<Args>
├── <feature>_coordinator.dart    # ONLY for compound modules / non-trivial entry — see CONTEXT.md
├── bloc/
│   ├── <feature>_bloc.dart       # part directives for event/state/freezed
│   ├── <feature>_event.dart      # abstract class + concrete events
│   └── <feature>_state.dart      # _StateData (freezed) + state classes + _factories
└── views/
    ├── <feature>_screen.dart     # StatefulWidget → StateBase<>
    ├── <feature>.action.dart     # part of screen — handlers/listeners
    └── widgets/                  # screen-local widgets (optional)
```

The module generator omits the coordinator file when the chosen template's source map lacks a `coordinator` key (see `tools/module_generator/lib/generator/module_generator_ext.dart`). Simple modules call `pushBehavior.push(context, FeatureScreen.routeName)` directly; only compound modules and modules with non-trivial entry logic (arg translation, pre-nav guards) keep a coordinator. A one-line `pushBehavior.push` wrapper is shallow — don't add one.

Domain + data live alongside, not under `presentation/`:

```
apps/main/lib/domain/usecases/<feature>/<feature>_usecase.dart
apps/main/lib/data/data_source/<feature>_repository.dart  (and *_impl.dart)
```

For shared widgets/services, add to `core/` instead of `apps/main/`.

## Compound features

When a feature has more than one screen, do not flatten it into one oversized module or bypass the established presentation structure. Use a parent module that owns the parent barrel, coordinator, and route aggregator; each non-trivial child screen gets its own sub-module with `bloc/` and `views/`.

```text
<feature>/
├── <feature>.dart
├── <feature>_route.dart          # aggregates child routes
├── <feature>_coordinator.dart
├── <child_a>/
│   ├── bloc/
│   └── views/
└── <child_b>/
    ├── bloc/
    └── views/
```

If the user says a flow should follow a named project architecture, apply that architecture directly and ask before choosing a lighter UI structure.

## Manual scaffold (when the generator does not fit)

Stick to the names below — `_factories`, `Args`, `routeName`, the part wiring — because other parts of the codebase rely on them.

1. Create the directory tree above.
2. Author the bloc/event/state with the patterns from `bloc-pattern`.
3. Author the screen + action file with `extension-action`.
4. Add the route + coordinator with `route-config`.
5. Register the route in the parent `IRoute` (e.g. `apps/main/lib/presentation/route/route.dart`).
6. Wire any new injectables, then `make gen_all`.

## Checklist

- [ ] Tried `make run_module_generator` first.
- [ ] Module placed under `lib/presentation/modules/<feature>/`.
- [ ] Multi-screen feature uses a parent route/coordinator/barrel plus child sub-modules.
- [ ] Screen extends `StateBase<T>` and has a `static String routeName`.
- [ ] Bloc extends `CoreBlocBase<E, S>` and is `@Injectable()`.
- [ ] Route extends `IRoute` and wraps the screen in `BlocProvider`.
- [ ] If present, the coordinator is an extension on `BuildContext` using `PushBehavior` — added only for compound modules or non-trivial entry logic (see `route-config` §Coordinator).
- [ ] Route registered in the app's parent `IRoute`.
- [ ] `make gen_all` run; generated files committed.

## Related

- [`bloc-pattern`](../bloc-pattern/SKILL.md)
- [`route-config`](../route-config/SKILL.md)
- [`extension-action`](../extension-action/SKILL.md)
- [`data-layer`](../data-layer/SKILL.md)
