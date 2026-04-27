import 'package:flutter/material.dart';

import '../../../core.dart';

/// A customizable screen form widget that provides a standard layout with
/// configurable app bar, content area, and scaffold features.
///
/// This widget handles common screen patterns like title, description,
/// back button, and various styling options.
class ScreenForm extends StatefulWidget {
  const ScreenForm({
    Key? key,
    // Appearance
    this.bgColor,
    this.appbarColor,
    this.appbarForegroundColor,
    this.showHeaderImage,
    this.hasBottomBorderRadius,
    this.showAppbarDivider,

    // Layout behavior
    this.resizeToAvoidBottomInset,

    // Header content
    this.title,
    this.description,
    this.titleWidgetBuilder,
    this.titleMaxLines,
    this.titleStyle,
    this.desStyle,

    // Navigation
    this.showBackButton,
    this.backButton,
    this.onBack,
    this.actions = const <Widget>[],

    // Title alignment
    this.centerTitle,
    this.forceCenterTitle,

    // Content
    this.child,
    this.extentions,

    // Scaffold components
    this.floatingActionButton,
    this.floatingActionButtonLocation =
        FloatingActionButtonLocation.miniEndDocked,
    this.bottomNavigationBar,
    this.endDrawer,
    this.drawer,
  }) : super(key: key);

  /// Text to display as the screen title
  final String? title;

  /// Optional description text displayed below the title
  final String? description;

  /// Maximum number of lines for the title text
  final int? titleMaxLines;

  /// Custom style for the title text
  final TextStyle? titleStyle;

  /// Custom style for the description text
  final TextStyle? desStyle;

  /// Custom builder for creating a title widget
  final Widget Function(
    BuildContext context,
    ScreenFormTheme screenTheme,
    String? title,
  )?
  titleWidgetBuilder;

  /// Main content of the screen
  final Widget? child;

  /// Additional content displayed below the app bar
  final Widget? extentions;

  /// Actions to display in the app bar (typically buttons)
  final List<Widget> actions;

  /// Callback when back button is pressed
  final void Function()? onBack;

  /// Custom back button widget
  final Widget? backButton;

  /// Whether to show the back button
  final bool? showBackButton;

  /// Background color for the entire screen
  final Color? bgColor;

  /// Background color for the app bar
  final Color? appbarColor;

  /// Foreground (text/icon) color for the app bar
  final Color? appbarForegroundColor;

  /// Whether to show the header background image
  final bool? showHeaderImage;

  /// Whether the bottom of the screen adjusts when keyboard appears
  final bool? resizeToAvoidBottomInset;

  /// Whether to apply bottom border radius to the app bar
  final bool? hasBottomBorderRadius;

  /// Whether to center the title in the app bar
  final bool? centerTitle;

  /// Whether to show a divider below the app bar
  final bool? showAppbarDivider;

  /// Whether to force center title regardless of other conditions
  final bool? forceCenterTitle;

  /// Floating action button for the scaffold
  final Widget? floatingActionButton;

  /// Position of the floating action button
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Bottom navigation bar for the scaffold
  final Widget? bottomNavigationBar;

  /// End drawer for the scaffold
  final Widget? endDrawer;

  /// Drawer for the scaffold
  final Widget? drawer;

  @override
  _ScreenFormState createState() => _ScreenFormState();
}

class _ScreenFormState extends State<ScreenForm> with AfterLayoutMixin {
  late ThemeData _theme;

