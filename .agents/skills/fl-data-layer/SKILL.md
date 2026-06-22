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

Base URL flows from app config (`apps/main/lib/envs.dart` + `--dart-define-from-file`), not from the client.

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

## Mock remote source

See `CONTEXT.md` §Mock remote source for the definition. `MockAuthRemoteSource` is the shipped example: an `@injectable` class with no separate interface, injected directly into `AuthRepositoryImpl`. Downstream apps swap it by defining `RetrofitAuthRemoteSource implements MockAuthRemoteSource` and rebinding — the repository depending on the mock keeps compiling.

Rules when introducing one:

- Keep the contract narrow — one `Future<DomainModel?>` (or domain entity) per operation.
- Return the refreshed domain object, not a `bool`. Callers that need to update state shouldn't have to issue a second read.

## Hive local store (optional)

Reach for the storage seam first. Only introduce a Hive box when you need typed collections beyond key/value scope. Rules:

- Pick a unique `@HiveType(typeId: …)`; never re-use a deleted `@HiveField(n)` index.
- Register the adapter in the DI module that owns the box.

## Local storage APIs

Expose storage behavior through the existing DAO → repository → usecase boundaries rather than letting presentation code reach into storage directly. Prefer stable table/row operations over replacing storage infrastructure. New public DAO/repository/usecase methods should have concise Dartdoc.

When a mutation produces data the caller needs, return the updated domain result instead of returning only a success flag and forcing an immediate duplicate query.

## Repository

Repositories accept the API client (or a remote source) by constructor and are the only layer feature blocs depend on.

The module-generator's `repository.impl.dart` template uses the `DataRepository` mixin, which exposes `restApi` (a `RestApiRepository` reached via DI) for shared transport calls, and wraps the call in `try/on Exception` so the impl can translate transport errors into domain errors before they reach the use case:

```dart
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

@Injectable(as: UserRepository)
class UserRepositoryImpl with DataRepository implements UserRepository {
  @override
  Future<User> getUser(String id) async {
    try {
      final dto = await restApi.getUser(id);
      return dto.toEntity();
    } on Exception catch (error, stackTrace) {
      // Wrap as NotFoundError / NetworkError / etc. so use cases can
      // switch on intent instead of catching raw DioException.
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
```

Two rules the template encodes:

- `with DataRepository implements XRepository` — `DataRepository` is a mixin, not a base class. Don't extend it.
- DTOs stop at the repository boundary; return domain entities (use a `toEntity()` mapper or equivalent). When a repository forwards a single endpoint with no mapping needed, keep it shallow — don't invent an entity layer for its own sake.

## DI

The `injectable` graph picks up `@Injectable`/`@LazySingleton`/`@Singleton` automatically once `make gen_all` is run. For Retrofit clients, register a `@module` somewhere under `apps/main/lib/di/`:

```dart
@module
abstract class ApiModule {
  @lazySingleton
  UserApiClient userApiClient(Dio dio) => UserApiClient(dio);
}
```

## Checklist

- [ ] DTO is `sealed class` with `@freezed`, defaults provided for collections.
- [ ] `@JsonKey` set for every non-camelCase JSON field.
- [ ] Enum factories use `@JsonValue`.
- [ ] Retrofit client uses `@RestApi`, `@Path`, `@Query`, `@Body` correctly; no hardcoded base URL.
- [ ] Repository depends on the API client (and any local store), exposes a domain-friendly API.
- [ ] Repository registered through `@LazySingleton` (or DI module).
- [ ] `make gen_all` run; generated files staged.

## Common mistakes

- Mutable lists/maps in DTOs (drop the default and end up with nullables).
- Repositories making `Dio` calls directly, bypassing Retrofit.
- Forgetting `part 'foo.g.dart';` — Retrofit won't compile.
- Reaching into `SharedPreferences` / `FlutterSecureStorage` from presentation or feature code instead of going through the storage seam.
- Binding `LocalDataManager` / `CoreLocalDataManager` as `@Injectable()` (factory) — the in-memory token cache silently desyncs across consumers. Must be `@lazySingleton`.
- Reusing `@HiveType(typeId: …)` across types when the optional Hive path is used.

## Related

- [`fl-bloc-pattern`](../fl-bloc-pattern/SKILL.md)
- [`fl-error-handling`](../fl-error-handling/SKILL.md)
- [`fl-code-generation`](../fl-code-generation/SKILL.md)
- [`fl-data-reviewer`](../fl-data-reviewer/SKILL.md)
