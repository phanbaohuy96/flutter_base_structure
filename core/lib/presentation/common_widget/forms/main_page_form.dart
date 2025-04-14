import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core.dart';

class MainPageForm extends StatelessWidget {
  final Widget? body;
  final String? title;
  final List<Widget>? actions;
  final Widget? extention;
  final Color? bgColor;
  final bool? showHeaderImage;
  final bool? showHeaderShadow;
  final bool? showAppbarDivider;
  final Color? appbarColor;
  final Color? appbarForegroundColor;
  final bool? hasBottomBorderRadius;
  final int? titleMaxLines;
  final bool? resizeToAvoidBottomInset;

  /// default is [TextTheme.titleLarge]
  final TextStyle? titleStyle;

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

  const MainPageForm({
    Key? key,
    this.body,
    this.title,
    this.actions,
    this.extention,
    this.floatingActionButton,
    this.bgColor,
    this.showHeaderShadow,
    this.showHeaderImage,
    this.showAppbarDivider,
    this.appbarColor,
    this.appbarForegroundColor,
    this.hasBottomBorderRadius,
    this.titleMaxLines,
    this.resizeToAvoidBottomInset,
    this.titleStyle,
    this.floatingActionButtonLocation =
        FloatingActionButtonLocation.miniEndDocked,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenTheme = context.mainPageFormTheme.let((it) {
      return it.copyWith(
        showHeaderImage: showHeaderImage,
        showHeaderShadow: showHeaderShadow,
        showAppbarDivider: showAppbarDivider,
        appbarColor: appbarColor,
        hasBottomBorderRadius: hasBottomBorderRadius,
        appbarForegroundColor: appbarForegroundColor,
        titleMaxLines: titleMaxLines,
        titleStyle: titleStyle ?? it.titleStyle ?? context.textTheme.titleLarge,
      );
    });
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildAppBar(context, screenTheme),
          if (screenTheme.showAppbarDivider) const Divider(),
          Expanded(child: body ?? const SizedBox()),
        ],
      ),
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    MainPageFormTheme screenTheme,
  ) {
    final mediaData = MediaQuery.of(context);
    final appbarColor = screenTheme.appbarColor ?? context.themeColor.primary;
    final appbarSecondaryColor = screenTheme.appbarForegroundColor ??
        context.themeColor.appbarForegroundColor;
    return ClipRRect(
      borderRadius: screenTheme.hasBottomBorderRadius
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            )
          : BorderRadius.zero,
      child: Container(
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
            if (show && coreImageConstant.imgMainPageFormHeader.isNullOrEmpty) {
              return DecorationImage(
                image: ImageViewProviderFactory(
                  coreImageConstant.imgMainPageFormHeader!,
                ).provider,
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
                mediaData.padding.top,
                24,
              ),
            ),
            if (title != null || actions != null)
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Text(
                      title ?? '',
                      style: screenTheme.titleStyle?.copyWith(
                        color: appbarSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: screenTheme.titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(width: 16),
                        ...actions ?? const <Widget>[],
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              ),
            extention ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}
