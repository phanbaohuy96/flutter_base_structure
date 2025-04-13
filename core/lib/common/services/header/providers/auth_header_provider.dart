import 'package:injectable/injectable.dart';

import '../../../../data/data_source/local/local_data_manager.dart';
import '../../../common.dart';

@injectable
class AuthHeaderProvider extends HeaderProvider {
  final CoreLocalDataManager localDataManager;
  AuthHeaderProvider(
    this.localDataManager,
  );

  @override
  Map<String, String> build() {
    final token = localDataManager.token;
    return {
      if (token != null) ...{
        RequestHeaderKey.authorization.key: token.authorization,
      },
    };
  }
}
