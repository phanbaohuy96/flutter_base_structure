import 'package:core/core.dart';
import 'package:flutter/material.dart';

typedef MainDashboardFactoryBuilder =
    Widget Function(BuildContext context, PageController controller);

class MainDashboardFactory extends StatefulWidget {
  const MainDashboardFactory({
    super.key,
    required this.pages,
    this.currentPageIndex,
    this.onPageChanged,
    this.floatingActionButtonBuilder,
    this.floatingActionButtonLocation,
  });

  final int? currentPageIndex;
  final List<MainDashboardItem> pages;

  final MainDashboardFactoryBuilder? floatingActionButtonBuilder;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final Function(int value)? onPageChanged;

  @override
  State<MainDashboardFactory> createState() => MainDashboardFactoryState();
}

class MainDashboardFactoryState extends State<MainDashboardFactory> {
  /// Can access through the [GlobalKey.currentState]
  late final controller = PageController(
    initialPage: widget.currentPageIndex ?? 0,
  );

  late ThemeData theme;

  void _onItemTapped(int index) {
    if (controller.page?.toInt() != index) {
      jumpToPage(index);
    }
  }

  /// Can access through the [GlobalKey.currentState]
  Future<void> jumpToPage(int index) async {
    controller.jumpToPage(index);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MainDashboardFactory oldWidget) {
    if (oldWidget.currentPageIndex != widget.currentPageIndex &&
        widget.currentPageIndex != null) {
      _setupCurrentPage();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _setupCurrentPage() {
    jumpToPage(widget.currentPageIndex ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    theme = context.theme;
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        onPageChanged: widget.onPageChanged,
        children: [...widget.pages.map((e) => e.page)],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final currentIndex = controller.page?.toInt() ?? 0;
          return BottomNavigationBar(
            items: [
              ...widget.pages.mapIndex(
                (e, idx) => _buildBottomNavigationBarItem(
                  icon: e.bottomNavItem.icon,
                  label: e.bottomNavItem.label,
                  selected: currentIndex == idx,
                ),
              ),
            ],
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            selectedItemColor: themeColor.titleText,
            unselectedItemColor: const Color(0xff49454F),
            showUnselectedLabels: true,
            backgroundColor: themeColor.surface,
            onTap: _onItemTapped,
          );
        },
      ),
      floatingActionButton: widget.floatingActionButtonBuilder?.call(
        context,
        controller,
      ),
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem({
    Widget? icon,
    String? label,
    required bool selected,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: icon,
      ),
      label: label,
    );
  }
}

class MainDashboardItem {
  final Widget page;
  final BottomNavItem bottomNavItem;

  const MainDashboardItem({required this.page, required this.bottomNavItem});
}

class BottomNavItem {
  final String? label;
  final Widget? icon;

  const BottomNavItem({this.label, this.icon});
}
