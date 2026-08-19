import '../../../../common/definitions.dart';

const detailModuleScreen =
    '''import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '$modelImportKey';
import '${libImportKey}l10n/localization_ext.dart';
import '${presentationImportKey}base/base.dart';
import '${presentationImportKey}extentions/extention.dart';
import '../bloc/${moduleNameKey}_bloc.dart';

part '$moduleNameKey.action.dart';

/// Route arguments for [${classNameKey}Screen].
///
/// Carries either a preloaded [$modelNameKey] (in-app navigation) or just an
/// [id] (deep link), so the screen can render immediately when it already has
/// the object and fetch when it does not.
class ${classNameKey}Args {
  ${classNameKey}Args({this.initial, this.id});

  factory ${classNameKey}Args.fromUrlParams(
    Map<String, dynamic> queryParameters,
  ) => ${classNameKey}Args(id: asOrNull(queryParameters['id']));

  final $modelNameKey? initial;
  final String? id;

  /// Platform-correct payload for `pushBehavior.push(arguments: ...)`: a query
  /// map on web (where `extra` does not survive a reload) and the object
  /// itself elsewhere.
  dynamic get adaptiveArguments {
    if (kIsWeb) {
      return <String, dynamic>{'id': initial?.id ?? id}
        ..removeWhere((key, value) => asOrNull<String>(value).isNullOrEmpty);
    }
    return this;
  }
}

class ${classNameKey}Screen extends StatefulWidget {
  static const String routeName = '/$routeNameKey';

  const ${classNameKey}Screen({super.key, this.args});

  final ${classNameKey}Args? args;

  @override
  State<${classNameKey}Screen> createState() => _${classNameKey}ScreenState();
}

class _${classNameKey}ScreenState extends StateBase<${classNameKey}Screen> {
  final _refreshController = RefreshController(initialRefresh: true);

  @override
  ${classNameKey}Bloc get bloc => BlocProvider.of(context);

  late AppLocalizations trans;

  @override
  void hideLoading() {
    _refreshController
      ..refreshCompleted()
      ..loadComplete();
    super.hideLoading();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    trans = translate(context);
    return ScreenForm(
      child: BlocConsumer<${classNameKey}Bloc, ${classNameKey}State>(
        listener: _blocListener,
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(${classNameKey}State state) {
    return SmartRefresherWrapper(
      enablePullDown: true,
      onRefresh: onRefresh,
      controller: _refreshController,
      child: const SingleChildScrollView(
        // TODO(template): render `state.detail`.
        child: SizedBox.shrink(),
      ),
    );
  }
}
''';
