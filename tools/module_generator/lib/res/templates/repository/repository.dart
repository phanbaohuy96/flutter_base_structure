import '../../../common/definitions.dart';

/// A REST repository: the retrofit client itself.
///
/// Retrofit generates the implementation from the annotations, so the client
/// *is* the repository — a hand-written contract + impl pair on top of it adds
/// a layer with nothing in it, which is why every real repository in this
/// template (`RestApiRepository`, `StorageRepository`,
/// `DataSourceRestApiRepository`) is a bare `@RestApi()` abstract class. The
/// seam that keeps transport out of `domain/` is the use case above this, not
/// a second interface beside it.
///
/// `factory X(Dio dio) = _X;` is the required shape: `_X` is what
/// `retrofit_generator` writes into the `.g.dart` part, and without the
/// redirect there is no way to construct the client.
///
/// One endpoint, not five. The generated CRUD set was five methods against
/// paths no real API has, so the first thing anyone did was delete four of
/// them; a single worked endpoint teaches the same shape with nothing to
/// clean up.
const restRepository =
    '''import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

$modelImportBlockKey

part '${moduleNameKey}_repository.g.dart';

/// Retrofit client for the $classNameKey endpoints.
///
/// Paths are relative to the Dio base URL (`Config.instance.appConfig
/// .baseApiLayer`), so never hardcode a host here.
@RestApi()
abstract class ${classNameKey}Repository {
  factory ${classNameKey}Repository(Dio dio) = _${classNameKey}Repository;

  /// One endpoint to copy: annotate the verb and the path, name each
  /// parameter with `@Path`, `@Query` or `@Body`, and wrap the payload in the
  /// `ApiResponse` envelope every endpoint in this project answers with. Add
  /// the rest of your endpoints the same way.
  @GET('/$routeNameKey/{id}')
  Future<ApiResponse<$modelNameKey>> getDetail({
    @Path('id') required String id,
  });
}
''';

/// A GraphQL repository: a retrofit transport plus the logic retrofit cannot
/// express.
///
/// REST fits entirely in annotations; GraphQL does not — one endpoint serves
/// every operation, the document has to be assembled from an operation and its
/// fragment, and failures arrive in the body rather than the status code. So
/// the retrofit client here is a single `execute` passthrough and the
/// repository class above it owns the composition and the error check. Both
/// live in one library so the `.g.dart` part covers the client.
const graphqlRepository =
    '''import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

$modelImportBlockKey
import '${moduleNameKey}_fragment.dart';

part '${moduleNameKey}_repository.g.dart';

/// Retrofit transport for the $classNameKey GraphQL operations.
///
/// One endpoint, one method: GraphQL routes by document, not by path, so the
/// empty path resolves to the base URL the client is constructed with — bind
/// it to `Config.instance.appConfig.baseGraphQLUrl` in your DI module.
@RestApi()
abstract class ${classNameKey}GraphqlApi {
  factory ${classNameKey}GraphqlApi(Dio dio, {String baseUrl}) =
      _${classNameKey}GraphqlApi;

  @POST('')
  Future<Map<String, dynamic>> execute(@Body() Map<String, dynamic> body);
}

/// Sends the $classNameKey operations and unwraps their responses.
@injectable
class ${classNameKey}Repository {
  const ${classNameKey}Repository(this._api);

  final ${classNameKey}GraphqlApi _api;

  /// Reads one $classNameKey by [id].
  ///
  /// One operation to copy: post a document from [${classNameKey}Fragment]
  /// with its variables, then read the root field out of `data`. Add the rest
  /// of your operations the same way — one document each, one method each.
  Future<$modelNameKey?> getDetail({required String id}) async {
    final response = await _api.execute(
      ${classNameKey}Fragment.request(
        ${classNameKey}Fragment.query,
        variables: {'id': id},
      ),
    );
    final node = _unwrap(response)?['$camelNameKey'];
    return node is Map<String, dynamic> ? $modelDecodeKey : null;
  }

  /// Returns the `data` payload, or throws when the operation failed.
  ///
  /// GraphQL answers 200 even when the operation failed, so `errors` — not the
  /// status code — is where the failure shows up. Check it before touching
  /// `data`, or a partial response reads as a success.
  Map<String, dynamic>? _unwrap(Map<String, dynamic> response) {
    final errors = response['errors'];
    if (errors is List && errors.isNotEmpty) {
      // TODO(template): translate into a domain error so usecases can switch
      // on intent instead of parsing messages.
      throw StateError('\$errors');
    }
    final data = response['data'];
    return data is Map<String, dynamic> ? data : null;
  }
}
''';
