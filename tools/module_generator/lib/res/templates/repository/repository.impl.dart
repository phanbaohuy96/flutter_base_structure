const repositoryImpl = r'''part of '%%MODULE_NAME%%_repository.dart';

@Injectable(as: %%CLASS_NAME%%Repository)
class %%CLASS_NAME%%RepositoryImpl with DataRepository implements %%CLASS_NAME%%Repository {
  @override
  Future<dynamic> sampleFunc() async {
    const query = '';
    return graphqlProvider.query(
      query,
      (p0) {
        return p0;
      },
      'sample',
      variables: {},
    );
  }
}''';
