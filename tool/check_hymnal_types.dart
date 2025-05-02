import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:isar/isar.dart';
import 'package:adventist_hymnarium/models/hymn.dart';
import 'package:adventist_hymnarium/models/responsive_reading.dart';
import 'package:adventist_hymnarium/models/thematic_list.dart';
import 'package:adventist_hymnarium/models/thematic_ambit.dart';

/// Checks and prints the distinct hymnalType values present in the Isar database.
/// Run this script from the project root directory using:
/// `dart run tool/check_hymnal_types.dart`
Future<void> main() async {
  // --- Configuration ---
  final projectRoot = Directory.current.path;
  final isarDbPath = p.join(projectRoot, 'assets');
  const isarDbName = 'hymnarium';

  // --- Initialization ---
  await Isar.initializeIsarCore(download: true);

  print('Opening Isar DB in directory: $isarDbPath');
  final isar = await Isar.open(
    [
      HymnSchema,
      ResponsiveReadingSchema, // Include all schemas used by the DB
      ThematicListSchema,
      ThematicAmbitSchema,
    ],
    directory: isarDbPath,
    name: isarDbName,
    inspector: false,
  );
  print('Isar DB opened successfully.');

  // --- Check Distinct Values ---
  try {
    print('Querying distinct hymnal types...');
    // Efficiently get distinct values using Isar query features
    final distinctTypes = await isar.hymns
        .where()
        .distinctByHymnalType()
        .hymnalTypeProperty()
        .findAll();
    
    // Alternative (less efficient): Get all hymns and extract unique types
    // final allHymns = await isar.hymns.where().findAll();
    // final distinctTypes = allHymns.map((h) => h.hymnalType).toSet();

    if (distinctTypes.isEmpty) {
      print('No hymns found or hymnalType field is empty.');
    } else {
      print("Distinct hymnal types found: ${distinctTypes.join(', ')}");
    }

  } catch (e, s) {
    print('\nError during query: $e');
    print(s);
  } finally {
    // --- Cleanup ---
    print('Closing Isar DB...');
    await isar.close();
    print('Isar DB closed.');
  }
} 