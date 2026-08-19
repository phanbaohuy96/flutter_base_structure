## 0.0.2

* Module templates now emit code that compiles and passes `make check`:
  * Fixed the broken `di/di.dart` import in the listing and detail route
    templates (`'../../..//../../di/di.dart'`).
  * Import prefixes are computed with `package:path` from each emitted file's
    own directory instead of a shared `'../' * n` counter, so route and
    coordinator files (one level above `bloc/` and `views/`) resolve correctly
    and any output directory works.
  * The detail generator suffixes `_detail` on the usecase as well as the
    module, and the usecase declares the `get<Module>ById` the bloc calls.
  * Modules scaffold the domain entity (and, for listings, its filter) they are
    typed against; `List<Model>` no longer refers to a type nothing writes.
  * The common-module bloc imports `package:core/core.dart` rather than
    `package:bloc/bloc.dart`, which `apps/main` does not depend on, and
    registers a concrete event instead of the abstract base event.
  * `@override` on `dispose`, `unused_element_parameter` in the state ignore
    header, `@freezed abstract class _StateData`, `adaptiveArguments` instead of
    `adaptive`, `static const String routeName`, `injector.get()`, and
    `// TODO(template):` comments throughout.
  * Emitted files are formatted with `dart format`, and barrel exports are
    sorted after substitution so `directives_ordering` holds for any name.
* Every module template now emits a `<module>_coordinator.dart` (previously
  only `detail` did), so a module has one entry point and callers never spell
  out a route path:
  * `listing` gained `<Feature>Args` carrying an `<Entity>Filter`, wired
    through `CustomRouter<Args>` + `extraFromUrlQueries`, an `@factoryParam` on
    the bloc, and a `filter` field on `_StateData`. Its coordinator translates
    a domain filter into the route payload, so a deep link and an in-app push
    land on the same filtered listing.
  * `<Entity>Filter` gained a `fromQuery` factory, the inverse of `query`, so a
    filtered listing round-trips through a URL.
  * `common`'s coordinator is a documented pre-nav-guard seam that tells you to
    delete it if entry logic never arrives.
* Added a real CLI: `--type`, `--name`, `--dir`, `--entity`,
  `--no-entity-scaffold`, `--force`, `--non-interactive`, `--help`. The
  interactive menu is unchanged when no flags are passed.
* Module names are validated, existing modules are not overwritten without
  `--force`, and menu prompts no longer crash on non-numeric input.
* The repository generator's default output directory now matches the package
  layout (`lib/src/data/...` vs `lib/data/...`).
* Added `make verify_module_generator`, an end-to-end smoke gate, and
  `test/module_emission_test.dart`, which verifies emitted imports resolve and
  that bloc, usecase, route, screen and barrel agree on names.

## 0.0.1

* TODO: Describe initial release.
