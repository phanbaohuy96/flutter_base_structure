import 'dart:math';

import 'package:flutter/material.dart';

/// Usage
///
/// =========> INIT Controller
/// final _textTaggingController = TextTaggingController<User>(
///   tagBuilder: (context, style, withComposing, user) {
///     return Container(
///       decoration: BoxDecoration(
///         color: Colors.grey.withAlpha((0.2 * 255).round()),
///         borderRadius: BorderRadius.circular(4),
///       ),
///       padding: const EdgeInsets.symmetric(horizontal: 4),
///       child: Text(
///         user.name,
///         style: style,
///       ),
///     );
///   },
///   tagToText: (e) => e.name,
/// );
///
/// =========> LISTEN TEXT CHANGED
/// _textTaggingController.addListener(() {
///   final text = _textTaggingController.edittingText;
///   ...
/// });
///
/// _textTaggingController.add(...)
/// _textTaggingController.removeAt(...)

class TextTaggingController<T> extends TextEditingController {
  List<T> _tags = [];

  final Widget Function(
    BuildContext context,
    TextStyle? style,
    bool withComposing,
    T tag,
    int index,
    int total,
  ) tagBuilder;

  final String Function(T) tagToText;
  final void Function(List<T>)? onTagsChanged;

  TextTaggingController({
    List<T>? initial,
    String? text,
    required this.tagBuilder,
    required this.tagToText,
    this.onTagsChanged,
  }) {
    _tags.addAll(initial ?? []);
    this.text = text ?? '';
  }

  String get placeholderChar => '@';

  List<T> get tags => _tags;

  String get edittingText => value.text.substring(
        _tags.length,
        value.text.length,
      );

  String get placeholderStr =>
      List.generate(_tags.length, (i) => placeholderChar).join();

  void add(T data) {
    _tags.add(data);
    final length = _tags.length;
    final newText = List.generate(length, (i) => placeholderChar).join();
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
    notifyTagChanged();
  }

  void setTags(List<T> data) {
    final old = _tags.map(tagToText).join('--');
    final neww = data.map(tagToText).join('--');
    _tags
      ..clear()
      ..addAll(data);
    final length = _tags.length;
    final newText = List.generate(length, (i) => placeholderChar).join();
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
    if (old != neww) {
      notifyTagChanged();
    }
  }

  void removeAt(int index) {
    _tags.removeAt(index);
    final newText = '${text.substring(0, index)}${text.substring(index + 1)}';
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
    notifyTagChanged();
  }

  @override
  set text(String newText) {
    final _newText = '$placeholderStr$newText';
    value = value.copyWith(
      text: _newText,
      selection: TextSelection.collapsed(offset: _newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  void clear() {
    _tags.clear();
    value = value.copyWith(
      text: '',
      selection: const TextSelection.collapsed(offset: 0),
      composing: TextRange.empty,
    );
    notifyTagChanged();
  }

  @override
  set value(TextEditingValue newValue) {
    final tagCount = _tags.length;
    final placeHolder = List.generate(tagCount, (i) => placeholderChar).join();
    final oldText = value.text;
    final newText = newValue.text;

    if (_tags.isNotEmpty && newValue.text != placeHolder) {
      if (newValue.text != oldText) {
        final cursorPos = selection.start;
        final cursorPosEnd = selection.end;
        final newCursorPos = newValue.selection.end;
        final addedStr = cursorPos < newCursorPos
            ? newText.substring(cursorPos, newCursorPos)
            : '';

        if (cursorPos <= tagCount) {
          if (cursorPos < newCursorPos && cursorPos == tagCount) {
            // Case replace/add text from last tag postion
            super.value = newValue;
            return;
          }
          String _newText;
          if (cursorPos < cursorPosEnd) {
            /// Editing With Multiple Selection
            if (cursorPosEnd < tagCount) {
              /// Remove tag
              _tags.removeRange(cursorPos, cursorPosEnd);
              _newText = oldText.replaceRange(cursorPos, cursorPosEnd, '');
            } else {
              /// Replace tags from current selection to end with adding text
              _tags.removeRange(cursorPos, min(cursorPosEnd, tagCount));
              _newText =
                  oldText.replaceRange(cursorPos, cursorPosEnd, addedStr);
            }
            notifyTagChanged();
          } else {
            /// Editing With Single Selection
            if (addedStr.isEmpty) {
              /// Case backspace
              if (cursorPos == tagCount) {
                // At last tag postion without multiple selection
                _tags.removeLast();
                _newText = '$placeholderStr${newText.substring(_tags.length)}';
              } else {
                // Bettwen two tags
                _tags.removeAt(cursorPos - 1);
                _newText =
                    '''${oldText.substring(0, cursorPos)}${oldText.substring(cursorPos + 1)}''';
              }
              notifyTagChanged();
            } else {
              // CTE => current to end
              final tagsCTE = tags.sublist(cursorPos);
              final tagsCTEStr = tagsCTE.map(tagToText).join(' ');
              final endText = edittingText;
              _tags = _tags.sublist(0, cursorPos);
              _newText = '$placeholderStr$addedStr$tagsCTEStr$endText';
              notifyTagChanged();
            }
          }
          super.value = value.copyWith(
            text: _newText,
            selection: TextSelection.collapsed(
              offset: min(newCursorPos, _newText.length),
            ),
            composing: TextRange.empty,
          );
          return;
        }
      }
    }
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans = <InlineSpan>[];
    final lenght = tags.length;
    for (var i = 0; i < lenght; i++) {
      spans.add(
        WidgetSpan(
          child: tagBuilder(
            context,
            style,
            withComposing,
            tags[i],
            i,
            lenght,
          ),
          alignment: PlaceholderAlignment.middle,
          style: style?.copyWith(
            height: 2,
          ),
          baseline: TextBaseline.alphabetic,
        ),
      );
    }
    spans.add(
      TextSpan(
        text: value.text.substring(spans.length),
        style: style,
      ),
    );

    return TextSpan(children: spans);
  }

  void notifyTagChanged() {
    onTagsChanged?.call([...tags]);
  }
}
