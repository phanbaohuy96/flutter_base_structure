---
name: data-reviewer
description: Reviews data-layer changes — Freezed DTOs, Retrofit clients, hive_ce stores, and repositories — against the template's conventions
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: code-review
---

# Data Layer Reviewer Skill

## When to use

- A diff touches files under `data/data_source/`, `data/models/`, `core/lib/data/`, or `modules/data_source/`.
- Reviewing a PR that adds or modifies a Retrofit client, repository, or DTO.

## What to check

### DTOs (`*_model.dart`)

- [ ] `sealed class` + `@freezed`.
- [ ] `factory FooModel.fromJson(Map<String, dynamic> json) => _$FooModelFromJson(json);` is present whenever the DTO crosses the wire.
- [ ] Non-nullable collections have `@Default([])` / `@Default({})`.
- [ ] `@JsonKey(name: ...)` on every non-camelCase field.
- [ ] Enums declare `@JsonValue('…')` per variant.
- [ ] `part 'foo_model.freezed.dart';` and `part 'foo_model.g.dart';` directives match the file name.
- [ ] No mutable fields, no manual `==`/`hashCode` (let freezed handle it).

### Retrofit clients

- [ ] Annotated `@RestApi()`; abstract `factory` calls the generated `_FooApiClient`.
- [ ] Path/query/body params use `@Path`, `@Query`, `@Body` — not interpolated strings.
- [ ] No hard-coded base URLs or auth headers — those flow from the `Dio` instance configured in DI.
- [ ] `Multipart` endpoints declared with `@Multipart` and `@PartFile()`.
- [ ] No `try/catch` in the client; let `DioException` propagate.

### Hive stores

- [ ] Unique `@HiveType(typeId: …)`. Cross-check the existing types.
- [ ] `@HiveField(n)` indices are stable; never reuse a deleted index.
- [ ] Adapters registered in the DI module that owns the box.

### Repositories

- [ ] One repository depends on one API client (and optionally one local store) — no rich aggregation across many clients.
- [ ] Public surface returns domain types (DTOs are fine here; entities if there's a mapper layer), never `DioException` or `Response<T>`.
- [ ] No business decisions: branching belongs in the use case or bloc, not the repo.
- [ ] Registered with `@LazySingleton(as: Foo)` (or `@Injectable`/`@Singleton`) and reachable from `injector`.

### DI

- [ ] Retrofit clients are produced from a `@module` (so `Dio` can be injected) — not direct `@LazySingleton` on the abstract class.
- [ ] `@injectable` annotations placed on impls, not interfaces, when both exist.

## Output format

Reply with:

1. **Verdict** — Approve / Minor changes / Blocking issues.
2. **Blocking issues** — concrete file:line citations with corrected snippets.
3. **Suggestions** — non-blocking improvements (naming, defaults, narrower types).
4. **Praise** — call out what's done right.

## Red flags

- DTOs with `class` instead of `sealed class` (will compile but blocks future union extensions).
- A `Repository` that imports `package:dio/dio.dart` for anything other than the constructor — it should depend only on the Retrofit interface.
- A new `typeId` that collides with an existing hive type elsewhere in the repo.
- Generated files (`*.freezed.dart`, `*.g.dart`) edited by hand.

## Related

- [`data-layer`](../data-layer/SKILL.md)
- [`code-generation`](../code-generation/SKILL.md)
- [`flutter-reviewer`](../flutter-reviewer/SKILL.md)
