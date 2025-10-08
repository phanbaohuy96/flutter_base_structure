import 'package:flutter/foundation.dart';

import '../../../core.dart';
import '../delegate.dart';

abstract class CoreBlocBase<E, S> extends Bloc<E, S> with CoreDelegate {
  CoreBlocBase(S s) : super(s);

  @override
  void onError(Object error, StackTrace stackTrace) {
    final errorData = ErrorData.fromObject(error: error);
    if (errorData != null) {
      notifyError(errorData);
    } else {
      logUtils.e('onError', error, stackTrace);
      super.onError(error, stackTrace);
    }
  }

  @override
  @mustCallSuper
  Future<void> close() async {
    clear();
    return super.close();
  }
}