  /// Gets the screen form theme with widget overrides applied
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
      desStyle: widget.desStyle ?? it.desStyle ?? _theme.textTheme.titleSmall,
    );
  });

  /// Determines if the title should be centered based on configuration and
  /// content
  bool get isCenterTitle =>
      screenTheme.forceCenterTitle == true ||
      (screenTheme.centerTitle == true &&
          widget.actions.length <= 1 &&
          widget.description?.isNotEmpty != true);

  /// Determines if the app bar should be shown based on content and
  /// configuration
  bool get showAppBar => [
    screenTheme.showBackButton == true,
    widget.title.isNotNullOrEmpty,
    widget.titleWidgetBuilder != null,
    widget.description.isNotNullOrEmpty,
    widget.actions.isNotEmpty,
  ].any((e) => e);

  @override
  void afterFirstLayout(BuildContext context) {
    _updateStatusBarStyle();
  }

  /// Updates the status bar style based on theme and header configuration
  void _updateStatusBarStyle() {
    if (screenTheme.showHeaderImage == true ||
        Theme.brightnessOf(context) == Brightness.dark) {
      context.themeColor.setDarkStatusBar();
    } else {
      context.themeColor.setLightStatusBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    _theme = context.theme;

    return Scaffold(
      backgroundColor: widget.bgColor,
      resizeToAvoidBottomInset:
          widget.resizeToAvoidBottomInset ?? !isAndroidBrowser,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
      body: _buildBody(),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }

  /// Builds the main body of the screen
  Widget _buildBody() {
    return GestureDetector(
      onTap: () => CoreCommonFunction().hideKeyboard(context),
      child: Container(
        color: widget.bgColor ?? themeColor.scaffoldBackgroundColor,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: widget.child ?? const SizedBox()),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar section of the screen
  Widget _buildAppBar() {
    final appbarColor =
        screenTheme.appbarColor ??
        context.themeColor.appbarBackgroundColor ??
        context.theme.appBarTheme.backgroundColor;

    final appbarForegroundColor =
        screenTheme.appbarForegroundColor ??
        context.themeColor.appbarForegroundColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: appbarColor,
        borderRadius: _getAppBarBorderRadius(),
        image: _getHeaderBackgroundImage(),
        border: _getAppBarBorder(),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          if (showAppBar) _buildAppBarContent(appbarForegroundColor),
          if (widget.extentions != null) widget.extentions!,
        ],
      ),
    );
  }

  /// Builds the content of the app bar (back button, title, actions)
  Widget _buildAppBarContent(Color? appbarForegroundColor) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBackButton(appbarForegroundColor),
            Expanded(child: _buildTitleAndDescription(appbarForegroundColor)),
            // Space to balance the back button
            const SizedBox(width: 56),
          ],
        ),
        // Actions are positioned at the end
        Row(mainAxisAlignment: MainAxisAlignment.end, children: widget.actions),
      ],
    );
  }

  /// Builds the back button or a placeholder with equal width
  Widget _buildBackButton(Color? foregroundColor) {
    if (screenTheme.showBackButton == true) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: IconButton(
          key: const ValueKey('screen_form_back_btn'),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
          icon:
              widget.backButton ??
              Icon(Icons.arrow_back, size: 22, color: foregroundColor),
        ),
      );
    } else {
      return const SizedBox(width: 56);
    }
  }

  /// Builds the title and description column
  Widget _buildTitleAndDescription(Color? foregroundColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: isCenterTitle ? Alignment.center : Alignment.centerLeft,
          child: _buildTitle(foregroundColor),
        ),
        if (widget.description.isNotNullOrEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.description!,
            textAlign: isCenterTitle ? TextAlign.center : TextAlign.start,
            style: screenTheme.desStyle?.copyWith(color: foregroundColor),
          ),
        ],
      ],
    );
  }

  /// Builds the title widget, using custom builder if provided
  Widget _buildTitle(Color? foregroundColor) {
    if (widget.titleWidgetBuilder != null) {
      return widget.titleWidgetBuilder!.call(
        context,
        screenTheme,
        widget.title,
      );
    }

    return Text(
      widget.title ?? '',
      style: screenTheme.titleStyle?.copyWith(color: foregroundColor),
      textAlign: isCenterTitle ? TextAlign.center : TextAlign.start,
      maxLines: screenTheme.titleMaxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Returns the border radius for the app bar based on configuration
  BorderRadius _getAppBarBorderRadius() {
    if (screenTheme.hasBottomBorderRadius == true) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }
    return BorderRadius.zero;
  }

  /// Returns the header background image if enabled
  DecorationImage? _getHeaderBackgroundImage() {
    if (screenTheme.showHeaderImage == true &&
        coreImageConstant.imgScreenFormHeader.isNotNullOrEmpty) {
      return DecorationImage(
        image: AssetImage(coreImageConstant.imgScreenFormHeader!),
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      );
    }
    return null;
  }

  /// Returns the app bar bottom border if divider is enabled
  BoxBorder? _getAppBarBorder() {
    if (screenTheme.showAppbarDivider) {
      return Border(
        bottom: BorderSide(color: themeColor.dividerColor, width: 1),
      );
    }
    return null;
  }
}
