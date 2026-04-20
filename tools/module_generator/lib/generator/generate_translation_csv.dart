import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

/// Generate translation CSV file with status column
/// Compares with old file to identify changes and adds status column:
/// - NEW: New keys
/// - UPDATED: Changed values
/// - UNCHANGED: No changes
Future<void> generateTranslationCSV({
  required String csvPath,
  required String oldFilePath,
  required String outputPath,
}) async {
  print('📝 Translation CSV Generator');
  print('================================\n');

  // Read CSV data
  print('Reading CSV file: $csvPath');
  final csvData = await _readCsvData(csvPath);
  if (csvData == null) {
    print('❌ Error: Failed to read CSV file');
    return;
  }

  // Read old data
  print('Reading old file: $oldFilePath');
  final oldData = await _readOldData(oldFilePath);

  // Generate new CSV with status column
  print('Generating new CSV file...\n');
  final stats = await _createCSVWithStatus(
    csvData: csvData,
    oldData: oldData,
    outputPath: outputPath,
  );

  print('\n✅ CSV file created: $outputPath');
  print('\nStatistics:');
  print('  🆕 New keys: ${stats['new']}');
  print('  🔄 Updated keys: ${stats['updated']}');
  print('  ✓ Unchanged keys: ${stats['unchanged']}');
  print('  📊 Total keys: ${stats['total']}');
  print('\nℹ️  You can filter by "status" column in Excel or Google Sheets');
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

    for (final row in fields.skip(1)) {
      if (row.isEmpty || row.first.toString().trim().isEmpty) continue;

      final key = row.first.toString().trim();
      final rowData = <String, String>{};

      for (var i = 1; i < headers.length && i < row.length; i++) {
        rowData[headers[i]] = row[i]?.toString().trim() ?? '';
      }

      data[key] = rowData;
    }

    return {'headers': headers, 'data': data};
  } catch (e) {
    print('❌ Error reading CSV: $e');
    return null;
  }
}

/// Read old data from CSV file
Future<Map<String, Map<String, String>>> _readOldData(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      print('⚠️  Old file not found (all keys will be marked as NEW)');
      return {};
    }

    // Read CSV
    final csvData = await _readCsvData(filePath);
    if (csvData == null) {
      return {};
    }

    final data = csvData['data'] as Map<String, Map<String, String>>?;

    // If old file has status column, remove it from comparison
    if (data != null) {
      for (final entry in data.entries) {
        entry.value.remove('status');
      }
    }

    return data ?? {};
  } catch (e) {
    print('⚠️  Error reading old file: $e');
    return {};
  }
}

/// Create CSV file with status column
Future<Map<String, int>> _createCSVWithStatus({
  required Map<String, dynamic> csvData,
  required Map<String, Map<String, String>> oldData,
  required String outputPath,
}) async {
  final headers = csvData['headers'] as List<String>;
  final data = csvData['data'] as Map<String, Map<String, String>>;

  final stats = {'new': 0, 'updated': 0, 'unchanged': 0, 'total': data.length};

  // Create output data with status column
  final outputRows = <List<String>>[];

  // Add headers with status column at the end
  final outputHeaders = [...headers, 'status'];
  outputRows.add(outputHeaders);

  // Process each row
  for (final entry in data.entries) {
    final key = entry.key;
    final values = entry.value;

    // Determine status
    String status;
    if (!oldData.containsKey(key)) {
      status = 'NEW';
      stats['new'] = (stats['new'] ?? 0) + 1;
    } else {
      var changed = false;
      for (final lang in values.keys) {
        final oldValue = oldData[key]?[lang] ?? '';
        final newValue = values[lang] ?? '';
        if (newValue != oldValue) {
          changed = true;
          break;
        }
      }

      if (changed) {
        status = 'UPDATED';
        stats['updated'] = (stats['updated'] ?? 0) + 1;
      } else {
        status = ''; // Empty for unchanged
        stats['unchanged'] = (stats['unchanged'] ?? 0) + 1;
      }
    }

    // Build row: [key, lang1, lang2, ..., status]
    final row = <String>[key];
    for (var i = 1; i < headers.length; i++) {
      row.add(values[headers[i]] ?? '');
    }
    row.add(status);
    outputRows.add(row);
  }

  // Write to CSV file
  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);

  final csv = ListToCsvConverter(
    eol: Platform.isMacOS ? '\n' : defaultEol,
  ).convert(outputRows);

  await outputFile.writeAsString(csv, encoding: utf8);

  return stats;
}
