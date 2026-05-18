import '../../../data/data_source/local/local_data_manager.dart';
import '../../../di/core_micro.dart';

mixin StateBaseInjectedMixin {
  /// Core data manager instance
  CoreLocalDataManager get coreLocalDataManager =>
      injector.get<CoreLocalDataManager>();
}
