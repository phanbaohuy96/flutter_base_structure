import '../../../common/components/graphql/graphql_provider.dart';
import '../../../di/di.dart';
import 'local/local_data_manager.dart';
import 'remote/app_api_service.dart';

mixin DataRepository {
  late final graphqlProvider = GraphqlProvider(
    injector.get<AppApiService>().graphQLClient,
  );

  late final localDataManager = injector.get<LocalDataManager>();
}
