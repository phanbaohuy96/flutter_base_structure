import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core.dart';

class ScreenForm extends StatefulWidget {
  const ScreenForm({
    Key? key,
    this.bgColor,
    this.appbarColor,
    this.appbarForegroundColor,
    this.showHeaderImage,
    this.resizeToAvoidBottomInset,
    this.showBackButton,
    this.hasBottomBorderRadius,
    this.centerTitle,
    this.showAppbarDivider,
    this.title,
    this.titleWidgetBuilder,
    this.description,
    this.child,
    this.actions = const <Widget>[],
    this.onBack,
    this.extentions,
    this.backButton,
    this.forceCenterTitle,
    this.titleMaxLines,
    this.titleStyle,
    this.desStyle,
    this.floatingActionButton,
    this.floatingActionButtonLocation =
        FloatingActionButtonLocation.miniEndDocked,
    this.bottomNavigationBar,
  }) : super(key: key);

  final String? title;
  final Widget Function(
    BuildContext context,
    ScreenFormTheme screenTheme,
    String? title,
  )? titleWidgetBuilder;
  final String? description;
  final Widget? child;
  final Color? bgColor;
  final Color? appbarColor;
  final Color? appbarForegroundColor;
  final bool? showHeaderImage;
  final List<Widget> actions;
  final void Function()? onBack;
  final bool? resizeToAvoidBottomInset;
  final Widget? extentions;
  final bool? showBackButton;
  final Widget? backButton;
  final bool? hasBottomBorderRadius;
  final bool? centerTitle;
  final bool? showAppbarDivider;
  final bool? forceCenterTitle;
  final int? titleMaxLines;

  /// default is [TextTheme.titleLarge]
  final TextStyle? titleStyle;

  /// default is [TextTheme.titleSmall]
  final TextStyle? desStyle;

  /// A button displayed floating above [body], in the bottom right corner.
  ///
  /// Typically a [FloatingActionButton].
  final Widget? floatingActionButton;

  /// Responsible for determining where the [floatingActionButton] should go.
  ///
  /// If null, the [ScaffoldState] will use the default location,
  /// [FloatingActionButtonLocation.endFloat].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final Widget? bottomNavigationBar;

  @override
  _ScreenFormState createState() => _ScreenFormState();
}

class _ScreenFormState extends State<ScreenForm> with AfterLayoutMixin {
  late ThemeData _theme;
  ScreenFormTheme get screenTheme => context.screenFormTheme.let((it) {
        return it.copyWith(
          showHeaderImage: widget.showHeaderImage,
          showBackButton: widget.showBackButton,
          hasBottomBorderRadius: widget.hasBottomBorderRadius,
          centerTitle: widget.centerTitle,
          showAppbarDivider: widget.showAppbarDivider,
          forceCenterTitle: widget.forceCenterTitle,
          appbarColor: widget.appbarColor,
          appbarForegroundColor: widget.appbarForegroundColor,
          titleMaxLines: widget.titleMaxLines,
          titleStyle:
              widget.titleStyle ?? it.titleStyle ?? _theme.textTheme.titleLarge,
          desStyle:
              widget.desStyle ?? it.desStyle ?? _theme.textTheme.titleSmall,
        );
      });

  @override
  void afterFirstLayout(BuildContext context) {
    if (screenTheme.showHeaderImage) {
      context.themeColor.setDarkStatusBar();
    } else {
      context.themeColor.setLightStatusBar();
    }
  }

  bool get isCenterTitle =>
      screenTheme.forceCenterTitle ||
      (screenTheme.centerTitle &&
          widget.actions.length <= 1 &&
          widget.description?.isNotEmpty != true);

  bool get showAppBar => [
        widget.showBackButton == true,
        widget.title.isNotNullOrEmpty,
        widget.titleWidgetBuilder != null,
        widget.description.isNotNullOrEmpty,
        widget.actions.isNotEmpty,
      ].any((e) => e);

  @override
  Widget build(BuildContext context) {
    _theme = context.theme;

    return Scaffold(
      backgroundColor: widget.bgColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      body: GestureDetector(
        onTap: () => CoreCommonFunction().hideKeyBoard(context),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Material(
                color: widget.bgColor ?? themeColor.scaffoldBackgroundColor,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: widget.child ?? const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }

  Widget _buildAppBar() {
    final appbarColor = screenTheme.appbarColor ??
        context.themeColor.appbarBackgroundColor ??
        context.themeColor.primary;
    final appbarForegroundColor = screenTheme.appbarForegroundColor ??
        context.themeColor.appbarForegroundColor;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: screenTheme.hasBottomBorderRadius.let((border) {
          if (border) {
            return const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            );
          }
          return BorderRadius.zero;
        }),
        image: screenTheme.showHeaderImage.let((show) {
          if (show && coreImageConstant.imgScreenFormHeader.isNotNullOrEmpty) {
            return DecorationImage(
              image: AssetImage(coreImageConstant.imgScreenFormHeader!),
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            );
          }
          return null;
        }),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: const [0.01, 0.01],
          colors: [
            screenTheme.showAppbarDivider ? Colors.black12 : appbarColor,
            appbarColor,
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: max(
              MediaQuery.of(context).padding.top,
              24,
            ),
          ),
          if (showAppBar)
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (screenTheme.showBackButton) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: IconButton(
                          key: const ValueKey('screen_form_back_btn'),
                          onPressed:
                              widget.onBack ?? () => Navigator.pop(context),
                          icon: widget.backButton ??
                              Icon(
                                Icons.chevron_left,
                                size: 26,
                                color: appbarForegroundColor,
                              ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 56),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: isCenterTitle
                                ? Alignment.center
                                : Alignment.centerLeft,
                            child: widget.titleWidgetBuilder?.call(
                                  context,
                                  screenTheme,
                                  widget.title,
                                ) ??
                                Text(
                                  widget.title ?? '',
                                  style: screenTheme.titleStyle?.copyWith(
                                    color: appbarForegroundColor,
                                  ),
                                  textAlign: isCenterTitle
                                      ? TextAlign.center
                                      : TextAlign.start,
                                  maxLines: screenTheme.titleMaxLines,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                          if (widget.description.isNotNullOrEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.description!,
                              textAlign: isCenterTitle
                                  ? TextAlign.center
                                  : TextAlign.start,
                              style: screenTheme.desStyle?.copyWith(
                                color: appbarForegroundColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 56),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...widget.actions,
                  ],
                ),
              ],
            ),
          if (widget.extentions != null) widget.extentions!,
        ],
      ),
    );
  }
}
