import 'dart:io';

import '../common/console.dart';
import '../common/generator_options.dart';
import '../common/input_helper.dart';
import '../common/package_scanner.dart';

/// Moves the working directory to the package the operator wants to generate
/// into, and reports which one that is.
///
/// The generator writes every file relative to `Directory.current`, so
/// choosing a package is the same thing as choosing a working directory. It
/// used to be chosen before the process started — `make run_module_generator`
/// asked for a path and passed it to a shell script — which meant typing a
/// path from memory and finding out it was the wrong one only after answering
/// four more prompts.
///
/// Returns the package generation will run in, or `null` when the operator
/// backed out.
Future<WorkspacePackage?> selectTargetPackage(GeneratorOptions options) async {
  final root = findWorkspaceRoot();
  if (root == null) {
    // Not in this template's workspace: generate where we stand rather than
    // refuse, so the tool still works in a single-package checkout.
    return currentPackage();
  }

  final packages = scanPackages(root);
  if (packages.isEmpty) {
    return currentPackage();
  }

  final requested = options.package;
  if (requested != null) {
    final match = resolvePackage(packages, requested);
    if (match == null) {
      throw GeneratorInputException(
        'No package "$requested" in this workspace. Available: '
        '${packages.map((package) => package.relativePath).join(', ')}.',
      );
    }
    Directory.current = match.path;
    return match;
  }

  final current = currentPackage();
  if (options.nonInteractive) {
    return current;
  }

  final selection = await _prompt(packages, current);
  if (selection == null) {
    return null;
  }
  Directory.current = selection.path;
  return selection;
}

/// Finds [query] among [packages] by relative path or by package name.
WorkspacePackage? resolvePackage(
  List<WorkspacePackage> packages,
  String query,
) {
  final needle = query.replaceAll('\\', '/').trim();
  final trimmed = needle.endsWith('/')
      ? needle.substring(0, needle.length - 1)
      : needle;
  for (final package in packages) {
    if (package.relativePath == trimmed || package.name == trimmed) {
      return package;
    }
  }
  return null;
}

Future<WorkspacePackage?> _prompt(
  List<WorkspacePackage> packages,
  WorkspacePackage? current,
) async {
  final currentIndex = current == null
      ? -1
      : packages.indexWhere((package) => package.path == current.path);
  final defaultValue = currentIndex >= 0 ? currentIndex + 1 : 1;

  stdout.writeln();
  stdout.writeln(
    Console.menu(
      title: 'Target package',
      subtitle: 'Where the generated files are written',
      sections: [
        MenuSection(
          title: 'packages',
          entries: [
            for (final (index, package) in packages.indexed)
              MenuEntry(
                value: index + 1,
                label: package.relativePath,
                // The retrofit note is the one capability that changes what
                // the generator will let you do: a repository cannot be
                // emitted into a package that lacks it.
                description: index == currentIndex
                    ? '${package.capabilities} (current)'
                    : package.capabilities,
              ),
          ],
        ),
        const MenuSection(
          title: 'other',
          entries: [
            MenuEntry(
              value: 0,
              label: 'exit',
              description: 'Leave without writing',
            ),
          ],
        ),
      ],
    ),
  );

  final selection = await InputHelper.enterChoice(
    'Select package [0-${packages.length}] '
    '${Console.dim('(default: $defaultValue)')}: ',
    allowed: {for (var i = 0; i <= packages.length; i++) i},
    defaultValue: defaultValue,
  );
  return selection == 0 ? null : packages[selection - 1];
}
