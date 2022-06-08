part of 'base.dart';

abstract class AppBlocBase<E, S> extends Bloc<E, S> {
  Function(ErrorData)? errorHandler;

  LocalDataManager get localDataManager => injector.get();

  AppBlocBase(S s) : super(s);

  EventTransformer<T> debounceSequential<T>(Duration duration) {
    return (events, mapper) =>
        events.debounceTime(duration).asyncExpand(mapper);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (error is OperationException) {
      final glError = error.graphqlErrors.firstOrNull;
      errorHandler?.call(
        ErrorData.fromGraplQL(
          error: GraphQLException.fromJson({
            'message': glError?.message,
            'locations': glError?.locations,
            'path': glError?.path,
            'extensions': glError?.extensions,
          }),
        ),
      );
    } else if (error is Exception) {
      errorHandler?.call(
        ErrorData.fromGraplQL(exception: error),
      );
    } else {
      LogUtils.e('onError', error, stackTrace);
    }
    super.onError(error, stackTrace);
  }
}
