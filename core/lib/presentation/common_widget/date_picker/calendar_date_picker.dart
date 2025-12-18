import 'package:flutter/material.dart';

import '../../../core.dart';

class DateInputCalendarPicker extends StatefulWidget {
  final void Function()? onTapInputField;
  final void Function(DateTime date) onDateSelected;
  final DateTime? initial;
  final String monthStr;
  final String title;
  final String? hint;
  final String? calendarIcon;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Color? iconColor;
  final bool required;

  const DateInputCalendarPicker({
    Key? key,
    this.onTapInputField,
    required this.onDateSelected,
    this.initial,
    required this.monthStr,
    required this.title,
    this.calendarIcon,
    this.hint,
    this.minDate,
    this.maxDate,
    this.iconColor,
    this.required = false,
  }) : super(key: key);

  @override
  State<DateInputCalendarPicker> createState() =>
      _DateInputCalendarPickerState();
}

class _DateInputCalendarPickerState extends State<DateInputCalendarPicker> {
  DateTime? select;
  final _expandableCtrl = ExpandableController();

  @override
  void initState() {
    select = widget.initial;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DateInputCalendarPicker oldWidget) {
    select = widget.initial;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    select = widget.initial;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _expandableCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return ExpandableWidget(
      onTapHeader: () {
        widget.onTapInputField?.call();
        Future.delayed(const Duration(milliseconds: 500), () {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 250),
          );
        });
      },
      header: _buildDateInputField(textTheme: textTheme),
      body: TableCalendarDatePicker(
        monthStr: widget.monthStr,
        value: select,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        onSelected: (date) {
          _expandableCtrl.toggle();
          if (mounted) {
            setState(() {
              select = date;
            });
          }
          widget.onDateSelected(date);
        },
      ),
      controller: _expandableCtrl,
    );
  }

  Widget _buildDateInputField({
    required AppTextTheme textTheme,
  }) {
    final idTheme = context.theme.inputDecorationTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputTitleWidget(
          title: widget.title,
          required: widget.required == true,
        ),
        const SizedBox(height: 8),
        HighlightBoxColor(
          borderColor: idTheme.border?.borderSide.color,
          borderWidth: idTheme.border?.borderSide.width,
          borderRadius:
              asOrNull<OutlineInputBorder>(idTheme.border)?.borderRadius,
          padding: context.theme.inputDecorationTheme.contentPadding ??
              const EdgeInsets.all(12),
          bgColor: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  select?.ddmmyyyy ?? widget.hint ?? '',
                  style: select != null
                      ? textTheme.textInput
                      : textTheme.inputHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 32,
                child: widget.calendarIcon.isNotNullOrEmpty
                    ? ImageView(
                        source: widget.calendarIcon!,
                        width: 24,
                        height: 24,
                        color: widget.iconColor ?? context.themeColor.primary,
                      )
                    : Icon(
                        Icons.calendar_month_outlined,
                        size: 22,
                        color: widget.iconColor ?? context.themeColor.primary,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WeekInputCalendarPicker extends StatefulWidget {
  final void Function()? onTapInputField;
  final void Function(DateTime date) onDateSelected;
  final DateRange? initial;
  final String monthStr;
  final String title;
  final String? hint;
  final String calendarIcon;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Color? iconColor;
  final bool required;

  const WeekInputCalendarPicker({
    Key? key,
    this.onTapInputField,
    required this.onDateSelected,
    this.initial,
    required this.monthStr,
    required this.title,
    required this.calendarIcon,
    this.hint,
    this.minDate,
    this.maxDate,
    this.iconColor,
    this.required = false,
  }) : super(key: key);

  @override
  State<WeekInputCalendarPicker> createState() =>
      _WeekInputCalendarPickerState();
}

class _WeekInputCalendarPickerState extends State<WeekInputCalendarPicker> {
  DateRange? select;

  final _expandableCtrl = ExpandableController();

  @override
  void initState() {
    select = widget.initial;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WeekInputCalendarPicker oldWidget) {
    select = widget.initial;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    select = widget.initial;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _expandableCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return ExpandableWidget(
      onTapHeader: () {
        widget.onTapInputField?.call();
      },
      header: _buildWeekInputField(textTheme: textTheme),
      body: TableCalendarDatePicker(
        monthStr: widget.monthStr,
        value: select?.from,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        rangeStart: select?.from,
        rangeEnd: select?.to,
        availableGestures: AvailableGestures.horizontalSwipe,
        onSelected: (date) {
          _expandableCtrl.toggle();
          if (mounted) {
            setState(() {
              select = DateRange(
                from: date.startThisWeek,
                to: date.endThisWeek,
              );
            });
          }
          widget.onDateSelected(date);
        },
      ),
      controller: _expandableCtrl,
    );
  }

  Widget _buildWeekInputField({
    required AppTextTheme textTheme,
  }) {
    final idTheme = context.theme.inputDecorationTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputTitleWidget(
          title: widget.title,
          required: widget.required == true,
        ),
        const SizedBox(height: 8),
        HighlightBoxColor(
          borderColor: idTheme.border?.borderSide.color,
          borderWidth: idTheme.border?.borderSide.width,
          borderRadius:
              asOrNull<OutlineInputBorder>(idTheme.border)?.borderRadius,
          padding: context.theme.inputDecorationTheme.contentPadding ??
              const EdgeInsets.all(12),
          bgColor: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  select != null
                      ? '''${select!.from!.ddmmyyyy} - ${select!.to!.ddmmyyyy}'''
                      : widget.hint ?? '',
                  style: select != null
                      ? textTheme.textInput
                      : textTheme.inputHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 32,
                child: ImageView(
                  source: widget.calendarIcon,
                  width: 24,
                  height: 24,
                  color: widget.iconColor ?? context.themeColor.schemeAction,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TableCalendarDatePicker extends StatelessWidget {
  const TableCalendarDatePicker({
    Key? key,
    required this.monthStr,
    required this.value,
    required this.onSelected,
    this.minDate,
    this.maxDate,
    this.rangeStart,
    this.rangeEnd,
    this.availableGestures = AvailableGestures.all,
  }) : super(key: key);

  final String monthStr;
  final DateTime? value;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final AvailableGestures availableGestures;

  final void Function(DateTime selected) onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final dateLocale = context.appDateLocale;
    return TableCalendar(
      startingDayOfWeek: StartingDayOfWeek.monday,
      rangeStartDay: rangeStart,
      availableGestures: availableGestures,
      rangeEndDay: rangeEnd,
      firstDay: DateTime.now().subtract(const Duration(days: 365 * 20)),
      lastDay: DateTime.now().add(const Duration(days: 365 * 100)),
      focusedDay: value ?? DateTime.now(),
      currentDay: value ?? DateTime.now(),
      availableCalendarFormats: {
        CalendarFormat.month: monthStr,
      },
      locale: Localizations.localeOf(context).languageCode,
      onDaySelected: (selectedDay, _) {
        onSelected.call(selectedDay);
      },
      enabledDayPredicate: (day) {
        var check1 = true;
        var check2 = true;
        if (minDate != null) {
          check1 = day.isAfter(minDate!) || day.isSameDay(minDate!);
        }

        if (maxDate != null) {
          check2 = day.isBefore(maxDate!) || day.isSameDay(maxDate!);
        }
        return check1 && check2;
      },
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonDecoration: BoxDecoration(
          color: Colors.brown,
          borderRadius: BorderRadius.circular(22.0),
        ),
        formatButtonTextStyle: const TextStyle(color: Colors.white),
        formatButtonShowsNext: false,
        titleTextFormatter: (date, locale) => date.customFormat(
          ['$monthStr ', 'mm', ', ', 'yyyy'],
          locale: context.appDateLocale,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          return Center(
            child: Text(
              dateLocale.daysShort[day.weekday - 1],
              style: textTheme.titleSmall,
            ),
          );
        },
      ),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: context.themeColor.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: context.themeColor.primary,
          shape: BoxShape.circle,
        ),
        rangeHighlightColor: context.themeColor.secondary,
        rangeStartDecoration: BoxDecoration(
          color: context.themeColor.primary,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
          color: context.themeColor.primary,
          shape: BoxShape.circle,
        ),
      ),
      calendarFormat: CalendarFormat.month,
    );
  }
}

Future<DateTime?> showCalendarDatePicker({
  required BuildContext context,
  required DateTime? initialDate,
  DateTime? minDate,
  DateTime? maxDate,
  AvailableGestures availableGestures = AvailableGestures.horizontalSwipe,
  String? title,
  String? monthStr,
  String? leftBtnText,
  String? rightBtnText,
}) async {
  return showModal<DateTime?>(
    context,
    builder: (context) => _CalendarDatePickerBottomSheet(
      initialDate: initialDate,
      minDate: minDate,
      maxDate: maxDate,
      availableGestures: availableGestures,
      title: title,
      monthStr: monthStr,
      leftBtnText: leftBtnText,
      rightBtnText: rightBtnText,
    ),
    title: title,
  );
}

class _CalendarDatePickerBottomSheet extends StatefulWidget {
  const _CalendarDatePickerBottomSheet({
    this.initialDate,
    required this.availableGestures,
    this.minDate,
    this.maxDate,
    this.title,
    this.monthStr,
    this.leftBtnText,
    this.rightBtnText,
  });

  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final AvailableGestures availableGestures;
  final String? title;
  final String? monthStr;
  final String? leftBtnText;
  final String? rightBtnText;

  @override
  State<_CalendarDatePickerBottomSheet> createState() =>
      _CalendarDatePickerBottomSheetState();
}

class _CalendarDatePickerBottomSheetState
    extends State<_CalendarDatePickerBottomSheet> {
  late DateTime? dateTime = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TableCalendarDatePicker(
            monthStr: widget.monthStr ?? '',
            value: dateTime,
            minDate: widget.minDate,
            maxDate: widget.maxDate,
            availableGestures: widget.availableGestures,
            onSelected: (date) {
              setState(() {
                dateTime = date;
              });
            },
          ),
        ),
        FooterWidget(
          child: Row(
            children: [
              Expanded(
                child: ThemeButton.outline(
                  title: widget.leftBtnText ?? 'Cancel',
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ThemeButton.primary(
                  title: widget.rightBtnText ?? 'Apply',
                  onPressed: () {
                    Navigator.pop(context, dateTime);
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
