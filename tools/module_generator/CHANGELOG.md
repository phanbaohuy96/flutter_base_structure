## 0.0.3

* A generated repository is now a real retrofit client, which is what every
  repository in this template already was (`RestApiRepository`,
  `StorageRepository`, `DataSourceRestApiRepository`). The old templates told
  you to add your endpoint to `RestApiRepository` — a class in `core`, a
  package a feature cannot edit — and shipped a `Future.value()` stub in the
  meantime, wrapped in an abstract contract plus a `part` impl that forwarded
  and nothing else. Retrofit generates the implementation, so that layer had
  nothing in it; the seam that keeps transport out of `domain/` is the use case
  above, not a second interface beside it.
  * `--transport rest` emits one file: an `@RestApi()` abstract class with a
    factory redirect and one annotated endpoint returning the `ApiResponse<T>`
    envelope.
  * `--transport graphql` emits the client and `<name>_fragment.dart`. GraphQL
    routes by document rather than by path, so the client is a single `execute`
    passthrough and an `@injectable` repository above it composes operations
    and checks the `errors` array before reading `data` — a failed GraphQL
    operation still answers HTTP 200.
* The generator writes the DI provider itself. A retrofit client's
  implementation is private, so `@Injectable` cannot be applied to it and a
  `@module` provider is the only way to bind one — the generator finds the
  package's module, inserts the provider, and adds the import, leaving
  everything else in the file untouched.
* A generated repository comes with the model it returns. A client typed
  against `Map<String, dynamic>` left you to create the model in a second run
  and wire the import by hand; one prompt now picks the template (Freezed by
  default, `0` to opt out) and the client is typed against it. The suffix goes
  on the class rather than the file — `ProductModel` lands in
  `models/product.dart` — and an existing model is skipped rather than
  overwritten, so two repositories can share one. Flags: `--model`,
  `--model-name`, `--model-dir`.
* Each transport emits one worked endpoint instead of a CRUD set. REST used to
  emit five verbs against paths no real API has and GraphQL two operations plus
  a `mutation` document, so the first thing anyone did was delete most of it.
  What is left is `getDetail` — verb, path template, `@Path`, envelope — with a
  comment saying to add the rest the same way.
* A repository can only be generated into a package that declares `retrofit`,
  `dio` and `core` as runtime dependencies. `apps/main` carries
  `retrofit_generator` as a dev dependency only, so a client generated there
  would build and then fail `depend_on_referenced_packages`; the generator now
  says so and names where to put it instead.
* The generator scans the workspace and asks which package to generate into,
  showing which ones can host a retrofit client. `make run_module_generator`
  no longer asks you to type a path from memory; `--package` skips the menu.
* The overwrite guard checks the files a run would replace instead of the
  directory that holds them. An existing directory is not a conflict, so
  generating a module beside unrelated files, or re-running after deleting
  one file, works — where before the only way forward was `--force`, the one
  option that does destroy work.
* Repository templates are covered by the test suite for the first time —
  emission, DI binding, and a sandbox generation that checks every emitted
  directive resolves — and `verify_module_generator.sh` generates both
  transports into `modules/data_source`, so they have to survive build_runner,
  `flutter analyze`, `dart format` and injectable registration.
* New `%%CAMEL_NAME%%` template key (lower-camel form of the class name), used
  by the GraphQL root fields.
* The interactive menus are grouped with per-entry descriptions and degrade to
  plain text when stdout is not an ANSI terminal, so piped output and CI logs
  stay greppable.
* Skipping an existing file prints one line instead of dumping the whole file
  it did not write into the terminal.

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
