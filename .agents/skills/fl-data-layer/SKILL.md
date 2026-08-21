---
name: fl-data-layer
description: Builds the data layer with Freezed DTOs, Retrofit clients, the storage-seam local data manager, and repositories wired through injectable
license: MIT
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: data-layer
---

# Data Layer Skill

## When to use

- Adding a new model that crosses the network or local store.
- Wrapping a new REST endpoint group in a Retrofit client.
- Implementing a repository that mediates between API and bloc.

## Stack

| Concern | Package | Generator output |
|---|---|---|
| DTO + value classes | `freezed` + `freezed_annotation` + `json_serializable` | `*.freezed.dart`, `*.g.dart` |
| REST client | `retrofit` + `dio` + `retrofit_generator` | `*.g.dart` |
| Key/value persistence | `shared_preferences` + `flutter_secure_storage` (private state behind the storage seam) | — |
| Local store (optional, on demand) | `hive_ce` + `hive_ce_generator` | `*.g.dart` |
| DI | `injectable` + `injectable_generator` | `*.config.dart` |

The shared module `modules/data_source/` exposes Retrofit plumbing; per-feature clients live there or, for app-specific endpoints, under `apps/main/lib/data/data_source/`. Models that are shared across apps go in `core/lib/data/models/`. Local persistence flows through the **storage seam** (see below) — go through it rather than reaching for raw `SharedPreferences` or `FlutterSecureStorage` instances in presentation or feature code.

Run `make gen_all` after edits.

## Freezed DTO

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
sealed class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    @JsonKey(name: 'display_name') String? displayName,
    @Default(false) bool isActive,
    @Default([]) List<String> roles,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

Rules:
- DTOs are `sealed class` with `@freezed`.
- All non-nullable collections use `@Default([])` / `@Default({})`.
- Use `@JsonKey(name: ...)` for any field whose JSON key is not exact-match camelCase.
- Wrap `DateTime` only when the API doesn't emit ISO-8601; otherwise the default converter works.

## Enum serialization

```dart
enum OrderStatus {
  @JsonValue('pending')   pending,
  @JsonValue('shipped')   shipped,
  @JsonValue('delivered') delivered,
}
```

Always pin the wire string with `@JsonValue` — never rely on Dart's enum name matching.

## Retrofit client

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/user_model.dart';

part 'user_api_client.g.dart';

@RestApi()
abstract class UserApiClient {
  factory UserApiClient(Dio dio, {String? baseUrl}) = _UserApiClient;

  @GET('/api/v1/users/{id}')
  Future<UserModel> getUser(@Path('id') String id);

