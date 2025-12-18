import 'package:flutter/material.dart';

import '../../../../../core.dart';

class WidgetStoryBook extends StatefulWidget {
  const WidgetStoryBook({super.key});

  @override
  State<WidgetStoryBook> createState() => _WidgetStoryBookState();
}

class _WidgetStoryBookState extends State<WidgetStoryBook> {
  @override
  Widget build(BuildContext context) {
    return TickerBuilder(
      duration: const Duration(seconds: 2),
      builder: (p0, tick) => ListView(
        padding: const EdgeInsets.all(16).copyWith(
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        children: _getStories(tick).insertSeparator(
          (index) => const SizedBox(
            height: 8,
          ),
        ),
      ),
    );
  }

  List<Widget> _getStories(int tick) {
    return <Widget>[
      StoryWidgetBox(
        title: 'fl_ui/AnimatedDropdownIcon',
        builder: (context, _, __) => AnimatedDropdownIcon(
          isExpanded: tick % 2 != 0,
          size: 56,
        ),
      ),
      StoryWidgetBox(
        title: 'fl_ui/AvailabilityWidget',
        description: '${tick % 2 == 0 ? 'Enabled' : 'Disabled'}',
        builder: (context, _, __) => AvailabilityWidget(
          enable: tick % 2 == 0,
          child: Text(
            'data',
            style: context.textTheme.headlineLarge?.copyWith(
              color: context.theme.colorScheme.primary,
            ),
          ),
        ),
      ),
      StoryWidgetBox(
        title: 'fl_ui/BadgeBox',
        builder: (context, _, __) => Align(
          child: BadgeBox(
            count: tick,
            child: const Icon(
              Icons.notifications,
              size: 32,
            ),
          ),
        ),
      ),
      StoryWidgetBox(
        title: 'fl_ui/BannerWidget',
        builder: (context, _, __) {
          final banners = <String>[
            'https://storage.googleapis.com/cms-storage-bucket/images/image001.width-1440.format-webp-lossless.webp',
            'https://storage.googleapis.com/cms-storage-bucket/images/image001.width-1440.format-webp-lossless.webp',
          ];
          return IntrinsicHeight(
            child: Row(
              children: [
                ...BannerWidgetUIStyle.values.map(
                  (e) => Expanded(
                    child: StoryWidgetBox(
                      description: e.toString(),
                      builder: (context, _, __) => BannerWidget<String>(
                        banners: banners,
                        ratio: 3 / 1,
                        getImageUrl: (e) => e,
                        padding: const EdgeInsets.symmetric(),
                        uiStyle: e,
                        itemBorderRadius: BorderRadius.circular(4),
                        onTap: (p0) => openImageGallery(
                          context: context,
                          images: banners,
                          focusIndex: banners.indexOf(p0),
                        ),
                        autoPlayInterval: const Duration(seconds: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      StoryWidgetBox(
        title: 'fl_ui/BoxColor',
        builder: (context, _, __) {
          return Wrap(
            children: [
              BoxColor(
                borderRadius: BorderRadius.circular(6),
                color: Colors.red,
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                child: const Text(
                  'BoxColor#Red#Padding(6,4,6,4)#Radius(6)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              HighlightBoxColor(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                borderRadius: BorderRadius.circular(6),
                margin: const EdgeInsets.only(top: 4),
                child: const Text(
                  'HighlightBoxColor#Padding(6,4,6,4)#Radius(6)',
                ),
              ),
            ],
          );
        },
      ),
      StoryWidgetBox(
        title: 'fl_ui/CheckBox',
        builder: (context, _, __) {
          return Column(
            children: [
              CheckboxWithTitle(
                value: tick % 2 == 0,
                title: 'CheckboxWithTitle',
              ),
            ],
          );
        },
      ),
      StoryWidgetBox(
        title: 'fl_ui/CheckBoxGroup',
        builder: (context, _, __) {
          final items = List.generate(3, (index) => index);
          return Column(
            children: [
              CheckBoxGroup<int>(
                items: items,
                getLabel: (p0) {
                  return 'CheckBox-$p0';
                },
                selectedItems: [...items.where((e) => e <= tick % 3)],
                onSelectedChanged: (p0) {
                  debugPrint(p0.toString());
                },
              ),
            ],
          );
        },
      ),
      StoryWidgetBox(
        title: 'fl_ui/Radio',
        builder: (context, _, __) {
          return Column(
            children: [
              RadioButtonWithTitle(
                value: 0,
                groupValue: tick % 2,
                title: 'RadioButtonWithTitle 0',
              ),
              RadioButtonWithTitle(
                value: 1,
                groupValue: tick % 2,
                title: 'RadioButtonWithTitle 1',
              ),
              StoryWidgetBox(
                title: 'fl_ui/RadioGroup',
                builder: (context, _, __) {
                  final items = List.generate(3, (index) => index);
                  return Column(
                    children: [
                      RadioGroup<int>(
                        items: items,
                        selectedItem: tick % items.length,
                        getLabel: (p0) {
                          return 'RadioItem-$p0';
                        },
                        onSelected: (p0) {},
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
      StoryWidgetBox(
        title: 'fl_ui/EnViSwitch',
        builder: (context, _, __) {
          return Center(
            child: EnViSwitch(
              isVILanguage:
                  context.read<AppGlobalBloc>().state.locale.languageCode ==
                      AppLocale.th.languageCode,
              onChanged: (isViLanguage) {
                context
                    .read<AppGlobalBloc>()
                    .changeLocale(isViLanguage ? AppLocale.th : AppLocale.en);
              },
            ),
          );
        },
      ),
      StoryWidgetBox(
        title: 'fl_ui/VerticalStepper',
        builder: (context, _, __) {
          return VerticalStepper(
            steps: List.generate(
              3,
              (idx) => StepData(
                step: HighlightBoxColor(
                  borderColor: tick % 4 - 1 >= idx
                      ? themeColor.primary
                      : Theme.of(context).dividerTheme.color!,
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(16),
                  child: Text(
                    (idx + 1).toString(),
                    style: TextStyle(
                      color: tick % 4 - 1 >= idx ? themeColor.primary : null,
                    ),
                  ),
                ),
                title: Text(
                  'Step ${idx + 1}',
                  style: TextStyle(
                    color: tick % 4 - 1 >= idx ? themeColor.primary : null,
                  ),
                ),
                content: HighlightBoxColor(
                  borderColor: tick % 4 - 1 >= idx
                      ? themeColor.primary
                      : Theme.of(context).dividerTheme.color!,
                  alignment: Alignment.center,
                  child: Text(
                    'Step $idx Widget',
                    style: TextStyle(
                      color: tick % 4 - 1 >= idx ? themeColor.primary : null,
                    ),
                  ),
                ),
                dividerColor: tick % 4 - 1 >= idx
                    ? themeColor.primary
                    : Theme.of(context).dividerTheme.color!,
                showDivider: tick % 4 - 1 >= idx,
              ),
            ),
          );
        },
      ),
      StoryWidgetBox<int>(
        title: 'fl_ui/CustomTabbar',
        initial: 0,
        builder: (context, update, value) {
          return CustomTabbar(
            selectedIdx: value!,
            titles: const ['title 1', 'title 2'],
            onTap: (p0) async {
              update(p0);
              return true;
            },
          );
        },
      ),
      StoryWidgetBox(
        title: 'fl_ui/InfoItem',
        builder: (context, _, __) {
          return const Column(
            children: [
              InfoItem(
                titleFlex: 2,
                valueFlex: 3,
                title: 'Text Title',
                value: 'text value',
                divider: ItemDivider.space,
              ),
              InfoItem(
                titleFlex: 2,
                valueFlex: 3,
                title: Text('Widget get title'),
                value: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Widget get value'),
                ),
                divider: ItemDivider.none,
              ),
            ],
          );
        },
      ),
      StoryWidgetBox(
        title: 'fl_ui/MenuItemWidget',
        builder: (context, _, __) {
          return Column(
            children: [
              MenuItemWidget(
                description: const Text('Widget'),
                onTap: () {
                  showToast(context, 'onTap');
                },
                divider: ItemDivider.space,
                itemBorder: ItemBorder.all,
                title: 'Title',
                icon: const Icon(
                  Icons.home,
                  size: 16,
                ),
              ),
              MenuItemWidget(
                description: const Text('5.000\$'),
                onTap: () {
                  showToast(context, 'onTap');
                },
                divider: ItemDivider.line,
                itemBorder: ItemBorder.top,
                title: 'Wallet',
                tailIcon: const Icon(
                  Icons.delete,
                  size: 16,
                ),
                icon: const Icon(
                  Icons.wallet,
                  size: 16,
                ),
              ),
              MenuItemWidget(
                onTap: () {
                  showToast(context, 'Delete account');
                },
                divider: ItemDivider.none,
                itemBorder: ItemBorder.bottom,
                title: 'Delete account',
                tailIcon: const Icon(
                  Icons.delete,
                  size: 16,
                ),
                icon: const Icon(
                  Icons.person,
                  size: 16,
                ),
              ),
            ],
          );
        },
      ),
      StoryWidgetBox<ErrorBoxController>(
        title: 'fl_ui/ErrorBox',
        builder: (context, update, controller) {
          if (controller == null) {
            update(ErrorBoxController());
            return const SizedBox();
          }
          return Column(
            children: [
              ErrorBox(
                borderRadius: BorderRadius.circular(12),
                controller: controller,
                normalBorderColor: themeColor.dividerColor,
                errorTextPadding: EdgeInsets.zero,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text('Any Widget'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ThemeButton.outline(
                    title: 'Set Error',
                    onPressed: () {
                      controller.setError('Error text');
                    },
                    minimumSize: const Size(
                      88,
                      32,
                    ),
                  ),
                  ThemeButton.outline(
                    title: 'Clear Error',
                    onPressed: () {
                      controller.clear();
                    },
                    minimumSize: const Size(
                      88,
                      32,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      StoryWidgetBox(
        title: 'fl_ui/ReceiptShapeBorder',
        description: 'Demo ReceiptShapeBorder with Separator widget',
        builder: (context, _, __) {
          return Material(
            color: themeColor.surface,
            shape: ReceiptShapeBorder(
              borderColor: themeColor.primary,
              borderWidth: 1,
            ),
            child: Container(
              height: 80,
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('Any widget'),
                  Separator(
                    color: context.themeColor.primary,
                  ),
                  const Text('Separated by Separator widget'),
                ],
              ),
            ),
          );
        },
      ),
      StoryWidgetBox(
        title: 'fl_ui/LayoutSwitching',
        builder: (context, _, __) {
          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            padding: EdgeInsets.zero,
            mainAxisSpacing: 2.0,
            crossAxisSpacing: 2.0,
            children: [
              ...SwitchingAnimation.values.map(
                (e) => StoryWidgetBox(
                  description: e.toString(),
                  builder: (context, _, __) {
                    return ClipRRect(
                      child: LayoutSwitching(
                        duration: const Duration(seconds: 1),
                        isFirstLayout: tick % 2 == 0,
                        direction: e,
                        first: Container(
                          color: Colors.blue.withAlpha((0.1 * 255).round()),
                          alignment: Alignment.center,
                          child: const Text('first widget'),
                        ),
                        second: Container(
                          color: Colors.red.withAlpha((0.1 * 255).round()),
                          alignment: Alignment.center,
                          child: const Text('second widget'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      StoryWidgetBox(
        title: 'core/GenderSelection',
        builder: (context, _, __) {
          return GenderSelection(
            required: true,
            title: 'Gender',
            defaultGender:
                tick % 2 == 0 ? ServerGender.male : ServerGender.female,
            onChange: (p0) {},
          );
        },
      ),
    ];
  }
}
