import 'package:injectable/injectable.dart';

import '../../../../data/data.dart';
import '../../../common.dart';

@injectable
class LanguageHeaderProvider extends HeaderProvider {
  final CoreLocalDataManager localDataManager;
  LanguageHeaderProvider(this.localDataManager);

  @override
  Map<String, String> build() {
    final languageCode = localDataManager.getLocalization() ??
        AppLocale.defaultLocale.languageCode;
    return {
      RequestHeaderKey.language.key: languageCode,
    };
  }
}
