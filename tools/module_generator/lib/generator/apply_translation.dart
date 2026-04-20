import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

/// Apply translated CSV back to current localization file
/// Merges translations from completed translation file while preserving
/// new keys added during development
Future<void> applyTranslation({
  required String translatedPath,
  required String currentPath,
  required String outputPath,
  bool createBackup = true,
}) async {
  print('📝 Apply Translation to Localization File');
  print('==========================================\n');

  // Read translated CSV (source with completed translations)
  print('Reading translated file: $translatedPath');
  final translatedData = await _readCsvData(translatedPath);
  if (translatedData == null) {
    print('❌ Error: Failed to read translated CSV file');
    return;
  }

  // Read current CSV (target with potentially new keys)
  print('Reading current file: $currentPath');
  final currentData = await _readCsvData(currentPath);
  if (currentData == null) {
    print('❌ Error: Failed to read current CSV file');
    return;
  }

  // Validate headers match
  final translatedHeaders = translatedData['headers'] as List<String>;
  final currentHeaders = currentData['headers'] as List<String>;

  if (!_headersMatch(translatedHeaders, currentHeaders)) {
    print('⚠️  Warning: Column headers do not match!');
    print('   Translated: ${translatedHeaders.join(", ")}');
    print('   Current: ${currentHeaders.join(", ")}');
    print('   Will use current file headers.\n');
  }

  // Create backup if requested
  if (createBackup) {
    await _createBackup(currentPath);
  }

  // Merge translations
  print('Merging translations...\n');
  final stats = await _mergeAndWrite(
    translatedData: translatedData,
    currentData: currentData,
    outputPath: outputPath,
  );

  print('\n✅ Translation applied successfully!');
  print('\nStatistics:');
  print('  🔄 Updated translations: ${stats['updated']}');
  print('  🆕 New keys preserved: ${stats['new']}');
  print('  📊 Total keys: ${stats['total']}');

  if (stats['removed']! > 0) {
    print(
      '  ⚠️  Keys not in translated file: ${stats['removed']} (kept current values)',
    );
  }
}

/// CSV data structure: {headers: [...], data: {key: {lang: value, ...}}}
Future<Map<String, dynamic>?> _readCsvData(String csvPath) async {
  try {
    final file = File(csvPath);
    if (!await file.exists()) {
      print('❌ CSV file not found: $csvPath');
      return null;
    }

    final input = file.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(
          CsvToListConverter(eol: Platform.isMacOS ? '\n' : defaultEol),
        )
        .toList();

    if (fields.isEmpty) {
      print('❌ CSV file is empty');
      return null;
    }

    final headers = fields.first.map((e) => e.toString().trim()).toList();
    final data = <String, Map<String, String>>{};

    // Track keys for preserving order
    final keyOrder = <String>[];

    for (final row in fields.skip(1)) {
      if (row.isEmpty || row.first.toString().trim().isEmpty) continue;

      final key = row.first.toString().trim();
      final rowData = <String, String>{};

      for (var i = 1; i < headers.length && i < row.length; i++) {
        // Skip 'status' column if exists in translated file
        if (headers[i].toLowerCase() == 'status') continue;
        rowData[headers[i]] = row[i]?.toString().trim() ?? '';
      }

      data[key] = rowData;
      keyOrder.add(key);
    }

    return {
      'headers': headers.where((h) => h.toLowerCase() != 'status').toList(),
      'data': data,
      'keyOrder': keyOrder,
    };
  } catch (e) {
    print('❌ Error reading CSV: $e');
    return null;
  }
}

/// Check if headers match (ignoring status column)
bool _headersMatch(List<String> headers1, List<String> headers2) {
  final h1 = headers1.where((h) => h.toLowerCase() != 'status').toList();
  final h2 = headers2.where((h) => h.toLowerCase() != 'status').toList();

  if (h1.length != h2.length) return false;

  for (var i = 0; i < h1.length; i++) {
    if (h1[i] != h2[i]) return false;
  }

  return true;
}

/// Create timestamped backup of current file
Future<void> _createBackup(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return;

    final timestamp = DateTime.now().toIso8601String();
    final backupPath = '$filePath.backup.$timestamp.csv';

    await file.copy(backupPath);
    print('💾 Backup created: $backupPath\n');
  } catch (e) {
    print('⚠️  Warning: Failed to create backup: $e\n');
  }
}

/// Merge translated data with current data and write to output
Future<Map<String, int>> _mergeAndWrite({
  required Map<String, dynamic> translatedData,
  required Map<String, dynamic> currentData,
  required String outputPath,
}) async {
  final headers = currentData['headers'] as List<String>;
  final translatedMap =
      translatedData['data'] as Map<String, Map<String, String>>;
  final currentMap = currentData['data'] as Map<String, Map<String, String>>;
  final currentKeyOrder = currentData['keyOrder'] as List<String>;

  final stats = {'updated': 0, 'new': 0, 'removed': 0, 'total': 0};

  // Create output data preserving current file's key order
  final outputRows = <List<String>>[];
  outputRows.add(headers);

  // Process keys in current file's order
  for (final key in currentKeyOrder) {
    final currentValues = currentMap[key]!;
    Map<String, String> finalValues;

    if (translatedMap.containsKey(key)) {
      // Key exists in translated file - use translated values
      finalValues = translatedMap[key]!;

      // Check if actually updated
      var hasChanges = false;
      for (final lang in currentValues.keys) {
        if (currentValues[lang] != (finalValues[lang] ?? '')) {
          hasChanges = true;
          break;
        }
      }

      if (hasChanges) {
        stats['updated'] = (stats['updated'] ?? 0) + 1;
      }
    } else {
      // Key only in current file - preserve it (new key added during translation)
      finalValues = currentValues;
      stats['new'] = (stats['new'] ?? 0) + 1;
    }

    // Build row: [key, lang1, lang2, ...]
    final row = <String>[key];
    for (var i = 1; i < headers.length; i++) {
      row.add(finalValues[headers[i]] ?? '');
    }
    outputRows.add(row);
    stats['total'] = (stats['total'] ?? 0) + 1;
  }

  // Count keys that were in translated but not in current (removed during dev)
  stats['removed'] =
      translatedMap.length -
      (stats['updated']! +
          (stats['total']! - stats['new']! - stats['updated']!));
  if (stats['removed']! < 0) stats['removed'] = 0;

  // Write to output file
  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);

  final csv = ListToCsvConverter(
    eol: Platform.isMacOS ? '\n' : defaultEol,
  ).convert(outputRows);

  await outputFile.writeAsString(csv, encoding: utf8);

  return stats;
}
