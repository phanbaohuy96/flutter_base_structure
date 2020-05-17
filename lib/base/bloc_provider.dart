import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'bloc_base.dart';


class MultiBlocProvider extends StatelessWidget {
  final List<BlocProvider> providers;
  final Widget child;

  const MultiBlocProvider({
    Key key,
    @required this.providers,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: child,
    );
  }
}

mixin BlocProviderSingleChildWidget on SingleChildWidget {}

class BlocProvider<T extends BlocBase> extends SingleChildStatelessWidget
    with BlocProviderSingleChildWidget {
  final Widget child;
  final bool lazy;
  final Dispose<T> _dispose;
  final Create<T> _create;

  BlocProvider({
    Key key,
    @required Create<T> create,
    Widget child,
    bool lazy,
  }) : this._(
          key: key,
          create: create,
          dispose: (_, bloc) => bloc?.dispose(),
          child: child,
          lazy: lazy,
        );

  BlocProvider.value({
    Key key,
    @required T value,
    Widget child,
  }) : this._(key: key, create: (_) => value, child: child);

  BlocProvider._({
    Key key,
    @required Create<T> create,
    Dispose<T> dispose,
    this.child,
    this.lazy,
  })  : _create = create,
        _dispose = dispose,
        super(key: key, child: child);

  static T of<T extends BlocBase>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } on ProviderNotFoundException catch (_) {
      throw FlutterError(
        '''
        BlocProvider.of() called with a context that does not contain a Bloc of type $T.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().
        This can happen if the context you used comes from a widget above the BlocProvider.
        The context used was: $context
        ''',
      );
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    return InheritedProvider<T>(
      create: _create,
      dispose: _dispose,
      lazy: lazy,
      child: child,
    );
  }
}
