import 'package:flutter/foundation.dart';

import '../../../core.dart';

/// A mixin that provides delegation capabilities for handling errors
/// and loading states.
///
/// This mixin allows objects to register handlers for error notifications
/// and loading state changes, enabling a centralized way to manage UI feedback
/// across the application.
mixin CoreDelegate {
  final _errorHandlers = <void Function(ErrorData)>[];
  final _loadingHandlers = <void Function(bool)>[];

  /// Notifies all registered error handlers with the provided error data.
  void notifyError(ErrorData error) {
    for (final errorHandler in _errorHandlers) {
      errorHandler.call(error);
    }
  }

  /// Registers an error handler to be called when [notifyError] is invoked.
  void addErrorHandler(void Function(ErrorData) errorHandler) {
    _errorHandlers.add(errorHandler);
  }

  /// Removes a previously registered error handler.
  void removeErrorHandler(void Function(ErrorData) errorHandler) {
    if (_errorHandlers.contains(errorHandler)) {
      _errorHandlers.remove(errorHandler);
    }
  }

  /// Shows loading state by notifying all registered loading handlers
  /// with `true`.
  void showLoading() {
    for (final loadingHandler in _loadingHandlers) {
      loadingHandler.call(true);
    }
  }

  /// Hides loading state by notifying all registered loading handlers
  /// with `false`.
  void hideLoading() {
    for (final loadingHandler in _loadingHandlers) {
      loadingHandler.call(false);
    }
  }

  /// Registers a loading handler to be called when [showLoading]
  /// or [hideLoading] is invoked.
  ///
  /// The handler receives a boolean parameter indicating the loading state:
  /// - `true` when loading should be shown
  /// - `false` when loading should be hidden
  void addLoadingHandler(void Function(bool) loadingHandler) {
    _loadingHandlers.add(loadingHandler);
  }

  /// Removes a previously registered loading handler.
  void removeLoadingHandler(void Function(bool) loadingHandler) {
    if (_loadingHandlers.contains(loadingHandler)) {
      _loadingHandlers.remove(loadingHandler);
    }
  }

  /// Clears all registered handlers.
  ///
  /// This method should be called when the object is being disposed to prevent
  /// memory leaks and ensure proper cleanup.
  @mustCallSuper
  void clear() {
    _errorHandlers.clear();
    _loadingHandlers.clear();
  }
}