  @GET('/api/v1/users')
  Future<List<UserModel>> getUsers({
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @POST('/api/v1/users')
  Future<UserModel> createUser(@Body() UserModel user);

  @PUT('/api/v1/users/{id}')
  Future<UserModel> updateUser(@Path('id') String id, @Body() UserModel user);

  @DELETE('/api/v1/users/{id}')
  Future<void> deleteUser(@Path('id') String id);
}
```

Base URL flows from app config (`apps/main/lib/main.dart` + `--dart-define-from-file`), not from the client.

Multipart uploads:

```dart
@Multipart
@POST('/api/v1/upload')
Future<UploadResponse> upload(
  @Part() String type,
  @PartFile() MultipartFile file,
);
```

## Storage seam (local persistence)

See `CONTEXT.md` §Storage seam for the definition. Operational rules:

- Bind the app-scope `LocalDataManager` **and** the `@module` bridge that exposes `CoreLocalDataManager` as `@lazySingleton`. The seam holds in-memory caches (e.g. `_memCacheToken`); a factory binding silently desyncs every consumer.
- Warm async-only fields once during app init (`await injector<CoreLocalDataManager>().token;`) so the synchronous `isAuthenticated` getter is usable from `GoRoute.redirect`.
- Add a new persisted field by extending the seam interface — don't add a parallel preferences helper.

## Remote-source port

See `CONTEXT.md` §Remote-source port for the definition. When a use case needs data from somewhere the app does not own yet — a backend that is not built, a service you are about to swap — declare the **port** in `domain/` and bind an **adapter** to it at DI composition. Standing a fixture in for a real network call is then a one-line change to the binding, and nothing above it moves.

Rules when introducing one:

- Keep the contract narrow — one `Future<DomainModel?>` (or domain entity) per operation.
- Return the refreshed domain object, not a `bool`. Callers that need to update state shouldn't have to issue a second read.
- **Every adapter implements the port, never another adapter.** A real implementation written as `implements MockXSource` inherits the fixture's shape and keeps the mock alive in the dependency graph forever.
- The use case depends on the port's type. If a use case names a concrete adapter, the seam has already failed.

> **Template demo.** `apps/main` ships `MockAuthRemoteSource` (`lib/data/data_source/remote/auth/mock_auth_remote_source.dart`) bound with `@Injectable(as: AuthCredentialSource)` — the port lives at `lib/domain/repositories/auth_credential_source.dart` and `AuthInteractorImpl` depends on it, not on the mock. Swap in a backend by writing another `@Injectable(as: AuthCredentialSource)` class and deleting this one. Nothing in this skill depends on the demo existing.

## Hive local store (optional)

Reach for the storage seam first. Only introduce a Hive box when you need typed collections beyond key/value scope. Rules:

- Pick a unique `@HiveType(typeId: …)`; never re-use a deleted `@HiveField(n)` index.
- Register the adapter in the DI module that owns the box.

## Local storage APIs

Expose storage behavior through the existing DAO → repository → usecase boundaries rather than letting presentation code reach into storage directly. Prefer stable table/row operations over replacing storage infrastructure. New public DAO/repository/usecase methods should have concise Dartdoc.

When a mutation produces data the caller needs, return the updated domain result instead of returning only a success flag and forcing an immediate duplicate query.

## Repository

**A repository is the retrofit client.** Retrofit generates the implementation
into the `.g.dart` part, so there is no contract-plus-impl pair to hand-write —
an interface beside a generated implementation holds nothing. Every repository
in this template has this shape (`RestApiRepository`, `StorageRepository`,
`DataSourceRestApiRepository`), and `dart run module_generator --type
repository` emits it.

```dart
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../models/product.dart';

part 'product_repository.g.dart';

@RestApi()
abstract class ProductRepository {
  factory ProductRepository(Dio dio) = _ProductRepository;

  @GET('/products/{id}')
  Future<ApiResponse<ProductModel>> getDetail({@Path('id') required String id});
}
```

The generator scaffolds the payload model in the same run and types the
endpoint against it, so there is no second trip through the tool to get a
client that returns something. Model suffix on the class, not the file:
`ProductModel` in `models/product.dart`.

Rules:

- `factory X(Dio dio) = _X;` is not optional — `_X` is what the generator
  writes, and without the redirect there is no way to construct the client.
- Paths are relative to the Dio base URL, which comes from app config. Never
  hardcode a host.
- The abstraction that keeps transport out of `domain/` is the **use case**
  above the repository, not a second interface beside it. A use case names
  domain operations (`fetchProfile`), a repository names endpoints
  (`getUserV2`).
- A repository can only live in a package that declares `retrofit`, `dio` and
  `core` as **runtime** dependencies. `apps/main` has `retrofit_generator` as a
  dev dependency only, so a client there fails
  `depend_on_referenced_packages`; put it in `modules/data_source`.

### Choosing a transport

`dart run module_generator --type repository` asks, or takes
`--transport rest|graphql`:

- **`rest`** — one file. One annotated method per endpoint, returning the
  `ApiResponse<T>` envelope.
- **`graphql`** — the client plus `<name>_fragment.dart`. GraphQL routes by
  document rather than by path, so the client is a single `@POST('')` `execute`
  passthrough and an `@injectable` repository above it composes the document
  and unwraps the response. The fragment file declares the field selection once
  and `request` appends it to every document, because a server resolves
  `...ProductFields` only when the fragment travels with the operation.
  Documents are raw strings (`r'''…'''`) so GraphQL's `$variable` syntax is not
  interpolated away.

The GraphQL rule worth memorising: **a failed operation still answers HTTP 200**.
The `errors` array, not the status code, decides whether the call succeeded, so
check it before reading `data` or a partial response reads as a success.

## DI

The `injectable` graph picks up `@Injectable`/`@LazySingleton`/`@Singleton`
automatically once `make gen_all` is run.

Retrofit clients are the exception: their implementation is a private class, so
the annotation has nowhere to go and a `@module` provider is the only way to
bind one. The module generator writes it for you — into
`modules/data_source/lib/src/di/data_source_micro.dart` for that package:

```dart
@module
abstract class DataSourceOverrideModule {
  @injectable
  ProductRepository productRepository(Dio dio) => ProductRepository(dio);
}
```

Adding one by hand, remember the client and the provider have to move together:
a client with no provider is a file nothing can inject, and injectable will not
tell you — it simply never appears in `di.config.dart`.

## Checklist

- [ ] DTO is `sealed class` with `@freezed`, defaults provided for collections.
- [ ] `@JsonKey` set for every non-camelCase JSON field.
- [ ] Enum factories use `@JsonValue`.
- [ ] Retrofit client uses `@RestApi`, `@Path`, `@Query`, `@Body` correctly; no hardcoded base URL.
- [ ] `factory X(Dio dio) = _X;` present — without the redirect the client cannot be constructed.
- [ ] GraphQL repositories check the `errors` array before reading `data`, and send the fragment with the operation.
- [ ] The use case above the repository names domain operations; nothing in *its* signature reveals REST vs GraphQL.
- [ ] Repository lives in a package that declares `retrofit`, `dio` and `core` as runtime dependencies.
- [ ] Every retrofit client has a `@module` provider — the annotation cannot bind a private implementation.
- [ ] `make gen_all` run; generated files staged.

## Common mistakes

- Mutable lists/maps in DTOs (drop the default and end up with nullables).
- Repositories making `Dio` calls directly, bypassing Retrofit.
- Forgetting `part 'foo.g.dart';` or the `= _X;` factory redirect — Retrofit won't compile.
- Emitting a retrofit client with no `@module` provider: it compiles, and then never appears in `di.config.dart`.
- Wrapping a retrofit client in a hand-written contract + impl pair. Retrofit already generated the implementation; the domain seam is the use case above.
- Reaching into `SharedPreferences` / `FlutterSecureStorage` from presentation or feature code instead of going through the storage seam.
- Binding `LocalDataManager` / `CoreLocalDataManager` as `@Injectable()` (factory) — the in-memory token cache silently desyncs across consumers. Must be `@lazySingleton`.
- Reusing `@HiveType(typeId: …)` across types when the optional Hive path is used.

## Related

- [`fl-bloc-pattern`](../fl-bloc-pattern/SKILL.md)
- [`fl-error-handling`](../fl-error-handling/SKILL.md)
- [`fl-code-generation`](../fl-code-generation/SKILL.md)
- [`fl-data-reviewer`](../fl-data-reviewer/SKILL.md)
