import '../../../../common/definitions.dart';

const listingModuleScreen =
    '''import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '$modelFilterImportKey';
import '${libImportKey}l10n/localization_ext.dart';
import '${presentationImportKey}base/base.dart';
import '${presentationImportKey}extentions/extention.dart';
import '../bloc/${moduleNameKey}_bloc.dart';

part '$moduleNameKey.action.dart';

/// Route arguments for [${classNameKey}Screen].
///
/// Carries the [${modelNameKey}Filter] the listing should open with, so an
/// in-app caller and a deep link land on the same filtered view instead of
/// the caller having to re-apply the filter after the first frame.
class ${classNameKey}Args {
  const ${classNameKey}Args({this.filter});

  factory ${classNameKey}Args.fromUrlParams(
    Map<String, dynamic> queryParameters,
  ) => ${classNameKey}Args(
    filter: ${modelNameKey}Filter.fromQuery(queryParameters),
  );

  final ${modelNameKey}Filter? filter;

  /// Platform-correct payload for `pushBehavior.push(arguments: ...)`: a query
  /// map on web (where `extra` does not survive a reload) and the object
  /// itself elsewhere.
  dynamic get adaptiveArguments {
    if (kIsWeb) {
      return <String, dynamic>{...?filter?.query};
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
          return _buildListing(state);
        },
      ),
    );
  }

  Widget _buildListing(${classNameKey}State state) {
    // TODO(template): show `EmptyData(message: ...)` when `state.items` is
    // empty, using a key from your localization CSV.
    return SmartRefresherWrapper(
      enablePullDown: true,
      enablePullUp: state.canLoadMore,
      onLoading: loadMore,
      onRefresh: onRefresh,
      controller: _refreshController,
      child: ListView.separated(
        itemBuilder: (context, index) {
          // TODO(template): render `state.items[index]`.
          return const SizedBox.shrink();
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 16);
        },
        itemCount: state.items.length,
      ),
    );
  }
}
''';
