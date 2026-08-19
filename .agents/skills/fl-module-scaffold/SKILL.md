---
name: fl-module-scaffold
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
| `common module` | Bloc + screen + route with no list/detail bias | Forms, single-action screens |
| `listing module` | List bloc with `items`, `canLoadMore`, refresh+load-more events | Browse/search screens |
| `detail module` | Detail bloc parameterised by `Args(initial, id)`, `Get<X>Event`, plus a coordinator | Item detail screens |
| `repository` | Repo + impl under the package's data-source tree | Wrap a Retrofit client |
| `usecase` | Usecase class in `apps/main/lib/domain/usecases/` | Wrap a repository |
| `model` | Freezed model template under `core/` or app | DTO between API and UI |

### The entity prompt

Every module type asks for the **entity** it is typed against (defaulting to
the first word of the module name), because the emitted state declares
`List<Entity>` / `Entity?`. When that entity does not exist yet the generator
scaffolds it — a freezed class under
`lib/domain/entities/<entity>/<entity>.entity.dart`, plus
`<entity>_filter.entity.dart` beside it for listing modules. Existing entity
files are never overwritten, so pointing a second module at the same entity is
safe. Pass `--no-entity-scaffold` to skip it.

### Naming

The detail generator appends `_detail` to the module name unless you already
typed it, and applies the same suffix to the usecase — module
`product_detail` gets `ProductDetailUsecase.getProductDetailById`. Keep the two
in step: the bloc imports the usecase by that exact path and class.

### Non-interactive use

Flags skip the prompts, which is what makes the generator scriptable and
testable:

```bash
cd apps/main
dart run module_generator \
  --type listing \
  --name product_list \
  --entity Product \
  --non-interactive
```

`--dir` overrides the output directory, `--force` allows overwriting an
existing module, and `--help` lists everything.

After generating, run `make gen_main` so freezed/injectable code and the route
provider registry are emitted, then `make check`. The route registers itself:
`@FlRouteProvider()` is picked up by the `fl_navigation` builder into
`lib/presentation/route/route_providers.config.dart` — there is no manual
registration step for a top-level module.

### Verifying the generator itself

If you change anything under `tools/module_generator/`, run both gates:

```bash
make check                    # includes the generator's template tests
make verify_module_generator  # generates all three module types into
                              # apps/main, runs gen_main, analyze and
                              # format, then removes what it created
```

`make verify_module_generator` needs a clean git state for `apps/main/build.yaml`,
`lib/di/di.config.dart`, and `lib/presentation/route/route_providers.config.dart`,
because it regenerates and then restores them.

## File layout (what the generator produces)

```
apps/main/lib/presentation/modules/<feature>/
├── <feature>.dart                # Barrel: exports route/bloc/screen/coordinator
├── <feature>_route.dart          # IRoute → CustomRouter<Args>
├── <feature>_coordinator.dart    # Entry point: Args translation + pre-nav guards
├── bloc/
│   ├── <feature>_bloc.dart       # part directives for event/state/freezed
│   ├── <feature>_event.dart      # abstract class + concrete events
│   └── <feature>_state.dart      # _StateData (freezed) + state classes + _factories
└── views/
    ├── <feature>_screen.dart     # StatefulWidget → StateBase<>
    ├── <feature>.action.dart     # part of screen — handlers/listeners
    └── widgets/                  # screen-local widgets (optional)
```

The barrel's `export` lines are sorted at emission, not fixed in the template:
`directives_ordering` sorts by URI, so whether `<feature>_route.dart` belongs
before or after `bloc/` depends on the feature's first letter.

Every module template emits a coordinator, so a caller has one entry point per module and route paths never leak into feature code. How much it owns depends on the template:

| Template | What its coordinator owns |
|---|---|
| `common` | `goTo<Feature>()` — the pre-nav guard seam, marked with a `TODO(template)` |
| `listing` | `goTo<Feature>({filter})` — translates a `<Entity>Filter` into `<Feature>Args` |
| `detail` | `goTo<Feature>({object})` and `goTo<Feature>ById({id})` — in-app vs deep-link entry |

The `common` coordinator is the one that starts out as a bare forwarder. If the module never grows entry logic, delete the file and its barrel export and call `pushBehavior.push(context, FeatureScreen.routeName)` directly — a permanent forwarding-only coordinator is indirection without leverage.

Domain + data live alongside, not under `presentation/`:

```
apps/main/lib/domain/entities/<entity>/<entity>.entity.dart
apps/main/lib/domain/usecases/<feature>/<feature>_usecase.dart  (and *.impl.dart)
apps/main/lib/data/data_source/remote/repository/<feature>/    (menu option 4)
```

The generated usecase impl has **no repository dependency** — it returns an
empty result behind a `TODO(template)`. That is deliberate: it compiles and
registers in DI on day one, and you wire your repository into it when you have
one.

Before adding a screen-local widget under `views/widgets/`, check `fl-ui-components` — it catalogs every reusable widget already in `fl_ui`, `fl_theme`, `fl_media`, and `common_widget`. For shared widgets/services, add to `core/` instead of `apps/main/`.

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
2. Author the bloc/event/state with the patterns from `fl-bloc-pattern`.
3. Author the screen + action file with `fl-extension-action`.
4. Add the route + coordinator with `fl-route-config`.
5. Register the route in the parent `IRoute` (e.g. `apps/main/lib/presentation/route/route.dart`).
6. Wire any new injectables, then `make gen_all`.

## Checklist

- [ ] Tried `make run_module_generator` first.
- [ ] Module placed under `lib/presentation/modules/<feature>/`.
- [ ] Multi-screen feature uses a parent route/coordinator/barrel plus child sub-modules.
- [ ] Screen extends `StateBase<T>` and has a `static String routeName`.
- [ ] Bloc extends `CoreBlocBase<E, S>` and is `@Injectable()`.
- [ ] Route extends `IRoute` and wraps the screen in `BlocProvider`.
- [ ] The coordinator is an extension on `BuildContext` using `PushBehavior`, and owns real entry logic rather than forwarding (see `fl-route-config` §Coordinator).
- [ ] Route registers itself via `@FlRouteProvider()` (top-level modules), or is aggregated by the parent `IRoute` (sub-modules).
- [ ] `make gen_main` run; generated files committed.
- [ ] `make check` green.

## Related

- [`fl-bloc-pattern`](../fl-bloc-pattern/SKILL.md)
- [`fl-route-config`](../fl-route-config/SKILL.md)
- [`fl-extension-action`](../fl-extension-action/SKILL.md)
- [`fl-data-layer`](../fl-data-layer/SKILL.md)
- [`fl-ui-components`](../fl-ui-components/SKILL.md)
