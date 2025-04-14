import 'package:injectable/injectable.dart';

import '../../../../domain/entity/config.dart';
import '../../../common.dart';

@injectable
class AppConfigHeaderProvider extends HeaderProvider {
  AppConfigHeaderProvider();

  @override
  Map<String, String> build() {
    final appConfig = Config.instance.appConfig;
    return <String, String>{
      RequestHeaderKey.platform.key: appConfig.platformRole,
      RequestHeaderKey.apiKey.key: appConfig.graphqlApiKey,
    };
  }
}
