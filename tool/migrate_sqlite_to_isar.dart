import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:isar/isar.dart';
import 'package:adventist_hymnarium/models/hymn.dart';
import 'package:adventist_hymnarium/models/responsive_reading.dart';
import 'package:adventist_hymnarium/models/thematic_list.dart';
import 'package:adventist_hymnarium/models/thematic_ambit.dart';

/// Migrates data from the SQLite database (hymnarium.db) to an Isar database (hymnarium.isar).
/// Run this script from the project root directory using:
/// `dart run tool/migrate_sqlite_to_isar.dart`
Future<void> main() async {
  // --- Configuration ---
  final projectRoot = Directory.current.path;
  final sqliteDbPath = p.join(projectRoot, 'assets', 'hymnarium.db');
  final isarDbPath = p.join(projectRoot, 'assets'); // Isar DB will be created here
  const isarDbName = 'hymnarium'; // Default Isar instance name

  // --- Initialization ---
  // Required for sqflite on non-mobile platforms
  sqfliteFfiInit();
  final databaseFactory = databaseFactoryFfi;

  // Required for Isar in standalone Dart scripts
  await Isar.initializeIsarCore(download: true);

  print('Opening SQLite DB: $sqliteDbPath');
  final sqfliteDb = await databaseFactory.openDatabase(sqliteDbPath);
  print('SQLite DB opened successfully.');

  print('Opening Isar DB in directory: $isarDbPath');
  final isar = await Isar.open(
    [
      HymnSchema,
      ResponsiveReadingSchema,
      ThematicListSchema,
      ThematicAmbitSchema,
    ],
    directory: isarDbPath,
    name: isarDbName,
    inspector: false, // No need for inspector in script
  );
  print('Isar DB opened successfully.');

  // --- Migration --- 
  try {
    await isar.writeTxn(() async {
      print('Clearing existing Isar data...');
      await isar.clear();
      print('Existing Isar data cleared.');

      // 1. Migrate Hymns
      print('Migrating hymns...');
      final hymnsData = await sqfliteDb.query('hymns');
      final isarHymns = hymnsData.map((row) {
        return Hymn()
          ..number = row['number'] as int
          ..title = row['title'] as String
          ..content = row['content'] as String
          ..hymnalType = row['hymnal_type'] as String;
      }).toList();
      await isar.hymns.putAll(isarHymns);
      print('Migrated ${isarHymns.length} hymns.');

      // 2. Migrate Responsive Readings
      print('Migrating responsive readings...');
      final readingsData = await sqfliteDb.query('responsive_readings');
      final isarReadings = readingsData.map((row) {
        return ResponsiveReading()
          ..number = row['number'] as int
          ..title = row['title'] as String
          ..content = row['content'] as String;
      }).toList();
      await isar.responsiveReadings.putAll(isarReadings);
      print('Migrated ${isarReadings.length} responsive readings.');

      // 3. Migrate Thematic Lists (and store mapping)
      print('Migrating thematic lists...');
      final thematicListsData = await sqfliteDb.query('thematic_lists');
      final Map<int, ThematicList> sqliteIdToIsarList = {};
      final List<ThematicList> isarLists = [];

      for (final row in thematicListsData) {
        final sqliteId = row['id'] as int;
        final isarList = ThematicList()
          ..thematic = row['thematic'] as String
          ..hymnalType = row['hymnal_type'] as String;
        isarLists.add(isarList);
        // Store mapping *before* putting, as ID is generated on put
        sqliteIdToIsarList[sqliteId] = isarList; 
      }
      // Put all lists first to get their Isar IDs assigned
      await isar.thematicLists.putAll(isarLists);
      print('Migrated ${isarLists.length} thematic lists.');
      
      // Update map with actual Isar IDs (optional but good practice)
      // Note: This relies on the order being preserved, which putAll should do.
      for(int i = 0; i < isarLists.length; i++) {
         final sqliteId = thematicListsData[i]['id'] as int;
         sqliteIdToIsarList[sqliteId] = isarLists[i]; // Now has the correct Isar ID
      }

      // 4. Migrate Thematic Ambits (and link them)
      print('Migrating thematic ambits and linking...');
      final thematicAmbitsData = await sqfliteDb.query('thematic_ambits');
      final List<ThematicAmbit> isarAmbits = [];
      final List<ThematicList> listsToSave = []; // Keep track of lists whose links changed

      for (final row in thematicAmbitsData) {
        final sqliteListId = row['thematic_list_id'] as int?;
        final parentList = sqliteIdToIsarList[sqliteListId];

        if (parentList == null && sqliteListId != null) {
            print('Warning: Could not find parent ThematicList for ambit with SQLite thematic_list_id: $sqliteListId');
            continue;
        }

        final isarAmbit = ThematicAmbit()
          ..ambit = row['ambit'] as String
          ..startNumber = row['start_number'] as int
          ..endNumber = row['end_number'] as int;
        
        // Set the link to the parent list
        isarAmbit.thematicList.value = parentList;
        isarAmbits.add(isarAmbit);

        // Add parent list to save its links if not already added
        if (parentList != null && !listsToSave.contains(parentList)) {
           listsToSave.add(parentList);
        }
      }
      // Put all ambits first
      await isar.thematicAmbits.putAll(isarAmbits);
      // Important: Save the parent lists to persist the backlinks
      await isar.thematicLists.putAll(listsToSave);
      // Save the links for the newly added ambits
      for (final ambit in isarAmbits) {
          await ambit.thematicList.save();
      }

      print('Migrated ${isarAmbits.length} thematic ambits and linked them.');

    }); // End Isar transaction

    print('\nMigration completed successfully!');

  } catch (e, s) {
    print('\nError during migration: $e');
    print(s);
  } finally {
    // --- Cleanup ---
    print('Closing databases...');
    await sqfliteDb.close();
    await isar.close();
    print('Databases closed.');
  }
} 