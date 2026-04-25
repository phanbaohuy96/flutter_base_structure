---
name: data-layer
description: Builds the data layer with Freezed DTOs, Retrofit clients, hive_ce local stores, and repositories wired through injectable
license: MIT
compatibility: all
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
| Local store | `hive_ce` + `hive_ce_generator` | `*.g.dart` |
| DI | `injectable` + `injectable_generator` | `*.config.dart` |

The shared module `modules/data_source/` exposes Retrofit + hive_ce plumbing; per-feature clients live there or, for app-specific endpoints, under `apps/main/lib/data/data_source/`. Models that are shared across apps go in `core/lib/data/models/`.

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

## Hive local store

For simple key/value caches use a hive_ce-backed data source. Generated boxes live under `data_source/local/` and surface a single class consumed by the repository.

```dart
@HiveType(typeId: 7)
class UserHive extends HiveObject {
  UserHive({required this.id, required this.name});

  @HiveField(0) final String id;
  @HiveField(1) final String name;
}
```

Don't reuse a `typeId` — pick a unique one across the app.

## Repository

Repositories accept the API client (and optionally a local data source) by constructor and decide cache/refresh policy. They are the only layer feature blocs depend on.

```dart
import 'package:injectable/injectable.dart';

import '../api/user_api_client.dart';
import '../models/user_model.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._api);

  final UserApiClient _api;

  @override
  Future<UserModel> getUser(String id) => _api.getUser(id);

  @override
  Future<List<UserModel>> getUsers({int page = 1, int limit = 20}) =>
      _api.getUsers(page: page, limit: limit);
}
```

Errors surface as `DioException` and are translated by the screen-level error handler (see `error-handling`). Don't wrap them at the repository layer unless you need a domain-specific failure type.

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
- Reusing `@HiveType(typeId: …)` across types.

## Related

- [`bloc-pattern`](../bloc-pattern/SKILL.md)
- [`error-handling`](../error-handling/SKILL.md)
- [`code-generation`](../code-generation/SKILL.md)
- [`data-reviewer`](../data-reviewer/SKILL.md)
