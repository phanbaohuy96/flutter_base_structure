import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../l10n/localization_ext.dart';
import '../extentions/extention.dart';
import 'export.dart';

class GenderSelection extends StatefulWidget {
  final String? defaultGender;
  final void Function(String)? onChange;
  final bool required;
  final String title;
  final TextStyle? titleStyle;

  const GenderSelection({
    Key? key,
    required this.title,
    this.titleStyle,
    this.onChange,
    this.defaultGender,
    this.required = false,
  }) : super(key: key);

  @override
  State<GenderSelection> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<GenderSelection> {
  String? _gender;
  late ThemeData _themeData;

  @override
  void didChangeDependencies() {
    _gender = widget.defaultGender;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant GenderSelection oldWidget) {
    if (widget.defaultGender != oldWidget.defaultGender) {
      _gender = widget.defaultGender;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    _themeData = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputTitleWidget(
          title: widget.title,
          required: widget.required,
          style: widget.titleStyle,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            {
              'lable': coreL10n.male,
              'value': ServerGender.male,
              'icon': Icons.male,
            },
            {
              'lable': coreL10n.female,
              'value': ServerGender.female,
              'icon': Icons.female,
            },
          ].map<Widget>(
            (e) {
              final color = e['value'] as String == _gender
                  ? context.theme.colorScheme.primary
                  : context.theme.disabledColor;
              return Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _gender = e['value'] as String;
                        widget.onChange?.call(_gender!);
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: color,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.only(right: 5),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: e['value'] as String,
                          groupValue: _gender,
                          onChanged: (gender) {
                            if (mounted) {
                              setState(() {
                                _gender = e['value'] as String;
                                widget.onChange?.call(_gender!);
                              });
                            }
                          },
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          fillColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              return Theme.of(context).colorScheme.primary;
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e['lable'] as String,
                            style: _themeData.textTheme.bodyLarge?.copyWith(
                              color: color,
                            ),
                          ),
                        ),
                        Icon(
                          e['icon'] as IconData,
                          size: 24,
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ).insertSeparator(
            (index) => const SizedBox(width: 15),
          ),
        ),
      ],
    );
  }
}

enum Gender { male, female }
