import 'package:flutter/material.dart';

import '../../../core.dart';
import '../../../l10n/localization_ext.dart';

class DateRangeUtils {
  List<MapEntry<String, DateRange>> generateSuggestions(BuildContext context) {
    final now = DateTime.now().startOfDay;
    final trans = context.coreL10n;
    return {
      trans.fullTime: const DateRange(
        from: null,
        to: null,
      ),
      trans.today: DateRange(
        from: now.startOfDay,
        to: now.endOfDay,
      ),
      trans.yesterday: DateRange(
        from: now.copyWith().subtract(const Duration(days: 1)).startOfDay,
        to: now.copyWith().subtract(const Duration(days: 1)).endOfDay,
      ),
      trans.threeDaysAgo: DateRange(
        from: now.copyWith().startPrev3Days,
        to: now.copyWith().endPrev3Days,
      ),
      trans.thisWeek: DateRange(
        from: now.copyWith().startThisWeek,
        to: now.copyWith().endThisWeek,
      ),
      trans.weekAgo: DateRange(
        from: now.copyWith().startPrevWeek,
        to: now.copyWith().endPrevWeek,
      ),
      trans.sevenDaysAgo: DateRange(
        from: now.copyWith().startPrev7Days,
        to: now.copyWith().endPrev7Days,
      ),
      trans.thisMonth: DateRange(
        from: now.copyWith().startThisMonth,
        to: now.copyWith().endThisMonth,
      ),
      trans.monthAgo: DateRange(
        from: now.copyWith().startPrevMonth,
        to: now.copyWith().endPrevMonth,
      ),
      trans.thirtyDaysAgo: DateRange(
        from: now.copyWith().startPrev30Days,
        to: now.copyWith().endPrev30Days,
      ),
      trans.thisQuarter: DateRange(
        from: now.copyWith().startOfQuarter,
        to: now.copyWith().endOfQuarter,
      ),
      trans.quarterAgo: DateRange(
        from: now.copyWith().startPrevQuarter,
        to: now.copyWith().endPrevQuarter,
      ),
      trans.thisYear: DateRange(
        from: now.copyWith().startOfYear,
        to: now.copyWith().endOfYear,
      ),
      trans.yearAgo: DateRange(
        from: now.copyWith().startPrevYear,
        to: now.copyWith().endPrevYear,
      ),
    }.entries.toList();
  }

  MapEntry<String, DateRange> getManualOption(
    DateRange? initial,
    BuildContext context,
  ) {
    final trans = context.coreL10n;
    return MapEntry(
      trans.manual,
      initial ?? const DateRange(),
    );
  }
}

class DateRangePickerWidget extends StatelessWidget {
  const DateRangePickerWidget({
    super.key,
    required this.initial,
    required this.calendarIcon,
    this.title,
    this.onChanged,
    this.showTimePickerTo,
    this.showTimePickerFrom,
  });

  final DateRange? initial;
  final void Function(DateRange range)? onChanged;
  final String? title;
  final String calendarIcon;
  final bool? showTimePickerTo;
  final bool? showTimePickerFrom;

  DateRange get _dateRange => initial ?? const DateRange();

