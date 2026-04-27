import 'package:flutter/material.dart';

import '../../../core.dart';

/// A widget that provides a standardized layout for main pages in the
/// application.
///
/// This widget creates a page with a customizable app bar at the top and
/// content area below. It supports features like custom styling, header images,
/// and various scaffold components.
class MainPageForm extends StatelessWidget {
  /// Creates a MainPageForm with customizable appearance and behavior.
  ///
  /// The [floatingActionButtonLocation]
  /// defaults to [FloatingActionButtonLocation.miniEndDocked].
  const MainPageForm({
    Key? key,
    // Content
    this.body,
    this.title,
    this.actions,
    this.extention,

    // Scaffold components
    this.floatingActionButton,
    this.floatingActionButtonLocation =
        FloatingActionButtonLocation.miniEndDocked,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,

    // Appearance
    this.bgColor,
    this.showHeaderShadow,
    this.showHeaderImage,
    this.showAppbarDivider,
    this.appbarColor,
    this.appbarForegroundColor,
    this.hasBottomBorderRadius,
    this.titleMaxLines,
    this.titleStyle,
  }) : super(key: key);

  /// Main content of the page.
  final Widget? body;

  /// Title text displayed in the app bar.
  final String? title;

  /// List of action widgets displayed in the app bar.
  final List<Widget>? actions;

  /// Additional widget displayed below the app bar title.
  final Widget? extention;

  /// Background color for the entire page.
  final Color? bgColor;

  /// Whether to show a shadow below the header.
  final bool? showHeaderShadow;

  /// Whether to show the header background image.
  final bool? showHeaderImage;

  /// Whether to show a divider below the app bar.
  final bool? showAppbarDivider;

  /// Background color for the app bar.
  final Color? appbarColor;

  /// Foreground (text/icon) color for the app bar.
  final Color? appbarForegroundColor;

  /// Whether to apply bottom border radius to the app bar.
  final bool? hasBottomBorderRadius;

  /// Maximum number of lines for the title text.
  final int? titleMaxLines;

  /// Whether the bottom of the screen adjusts when keyboard appears.
  final bool? resizeToAvoidBottomInset;

  /// Custom style for the title text. Default is [TextTheme.titleLarge].
  final TextStyle? titleStyle;

  /// A button displayed floating above [body], in the bottom right corner.
  /// Typically a [FloatingActionButton].
  final Widget? floatingActionButton;

  /// Responsible for determining where the [floatingActionButton] should go.
  /// If null, defaults to [FloatingActionButtonLocation.miniEndDocked].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Bottom navigation bar for the scaffold.
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final screenTheme = _createScreenTheme(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildAppBar(context, screenTheme),
          Expanded(child: body ?? const SizedBox()),
        ],
      ),
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  /// Creates a MainPageFormTheme with widget properties applied.
  MainPageFormTheme _createScreenTheme(BuildContext context) {
    return context.mainPageFormTheme.let((it) {
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
  }

  /// Builds the app bar with title, actions, and styling.
  Widget _buildAppBar(BuildContext context, MainPageFormTheme screenTheme) {
    final appbarColor =
        screenTheme.appbarColor ??
        context.themeColor.appbarBackgroundColor ??
        context.theme.appBarTheme.backgroundColor;

    final appbarForegroundColor =
        screenTheme.appbarForegroundColor ??
        context.themeColor.appbarForegroundColor;

    return Container(
      decoration: BoxDecoration(
        color: appbarColor,
        borderRadius: _getAppBarBorderRadius(screenTheme),
        image: _getHeaderBackgroundImage(screenTheme),
        border: _getAppBarBorder(context, screenTheme),
      ),
      foregroundDecoration: BottomBorderDecoration(
        showBottomBorder: screenTheme.showAppbarDivider == true,
        borderColor: context.themeColor.dividerColor,
        borderWidth: 1,
        borderRadius: _getAppBarBorderRadius(screenTheme),
      ),
      child: AppBar(
        backgroundColor: screenTheme.showHeaderImage == true
            ? Colors.transparent
            : appbarColor,
        foregroundColor: appbarForegroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: _buildAppBarContent(screenTheme, appbarForegroundColor),
        actions: actions,
      ),
    );
  }

  /// Builds the content of the app bar (title and actions).
  Widget _buildAppBarContent(
    MainPageFormTheme screenTheme,
    Color? appbarForegroundColor,
  ) {
    return Text(
      title ?? '',
      style: screenTheme.titleStyle?.copyWith(color: appbarForegroundColor),
      textAlign: TextAlign.center,
      maxLines: screenTheme.titleMaxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Returns the border radius for the app bar based on configuration.
  BorderRadius _getAppBarBorderRadius(MainPageFormTheme screenTheme) {
    return screenTheme.hasBottomBorderRadius == true
        ? const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )
        : BorderRadius.zero;
  }

  /// Returns the header background image if enabled.
  DecorationImage? _getHeaderBackgroundImage(MainPageFormTheme screenTheme) {
    if (screenTheme.showHeaderImage == true &&
        coreImageConstant.imgMainPageFormHeader != null &&
        coreImageConstant.imgMainPageFormHeader!.isNotEmpty) {
      return DecorationImage(
        image: ImageViewProviderFactory(
          coreImageConstant.imgMainPageFormHeader!,
        ).provider,
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      );
    }
    return null;
  }

  /// Returns the app bar bottom border if divider is enabled
  BoxBorder? _getAppBarBorder(
    BuildContext context,
    MainPageFormTheme screenTheme,
  ) {
    if (screenTheme.showAppbarDivider) {
      return Border(
        bottom: BorderSide(color: context.themeColor.dividerColor, width: 1),
      );
    }
    return null;
  }
}
