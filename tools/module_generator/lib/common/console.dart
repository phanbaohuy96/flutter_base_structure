import 'dart:io';

/// One selectable row in a [Console.menu].
class MenuEntry {
  const MenuEntry({
    required this.value,
    required this.label,
    required this.description,
  });

  /// The number the operator types to pick this row.
  final int value;

  /// Short name of what gets generated.
  final String label;

  /// One line saying what the row is for, so the menu answers "which one?"
  /// without a trip to the README.
  final String description;
}

/// A titled group of [MenuEntry] rows.
class MenuSection {
  const MenuSection({required this.title, required this.entries});

  final String title;
  final List<MenuEntry> entries;
}

/// Terminal styling for the generator's interactive surface.
///
/// Every helper degrades to plain text when stdout is not an ANSI terminal, so
/// piped output, CI logs and `make` captures stay greppable instead of filling
/// with escape codes.
abstract final class Console {
  /// Overrides terminal detection.
  ///
  /// Tests set this so rendered output is identical wherever they run; leaving
  /// it `null` restores auto-detection.
  static bool? forceStyle;

  static const int _width = 68;

  static bool get _styled =>
      forceStyle ?? (stdout.hasTerminal && stdout.supportsAnsiEscapes);

  static String _sgr(String code, String text) =>
      _styled ? '\x1B[${code}m$text\x1B[0m' : text;

  static String bold(String text) => _sgr('1', text);

  static String dim(String text) => _sgr('2', text);

  static String cyan(String text) => _sgr('36', text);

  static String green(String text) => _sgr('32', text);

  static String yellow(String text) => _sgr('33', text);

  static String red(String text) => _sgr('31', text);

  /// Renders a boxed title bar.
  static String banner(String title, {String? subtitle}) {
    final buffer = StringBuffer()
      ..writeln(dim('┌${'─' * _width}┐'))
      ..writeln(
        '${dim('│')} ${bold(cyan(_pad(title, _width - 2)))} '
        '${dim('│')}',
      );
    if (subtitle != null) {
      buffer.writeln(
        '${dim('│')} ${dim(_pad(subtitle, _width - 2))} ${dim('│')}',
      );
    }
    buffer.write(dim('└${'─' * _width}┘'));
    return buffer.toString();
  }

  /// Renders a grouped, numbered menu.
  ///
  /// Numbers are right-aligned and labels share one column across every
  /// section, so the descriptions line up no matter how the sections are
  /// split.
  static String menu({
    required String title,
    required List<MenuSection> sections,
    String? subtitle,
  }) {
    final entries = sections.expand((section) => section.entries);
    final labelWidth = entries
        .map((entry) => entry.label.length)
        .fold(0, (widest, length) => length > widest ? length : widest);

    final buffer = StringBuffer()
      ..writeln(banner(title, subtitle: subtitle))
      ..writeln();

    for (final section in sections) {
      buffer.writeln('  ${dim(section.title.toUpperCase())}');
      for (final entry in section.entries) {
        buffer.writeln(
          '    ${bold(green(entry.value.toString().padLeft(2)))}  '
          '${_pad(entry.label, labelWidth)}  '
          '${dim(entry.description)}',
        );
      }
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  /// A step heading, printed as the generator moves through a run.
  static String step(String message) => '${cyan('==>')} ${bold(message)}';

  static String success(String message) => '${green('✔')} $message';

  static String warning(String message) => '${yellow('!')} $message';

  static String failure(String message) => '${red('✖')} $message';

  /// Pads [text] to [width], measured on the unstyled string.
  ///
  /// Styling has to be applied *after* padding: an ANSI escape sequence is
  /// several characters wide to `padRight` and zero columns wide on screen, so
  /// padding a coloured string misaligns every row.
  static String _pad(String text, int width) => text.padRight(width);
}
