import 'package:flutter/material.dart';

import 'box_color.dart';

class StoryWidgetBox<T> extends StatefulWidget {
  const StoryWidgetBox({
    required this.builder,
    this.title = '',
    this.description = '',
    this.initial,
  });

  final String title;
  final String description;
  final Widget Function(
    BuildContext context,
    void Function(T? value) updateBuildValue,
    T? value,
  ) builder;
  final T? initial;

  @override
  State<StoryWidgetBox<T>> createState() => _StoryWidgetBoxState<T>();
}

class _StoryWidgetBoxState<T> extends State<StoryWidgetBox<T>> {
  T? value;

  @override
  void initState() {
    value = widget.initial;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StoryWidgetBox<T> oldWidget) {
    if (widget.initial != oldWidget.initial) {
      value = widget.initial;
    }
    super.didUpdateWidget(oldWidget);
  }

  void updateBuildValue(T? value) {
    if (mounted) {
      setState(() {
        this.value = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HighlightBoxColor(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.title.isNotEmpty)
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          if (widget.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.description,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
          const Divider(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.builder(context, updateBuildValue, value),
          ),
        ],
      ),
    );
  }
}
