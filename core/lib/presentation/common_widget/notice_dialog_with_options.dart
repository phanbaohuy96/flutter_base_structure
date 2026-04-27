import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/localization_ext.dart';
import '../extentions/extention.dart';

class NoticeDialogWithOptions extends StatelessWidget {
  final dynamic title;
  final List<Map<String, dynamic>> options;
  final TextStyle? styleOptionTitle;
  final bool useRootNavigator;
  final bool dismissWhenAction;
  final bool barrierDismissible;
  final void Function(int? selectedOption)? onConfirmed;
  final void Function()? onCanceled;
  final int? initialValue;
  final BuildContext parentContext;

  const NoticeDialogWithOptions({
    Key? key,
    required this.title,
    required this.options,
    required this.parentContext,
    this.styleOptionTitle,
    this.useRootNavigator = true,
    this.dismissWhenAction = true,
    this.barrierDismissible = true,
    this.onConfirmed,
    this.onCanceled,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dismissFunc = () {
      if (dismissWhenAction) {
        Navigator.of(context, rootNavigator: useRootNavigator).pop();
      }
    };

    final selectedOptionNotifier = ValueNotifier<int?>(initialValue);
    final localization = parentContext.coreL10n;
    final themeColor = parentContext.themeColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        color: themeColor.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localization.inform,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 12),
                    title is String
                        ? Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: Color(0xFF23262F),
                            ),
                          )
                        : title,
                  ],
                ],
              ),
            ),

            Container(
              height: 0.5,
              color: Colors.grey.withAlpha((0.3 * 255).round()),
            ),

            // Options
            Flexible(
              child: SingleChildScrollView(
                child: ValueListenableBuilder<int?>(
                  valueListenable: selectedOptionNotifier,
                  builder: (context, selectedOption, _) {
                    return RadioGroup<int?>(
                      groupValue: selectedOption,
                      onChanged: (value) {
                        selectedOptionNotifier.value = value;
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(options.length, (index) {
                          final option = options[index];
                          final title = option['title'] as dynamic;
                          final description = option['description'] as dynamic;

                          return Container(
                            decoration: BoxDecoration(
                              color: selectedOption == index
                                  ? themeColor.primary.withAlpha(
                                      (0.05 * 255).round(),
                                    )
                                  : null,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withAlpha(
                                    (0.2 * 255).round(),
                                  ),
                                ),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  selectedOptionNotifier.value = index;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Transform.scale(
                                        scale: 0.9,
                                        child: CupertinoRadio<int?>(
                                          value: index,
                                          activeColor: themeColor.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            title is String
                                                ? Text(
                                                    title,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          selectedOption ==
                                                              index
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                      color: const Color(
                                                        0xFF23262F,
                                                      ),
                                                    ),
                                                  )
                                                : title,
                                            if (description != null) ...[
                                              const SizedBox(height: 4),
                                              description is String
                                                  ? Text(
                                                      description,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            const Color(
                                                              0xFF23262F,
                                                            ).withAlpha(
                                                              (0.7 * 255)
                                                                  .round(),
                                                            ),
                                                        height: 1.3,
                                                      ),
                                                    )
                                                  : description,
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Actions
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withAlpha((0.3 * 255).round()),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: () {
                        dismissFunc.call();
                        onCanceled?.call();
                      },
                      child: Text(
                        localization.cancel,
                        style: TextStyle(
                          fontSize: 17,
                          color: themeColor.primary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 0.5,
                    height: 50,
                    color: Colors.grey.withAlpha((0.3 * 255).round()),
                  ),
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: () {
                        dismissFunc.call();
                        onConfirmed?.call(selectedOptionNotifier.value);
                      },
                      child: Text(
                        localization.confirm,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: themeColor.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
