import 'package:flutter/foundation.dart';

import '../../../core.dart';

abstract class CoreBlocBase<E, S> extends Bloc<E, S> {
  final _errorHandlers = <void Function(ErrorData)>[];

  CoreBlocBase(S s) : super(s);

  @override
  void onError(Object error, StackTrace stackTrace) {
    final errorData = ErrorData.fromObject(error: error);
    if (errorData != null) {
      _notifyError(errorData);
    } else {
      logUtils.e('onError', error, stackTrace);
      super.onError(error, stackTrace);
    }
  }

  void _notifyError(ErrorData error) {
    for (final errorHandler in _errorHandlers) {
      errorHandler.call(error);
    }
  }

  void addErrorHandler(void Function(ErrorData) errorHandler) {
    _errorHandlers.add(errorHandler);
  }

  void removeErrorHandler(void Function(ErrorData) errorHandler) {
    if (_errorHandlers.contains(errorHandler)) {
      _errorHandlers.remove(errorHandler);
    }
  }

  @override
  @mustCallSuper
  Future<void> close() async {
    _errorHandlers.clear();
    return super.close();
  }
}
