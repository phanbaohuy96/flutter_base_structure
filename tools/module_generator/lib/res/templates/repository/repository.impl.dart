import '../../../common/definations.dart';

const repositoryImpl = '''part of '${moduleNameKey}_repository.dart';

@Injectable(as: ${classNameKey}Repository)
class ${classNameKey}RepositoryImpl with DataRepository implements ${classNameKey}Repository {
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
