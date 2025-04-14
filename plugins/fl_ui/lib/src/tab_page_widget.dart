import 'package:fl_theme/fl_theme.dart';
import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';

class TabBox extends StatelessWidget {
  const TabBox({
    Key? key,
    this.child,
    this.tabBarHeight,
    this.tabBarDecoration,
    this.tabBarMargin,
  }) : super(key: key);

  final Widget? child;
  final double? tabBarHeight;
  final BoxDecoration? tabBarDecoration;
  final EdgeInsetsGeometry? tabBarMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tabBarHeight,
      margin: tabBarMargin,
      decoration: tabBarDecoration ??
          BoxDecoration(
            color: context.theme.primaryColor,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [0.04, 0.04],
              colors: [
                Colors.black.withAlpha((0.05 * 255).round()),
                context.theme.primaryColor,
              ],
            ),
          ),
      child: child,
    );
  }
}

class TabPageWidget extends StatefulWidget {
  final Tab Function(BuildContext context, int index) tabBuilder;
  final Widget Function(BuildContext context, int index) pageBuilder;
  final int length;
  final void Function(
    TabController tabController,
    PageController pageController,
  )? onViewCreated;
  final ScrollPhysics? physics;
  final bool isTabScrollable;
  final Color? pageBackground;
  final bool allowImplicitScrolling;
  final PageController? pageController;
  final void Function(int)? onPageChanged;
  final int initialIndex;
  final BoxDecoration? indicator;
  final Color? indicatorColor;

  final Color? labelColor;
  final Color? unselectedLabelColor;
  final EdgeInsetsGeometry? indicatorPadding;
  final double? tabBarHeight;
  final BoxDecoration? tabBarDecoration;
  final EdgeInsetsGeometry? tabBarPadding;

  const TabPageWidget({
    Key? key,
    required this.tabBuilder,
    required this.pageBuilder,
    required this.length,
    this.onViewCreated,
    this.physics,
    this.isTabScrollable = false,
    this.pageBackground,
    this.allowImplicitScrolling = false,
    this.pageController,
    this.onPageChanged,
    this.initialIndex = 0,
    this.indicator,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorPadding,
    this.tabBarHeight,
    this.tabBarDecoration,
    this.tabBarPadding,
  }) : super(key: key);

  @override
  State<TabPageWidget> createState() => _TabPageWidgetState();
}

class _TabPageWidgetState extends State<TabPageWidget> {
  late final _pageController = PageController(
    initialPage: widget.initialIndex,
  );

  TabController? tabController;

  PageController get pageController => widget.pageController ?? _pageController;

  void onDefaultTabCreated(BuildContext context) {
    DefaultTabController.of(context).let((it) {
      tabController = it;
      widget.onViewCreated?.call(
        tabController!,
        pageController,
      );
    });
  }

  late final debouncer = Debouncer<int>(
    const Duration(milliseconds: 100),
    onPageChanged,
  );

  @override
  void initState() {
    setupAfterFirstLayout();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TabPageWidget oldWidget) {
    if (widget.length != oldWidget.length) {
      setupAfterFirstLayout();
    }
    super.didUpdateWidget(oldWidget);
  }

  void setupAfterFirstLayout() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _defaultTabContext?.let(onDefaultTabCreated);
      pageController.jumpToPage(widget.initialIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  BuildContext? _defaultTabContext;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: widget.length,
      child: Builder(
        builder: (defaultTabContext) {
          _defaultTabContext = defaultTabContext;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBox(
                tabBarHeight: widget.tabBarHeight,
                tabBarDecoration: widget.tabBarDecoration,
                tabBarMargin: widget.tabBarPadding,
                child: TabBar(
                  onTap: (index) => pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  ),
                  indicator: widget.indicator,
                  indicatorPadding: widget.indicatorPadding ?? EdgeInsets.zero,
                  labelColor: widget.labelColor,
                  indicatorColor: widget.indicatorColor,
                  unselectedLabelColor: widget.unselectedLabelColor,
                  isScrollable: widget.isTabScrollable,
                  tabs: [
                    ...List.generate(
                      widget.length,
                      (index) => widget.tabBuilder(context, index),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: widget.pageBackground,
                  child: PageView.builder(
                    controller: pageController,
                    physics: widget.physics ?? const BouncingScrollPhysics(),
                    allowImplicitScrolling: widget.allowImplicitScrolling,
                    onPageChanged: (value) {
                      debouncer.value = value;
                    },
                    itemBuilder: widget.pageBuilder,
                    itemCount: widget.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void onPageChanged(int? value) {
    if (value != null) {
      tabController?.animateTo(value);
      widget.onPageChanged?.call(value);
    }
  }
}
