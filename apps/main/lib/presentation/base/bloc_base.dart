part of 'base.dart';

abstract class AppBlocBase<E, S> extends CoreBlocBase<E, S> {
  LocalDataManager get localDataManager => injector();

  AppBlocBase(S s) : super(s);
}