  @override
  Widget build(BuildContext context) {
    final trans = context.coreL10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._buildDateSuggestionSection(
          context,
          trans,
        ),
        if (showTimePickerFrom != false) ...[
          const SizedBox(height: 12),
          DateInputCalendarPicker(
            onDateSelected: (date) {
              onChanged?.call(
                _dateRange.copyWith(
                  from: date.startOfDay,
                ),
              );
            },
            hint: trans.selectDate,
            monthStr: trans.month,
            title: trans.fromDate,
            initial: _dateRange.from,
            calendarIcon: calendarIcon,
            maxDate: _dateRange.to,
          ),
        ],
        if (showTimePickerFrom != false && showTimePickerTo != false) ...[
          const SizedBox(height: 12),
        ],
        if (showTimePickerTo != false) ...[
          const SizedBox(height: 12),
          DateInputCalendarPicker(
            onDateSelected: (date) {
              onChanged?.call(
                _dateRange.copyWith(
                  to: date.endOfDay,
                ),
              );
            },
            hint: trans.selectDate,
            monthStr: trans.month,
            title: trans.toDate,
            initial: _dateRange.to,
            calendarIcon: calendarIcon,
            minDate: _dateRange.from,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildDateSuggestionSection(
    BuildContext context,
    CoreLocalizations trans,
  ) {
    return [
      if (title.isNotNullOrEmpty) ...[
        Text(
          title!.capitalizeFirst(),
          style: context.textTheme.labelLarge?.copyWith(
            color: const Color(0xff646464),
          ),
        ),
        const SizedBox(height: 12),
      ],
      _buildDateSuggestions(context, trans),
    ];
  }

  Widget _buildDateSuggestions(
    BuildContext context,
    CoreLocalizations trans,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...DateRangeUtils().generateSuggestions(context).map(
              (entry) => ChipItem(
                text: entry.key,
                selected: _dateRange.campareDate(entry.value),
                textTheme: context.textTheme,
                constraints: const BoxConstraints(),
                onTap: (selected) {
                  onChanged?.call(
                    (selected == false ? entry.value : const DateRange()).let(
                      (e) => e.copyWith(
                        from: e.from?.startOfDay,
                        to: e.to?.endOfDay,
                      ),
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }
}

class _DateRangePickerModal extends StatefulWidget {
  const _DateRangePickerModal({
    required this.initial,
    this.defaultValue,
    this.leftBtnLabel,
    this.rightBtnLabel,
  });

  final DateRange? initial;
  final DateRange? defaultValue;
  final String? leftBtnLabel;
  final String? rightBtnLabel;

  @override
  State<_DateRangePickerModal> createState() => _DateRangePickerModalState();
}

class _DateRangePickerModalState extends State<_DateRangePickerModal>
    with AfterLayoutMixin {
  MapEntry<String, DateRange?>? selected;

  DateRange get dateRange => selected?.value ?? const DateRange();

  @override
  void afterFirstLayout(BuildContext context) {
    final initial = widget.initial ?? const DateRange();
    setState(() {
      selected = DateRangeUtils().generateSuggestions(context).firstWhere(
        (entry) {
          return entry.value.campareDate(initial);
        },
        orElse: () => MapEntry(
          context.coreL10n.manual,
          initial,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selected == null) {
      return const SizedBox();
    }
    final trans = context.coreL10n;
    final options = [
      ...DateRangeUtils().generateSuggestions(context),
      MapEntry(trans.manual, selected!.value),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
              bottom: 16,
            ),
            children: [
              ...options.mapIndex(
                (e, index) => Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (e.key == options.last.key) {
                            selected = MapEntry(e.key, selected!.value);
                          } else {
                            selected = e;
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.key,
                            ),
                          ),
                          Radio<String>(
                            activeColor: themeColor.primary,
                            value: e.key,
                            // ignore: deprecated_member_use
                            groupValue: selected!.key,
                            // ignore: deprecated_member_use
                            onChanged: (value) {
                              setState(() {
                                if (value == options.last.key) {
                                  selected = MapEntry(e.key, selected!.value);
                                } else {
                                  selected = e;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (index == options.length - 1 &&
                        selected!.key == e.key) ...[
                      DateInputCalendarPicker(
                        onDateSelected: (selectedDate) {
                          setState(() {
                            selected = MapEntry(
                              selected!.key,
                              dateRange.copyWith(
                                from: selectedDate.startOfDay,
                              ),
                            );
                          });
                        },
                        hint: trans.selectDate,
                        monthStr: trans.month,
                        title: trans.fromDate,
                        initial: dateRange.from,
                        maxDate: dateRange.to,
                      ),
                      const SizedBox(height: 24),
                      DateInputCalendarPicker(
                        onDateSelected: (selectedDate) {
                          setState(() {
                            selected = MapEntry(
                              selected!.key,
                              dateRange.copyWith(
                                to: selectedDate.endOfDay,
                              ),
                            );
                          });
                        },
                        hint: trans.selectDate,
                        monthStr: trans.month,
                        title: trans.toDate,
                        initial: dateRange.to,
                        minDate: dateRange.from,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        FooterWidget(
          child: Row(
            children: [
              if (widget.defaultValue != null) ...[
                Expanded(
                  child: ThemeButton.outline(
                    title: widget.leftBtnLabel ?? trans.reset,
                    onPressed: () {
                      Navigator.pop(
                        context,
                        widget.defaultValue,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: ThemeButton.primary(
                  title: widget.rightBtnLabel ?? trans.apply,
                  onPressed: () {
                    Navigator.pop(context, dateRange);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

typedef DateRangePickerWidgetBuilder = Widget Function(
  BuildContext context,
  DateRange? value,
  String formartedText,
);

class DateRangePickerBuilder extends StatelessWidget {
  const DateRangePickerBuilder({
    super.key,
    this.initial,
    this.defaultValue,
    this.leftBtnLabel,
    this.rightBtnLabel,
    this.onChanged,
    required this.builder,
  });

  final DateRange? initial;
  final DateRange? defaultValue;
  final String? leftBtnLabel;
  final String? rightBtnLabel;
  final void Function(DateRange)? onChanged;
  final DateRangePickerWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final trans = context.coreL10n;
    final manualOption = DateRangeUtils().getManualOption(initial, context);
    final selected = initial == null
        ? manualOption
        : DateRangeUtils().generateSuggestions(context).firstWhere(
            (entry) {
              return entry.value.campareDate(initial!);
            },
            orElse: () => manualOption,
          );
    return InkWell(
      child:
          builder(context, selected.value, _getLabel(context, trans, selected)),
      onTap: () async {
        final d = await context.showDateRangePickerModal(
          initial: initial,
          defaultValue: defaultValue,
          leftBtnLabel: leftBtnLabel,
          rightBtnLabel: rightBtnLabel,
        );
        if (d != null) {
          onChanged?.call(d);
        }
      },
    );
  }

  String _getLabel(
    BuildContext context,
    CoreLocalizations trans,
    MapEntry<String, DateRange> selected,
  ) {
    final dateRange = selected.value;
    final timeStr = (dateRange.from ?? dateRange.to)?.toDateRangeString(
      endDate: dateRange.to ?? dateRange.from!,
      locale: context.appDateLocale,
    );
    return [
      '${selected.key}',
      if (timeStr.isNotNullOrEmpty)
        [
          if (dateRange.from == null && dateRange.to != null)
            trans.toDate.toLowerCase(),
          if (dateRange.from != null && dateRange.to == null)
            trans.fromDate.toLowerCase(),
          if (dateRange.from != null && dateRange.to != null)
            trans.day.toLowerCase(),
          timeStr!,
        ].join(' '),
    ].join(', ');
  }
}

class DateRangePickerLabel extends StatelessWidget {
  const DateRangePickerLabel({
    super.key,
    this.initial,
    this.defaultValue,
    this.leftBtnLabel,
    this.rightBtnLabel,
    this.onChanged,
    this.prefixIcon,
    this.textStyle,
  });

  final DateRange? initial;
  final DateRange? defaultValue;
  final String? leftBtnLabel;
  final String? rightBtnLabel;
  final Widget? prefixIcon;
  final TextStyle? textStyle;
  final void Function(DateRange)? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    final _textStyle = textStyle ?? textTheme.bodySmall;
    return DateRangePickerBuilder(
      builder: (context, value, formartedText) => Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              child: prefixIcon ??
                  Icon(
                    Icons.calendar_month_outlined,
                    size: (_textStyle?.fontSize ?? 0) * 1.3,
                    color: _textStyle?.color,
                  ),
              alignment: PlaceholderAlignment.middle,
            ),
            const WidgetSpan(
              child: SizedBox(
                width: 4,
              ),
            ),
            TextSpan(
              text: formartedText,
            ),
            const WidgetSpan(
              child: SizedBox(
                width: 2,
              ),
            ),
            WidgetSpan(
              child: Icon(
                Icons.keyboard_arrow_down_outlined,
                size: (_textStyle?.fontSize ?? 0) * 1.3,
                color: _textStyle?.color,
              ),
            ),
          ],
          style: _textStyle,
        ),
      ),
      initial: initial,
      defaultValue: defaultValue,
      leftBtnLabel: leftBtnLabel,
      rightBtnLabel: rightBtnLabel,
      onChanged: onChanged,
    );
  }
}

extension DateRangePickerExt on BuildContext {
  Future<DateRange?> showDateRangePickerModal({
    DateRange? initial,
    DateRange? defaultValue,
    String? leftBtnLabel,
    String? rightBtnLabel,
  }) {
    return showModal(
      this,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(this).size.height * 0.85,
        ),
        child: _DateRangePickerModal(
          initial: initial,
          defaultValue: defaultValue,
          leftBtnLabel: leftBtnLabel,
          rightBtnLabel: rightBtnLabel,
        ),
      ),
      title: coreL10n.selectTimePeriod,
    );
  }
}
