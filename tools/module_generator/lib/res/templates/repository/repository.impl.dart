import '../../../common/definitions.dart';

const repositoryImpl =
    '''part of '${moduleNameKey}_repository.dart';

@Injectable(as: ${classNameKey}Repository)
class ${classNameKey}RepositoryImpl with DataRepository
    implements ${classNameKey}Repository {
  @override
  Future<dynamic> sampleFunc() async {
    try {
      // TODO: call the real endpoint, e.g. `final dto = await restApi.…`.
      final dto = await Future<dynamic>.value();

      // TODO: translate the DTO into a domain entity before returning so
      // callers in `domain/` never see transport-layer types.
      return dto;
    } on Exception catch (error, stackTrace) {
      // TODO: normalise transport errors into domain errors here (e.g. wrap
      // as AuthError / NotFoundError / NetworkError) so usecases can switch
      // on intent instead of catching raw DioException.
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}''';
