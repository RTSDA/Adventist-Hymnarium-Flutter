import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

// Include the generated code from schema.dart
// part 'schema.drift.dart'; // Removed - Not needed for this setup
part 'database.g.dart'; // Standard drift generated part

// Table: hymns
// Corresponds to the 'hymns' table in SQLite
class Hymns extends Table {
  IntColumn get number => integer()(); // Assuming number is the primary key (Keep Non-nullable)
  TextColumn get title => text().nullable()();   // Allow NULL
  TextColumn get content => text().nullable()(); // Allow NULL
  TextColumn get hymnalType => text().named('hymnal_type').nullable()(); // Allow NULL - Changed below
  BoolColumn get isFavorite => boolean().nullable()(); // Allow NULL (column might not exist in source DB)

  @override
  Set<Column> get primaryKey => {number, hymnalType}; // Composite primary key
}

// Table: responsive_readings
@DataClassName('ResponsiveReading') // Ensure generated class is named correctly
class ResponsiveReadings extends Table {
  IntColumn get number => integer()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  BoolColumn get isFavorite => boolean().nullable().withDefault(const Constant(false))(); // Add isFavorite

  @override
  Set<Column> get primaryKey => {number};
}

// Table: history_entries (Reverted name)
@DataClassName('HistoryEntry') // Reverted name
class HistoryEntries extends Table { // Reverted name
  IntColumn get id => integer().autoIncrement()();
  // Link to hymn (nullable)
  IntColumn get hymnNumber => integer().named('hymn_number').nullable()(); 
  TextColumn get hymnalType => text().named('hymnal_type').nullable()(); 
  // Link to reading (nullable)
  IntColumn get readingNumber => integer().named('reading_number').nullable()(); 
  // Timestamp of when it was viewed
  DateTimeColumn get viewedAt => dateTime().named('viewed_at')(); 

  // Add constraints if needed...
}

// Table: thematic_lists
@DataClassName('ThematicList')
class ThematicLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get thematic => text()();
  TextColumn get hymnalType => text().named('hymnal_type')();
}

// Table: thematic_ambits
@DataClassName('ThematicAmbit')
class ThematicAmbits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ambit => text()();
  IntColumn get startNumber => integer().named('start_number')();
  IntColumn get endNumber => integer().named('end_number')();
  IntColumn get thematicListId => integer().named('thematic_list_id').references(ThematicLists, #id)();
}

// --- FTS5 Virtual Tables ---

// Define the FTS5 table for searching hymns
// @DriftTable(name: 'hymns_fts') // Removed - Table created via migration SQL
class HymnsFts extends Table {
  // The rowid of the hymns table this entry corresponds to.
  // Drift defaults to mapping this to `rowid` in fts5, which is correct.
  IntColumn get rowId => integer()(); 

  // Columns to be indexed by FTS5.
  // Names must match the columns in the main Hymns table.
  TextColumn get title => text()();
  TextColumn get content => text()();
}

// Define the FTS5 table for searching readings
// @DriftTable(name: 'readings_fts') // Removed - Table created via migration SQL
class ReadingsFts extends Table {
  IntColumn get rowId => integer()(); 
  TextColumn get title => text()();
  TextColumn get content => text()();
}

// --- Define Database Class ---

// Reference tables defined in schema.drift.dart
// Note: We no longer need the FTS table definitions here, 
// they are handled by the drift file and generation.
@DriftDatabase(tables: [
  Hymns, 
  ResponsiveReadings, 
  ThematicLists, 
  ThematicAmbits,
  HistoryEntries, // Use original table name
  // FTS tables (hymns_fts, readings_fts) are implicitly included 
  // via the schema.drift file processing, no need to list here.
])
class AppDatabase extends _$AppDatabase {
  // Store the executor to close it later
  final QueryExecutor _executor;
  // Schema version. Bump this when you change the schema.
  static const int _dbVersion = 3; // Bumped version for FTS table creation

  AppDatabase._internal(this._executor) : super(_executor);

  // Singleton instance
  static AppDatabase? _instance;
  static AppDatabase get instance {
    if (_instance == null) {
      throw Exception("Database not initialized. Call AppDatabase.initialize() first.");
    }
    return _instance!;
  }

  // Initialize the database
  static Future<void> initialize() async {
    if (_instance == null) {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'hymnarium_drift.db'));
      if (!await file.exists()) {
        print("Database file does not exist. Copying from assets...");
        try {
          if (!await dbFolder.exists()) {
            await dbFolder.create(recursive: true);
          }
          ByteData data = await rootBundle.load(p.join('assets', 'hymnarium.db'));
          List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await file.writeAsBytes(bytes, flush: true);
          print("Database copied successfully to ${file.path}");
        } catch (e) {
          print("Error copying database: $e");
          rethrow;
        }
      } else {
        print("Database file already exists at ${file.path}");
      }
      // Store the executor when creating the instance
      final executor = NativeDatabase(file);
      _instance = AppDatabase._internal(executor);
      print("Drift Database initialized.");
    }
  }

  // Method to close the database connection (Renamed to avoid conflict)
  static Future<void> closeDatabase() async {
    if (_instance != null) {
      await _instance!._executor.close(); // Close the underlying connection
      _instance = null;
      print("Drift Database connection closed.");
    } else {
      print("Drift Database connection already closed or not initialized.");
    }
  }

  // --- Data Access Methods ---
  Future<List<Hymn>> getHymnsByType(String hymnalType) {
     return (select(hymns)..where((tbl) => tbl.hymnalType.equals(hymnalType))).get();
  }

  Future<List<ResponsiveReading>> getAllReadingsSorted() {
     return (select(responsiveReadings)..orderBy([(t) => OrderingTerm(expression: t.number)])).get();
  }
   
  Future<List<ThematicList>> getThematicListsSorted(String hymnalType) {
    return (select(thematicLists)
           ..where((tbl) => tbl.hymnalType.equals(hymnalType))
           ..orderBy([(t) => OrderingTerm(expression: t.thematic)]))
           .get();
  }
   
  Future<int> upsertHymn(Hymn hymnData) {
      return into(hymns).insertOnConflictUpdate(hymnData);
  }

  Future<List<Hymn>> getFavoriteHymns(String hymnalType) {
    return (select(hymns)
            ..where((tbl) => tbl.isFavorite.equals(true) & tbl.hymnalType.equals(hymnalType)))
           .get();
  }

  Future<Hymn?> getHymnByNumberAndType(int hymnNumber, String hymnalType) {
    return (select(hymns)
            ..where((tbl) => tbl.number.equals(hymnNumber) & tbl.hymnalType.equals(hymnalType))
           ).getSingleOrNull();
  }

  Future<ResponsiveReading?> getReadingByNumber(int readingNumber) {
    return (select(responsiveReadings)..where((tbl) => tbl.number.equals(readingNumber))).getSingleOrNull();
  }

  Future<List<Hymn>> getHymnsByCategory(ThematicList category) async {
    // Find all ambits for the given category ID
    final ambits = await (select(thematicAmbits)..where((tbl) => tbl.thematicListId.equals(category.id))).get();

    if (ambits.isEmpty) {
      return [];
    }

    // Build a combined query condition for all ambits
    Expression<bool> condition = Constant(false);
    for (final ambit in ambits) {
      final ambitCondition = hymns.number.isBetweenValues(ambit.startNumber, ambit.endNumber);
      condition = condition | ambitCondition; // Combine with OR
    }

    // Select hymns matching the hymnal type and any of the ambit ranges
    final query = select(hymns)
      ..where((tbl) => tbl.hymnalType.equals(category.hymnalType) & condition)
      ..orderBy([(t) => OrderingTerm(expression: t.number)]);
      
    return query.get();
  }

  // Get all favorite readings, sorted by number
  Future<List<ResponsiveReading>> getFavoriteReadings() {
    return (select(responsiveReadings)..where((tbl) => tbl.isFavorite.equals(true))..orderBy([(t) => OrderingTerm(expression: t.number)])).get();
  }

  // Toggle favorite status for a responsive reading
  Future<void> toggleReadingFavorite(ResponsiveReading reading) async {
    final newStatus = !(reading.isFavorite ?? false); // Toggle current status (handle null)
    final updatedReading = reading.copyWith(isFavorite: Value(newStatus));
    await update(responsiveReadings).replace(updatedReading);
  }

  // Toggle favorite status for a hymn
  Future<void> toggleHymnFavorite(Hymn hymn) async {
    final newStatus = !(hymn.isFavorite ?? false); // Toggle current status (handle null)
    // Create a companion to update only the favorite status
    final companion = HymnsCompanion(
      isFavorite: Value(newStatus),
    );
    // Update the specific hymn using its composite key
    await (update(hymns)
            ..where((tbl) => tbl.number.equals(hymn.number) & tbl.hymnalType.equals(hymn.hymnalType!)))
           .write(companion);
     print("Favorites: Toggled favorite status for hymn ${hymn.number} (${hymn.hymnalType}) to $newStatus");
  }

  // --- Search Methods ---

  /// Basic search (LIKE matching) - Kept for reference or simpler search needs
  Future<List<Hymn>> searchHymnsBasic(String query, String hymnalType) {
    final searchTerm = '%$query%';
    final numberQuery = int.tryParse(query);

    return (select(hymns)
           ..where((tbl) =>
               tbl.hymnalType.equals(hymnalType) &
               (tbl.title.like(searchTerm) | (numberQuery != null ? tbl.number.equals(numberQuery) : Constant(false)))))
           .get();
  }

  /// Basic search (LIKE matching) - Kept for reference or simpler search needs
  Future<List<ResponsiveReading>> searchReadingsBasic(String query) {
    final searchTerm = '%$query%';
    final numberQuery = int.tryParse(query);
    
    return (select(responsiveReadings)
            ..where((tbl) =>
                tbl.title.like(searchTerm) | (numberQuery != null ? tbl.number.equals(numberQuery) : Constant(false))))
           .get();
  }
  
  /// Fetch all hymns for a specific hymnal type (for client-side search)
  Future<List<Hymn>> getAllHymnsForType(String hymnalType) {
    return (select(hymns)..where((tbl) => tbl.hymnalType.equals(hymnalType))).get();
  }
  
  /// Fetch all responsive readings (for client-side search)
  Future<List<ResponsiveReading>> getAllReadings() {
    return (select(responsiveReadings)).get();
  }

  // --- FTS Search Methods ---

  /// Searches hymns using FTS5.
  /// Returns a list of matching Hymn objects, ordered by relevance.
  Future<List<Hymn>> searchHymnsFTS(String query, String hymnalType) async {
    if (query.trim().isEmpty) return [];
    final ftsQuery = query.replaceAll('"', ' ').trim(); // Sanitize FIRST to remove user quotes
    if (ftsQuery.isEmpty) return [];

    print("['searchHymnsFTS'] Searching with term: '$ftsQuery', type: '$hymnalType'"); // DEBUG (Using plain term)

    // Use the table name specified in the .drift file for MATCH
    final results = await customSelect(
      '''
      SELECT h.* 
      FROM hymns h
      JOIN hymns_fts fts ON h.rowid = fts.rowid -- Use the actual FTS table name
      WHERE hymns_fts MATCH ? AND h.hymnal_type = ?
      ORDER BY rank;
      ''',
      variables: [Variable.withString(ftsQuery), Variable.withString(hymnalType)], // Use plain query
      // ReadsFrom helps drift know which tables are involved
      readsFrom: {hymns}, // Removed hymnsFtsView - Not a generated Dart table object
    ).get();

    print("['searchHymnsFTS'] Raw results count: ${results.length}"); // DEBUG

    return results.map((row) => hymns.map(row.data)).toList();
  }

  /// Searches readings using FTS5.
  /// Returns a list of matching ResponsiveReading objects, ordered by relevance.
  Future<List<ResponsiveReading>> searchReadingsFTS(String query) async {
    if (query.trim().isEmpty) return [];
    final ftsQuery = query.replaceAll('"', ' ').trim(); // Sanitize FIRST to remove user quotes
    if (ftsQuery.isEmpty) return [];

    print("['searchReadingsFTS'] Searching with term: '$ftsQuery'"); // DEBUG (Using plain term)

    final results = await customSelect(
      '''
      SELECT r.*
      FROM responsive_readings r
      JOIN readings_fts fts ON r.rowid = fts.rowid
      WHERE readings_fts MATCH ?
      ORDER BY rank;
      ''',
      variables: [Variable.withString(ftsQuery)], // Use plain query
      readsFrom: {responsiveReadings}, // Removed readingsFtsView - Not a generated Dart table object
    ).get();

    print("['searchReadingsFTS'] Raw results count: ${results.length}"); // DEBUG

    return results.map((row) => responsiveReadings.map(row.data)).toList();
  }

  // --- History Methods ---
  // /* // TEMPORARILY COMMENTED OUT FOR DEBUGGING - REVERTING
  Future<void> addHistoryEntry(Hymn? hymn, ResponsiveReading? reading) async {
    if (hymn == null && reading == null) return; // Nothing to add

    // Get the most recent history entry
    final lastEntry = await (select(historyEntries)
                              ..orderBy([(t) => OrderingTerm(expression: t.viewedAt, mode: OrderingMode.desc)])
                              ..limit(1)
                            ).getSingleOrNull();

    // Check if the item being added is the same as the most recent one
    bool isSameAsLast = false;
    if (lastEntry != null) {
      if (hymn != null && 
          lastEntry.hymnNumber == hymn.number && 
          lastEntry.hymnalType == hymn.hymnalType) {
        isSameAsLast = true;
      } else if (reading != null && // Use reverted parameter
                 lastEntry.readingNumber == reading.number) { // Use reverted parameter
        isSameAsLast = true;
      }
    }

    // If it's the same as the last entry, don't add it again
    if (isSameAsLast) {
      print("History: Item is same as last entry, skipping add.");
      return; 
    }

    // Create the companion object for insertion
    final companion = HistoryEntriesCompanion(
      hymnNumber: hymn != null ? Value(hymn.number) : const Value.absent(),
      hymnalType: hymn != null ? Value(hymn.hymnalType) : const Value.absent(),
      readingNumber: reading != null ? Value(reading.number) : const Value.absent(), // Use reverted parameter
      viewedAt: Value(DateTime.now()),
    );

    await into(historyEntries).insert(companion);
    print("History: Added entry - ${hymn != null ? 'Hymn ${hymn.number} (${hymn.hymnalType})' : 'Reading ${reading?.number}'}"); // Use reverted parameter
  }

  /// Fetches all history entries, ordered by most recently viewed.
  Future<List<HistoryEntry>> getHistoryEntries() {
    return (select(historyEntries)
            ..orderBy([(t) => OrderingTerm(expression: t.viewedAt, mode: OrderingMode.desc)])
          ).get();
  }

  /// Clears all entries from the history table.
  Future<void> clearHistory() async {
    await delete(historyEntries).go();
    print("History: Cleared all entries.");
  }
  // */ // END TEMPORARY COMMENT OUT - REVERTING

  // --- Favorites Clearing Methods ---

  /// Sets the isFavorite flag to false for all hymns.
  Future<void> clearHymnFavorites() async {
    final updatedRows = await (update(hymns)..where((tbl) => tbl.isFavorite.equals(true)))
                           .write(const HymnsCompanion(isFavorite: Value(false)));
    print("Favorites: Cleared hymn favorites for $updatedRows rows.");
  }

  /// Sets the isFavorite flag to false for all responsive readings.
  Future<void> clearReadingFavorites() async {
     final updatedRows = await (update(responsiveReadings)..where((tbl) => tbl.isFavorite.equals(true)))
                           .write(const ResponsiveReadingsCompanion(isFavorite: Value(false)));
     print("Favorites: Cleared reading favorites for $updatedRows rows.");
  }

  // --- Schema Version ---
  @override
  int get schemaVersion => _dbVersion; // Use the defined version

  // --- Migration Strategy ---
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        print("Running onCreate for all tables...");
        await m.createAll();
        // Explicitly add the column even on create, just in case?
        // Or assume createAll handles the latest schema.
        // Let's try adding it defensively in onUpgrade instead.
        print("onCreate: Creating FTS tables...");
        // Create FTS tables explicitly
        await m.issueCustomQuery('''
          CREATE VIRTUAL TABLE hymns_fts USING fts5 (
            title, content, content='hymns', content_rowid='rowid'
          );
        ''');
         await m.issueCustomQuery('''
          CREATE VIRTUAL TABLE readings_fts USING fts5 (
            title, content, content='responsive_readings', content_rowid='rowid'
          );
        ''');
        print("onCreate: FTS tables created.");
        
        // Populate FTS tables initially
        print("onCreate: Populating FTS tables...");
        await m.issueCustomQuery('INSERT INTO hymns_fts (rowid, title, content) SELECT rowid, title, content FROM hymns;');
        await m.issueCustomQuery('INSERT INTO readings_fts (rowid, title, content) SELECT rowid, title, content FROM responsive_readings;');
        print("onCreate: FTS tables populated.");

        print("onCreate finished.");
      },
      onUpgrade: (Migrator m, int from, int to) async {
        print("Running onUpgrade from version $from to $to...");
        if (from < 2) {
          // Migration logic to add the isFavorite column to the hymns table
          // This code runs if the existing database version is less than 2.
          try {
             print("onUpgrade (from < 2): Attempting to add 'isFavorite' column to 'hymns' table...");
            await m.addColumn(hymns, hymns.isFavorite);
             print("onUpgrade (from < 2): 'isFavorite' column added successfully (or already existed).");
          } catch (e) {
             print("onUpgrade (from < 2): Error adding 'isFavorite' column (might already exist): $e");
          }
           try {
             print("onUpgrade (from < 2): Attempting to add 'isFavorite' column to 'responsive_readings' table...");
            await m.addColumn(responsiveReadings, responsiveReadings.isFavorite);
             print("onUpgrade (from < 2): 'isFavorite' column added successfully to readings (or already existed).");
          } catch (e) {
             print("onUpgrade (from < 2): Error adding 'isFavorite' column to readings (might already exist): $e");
          }
        }
        if (from < 3) {
          // Migration logic to add FTS tables and populate them
          print("onUpgrade (from < 3): Creating and populating FTS tables...");
          try {
             // Create FTS tables explicitly
             await m.issueCustomQuery('''
              CREATE VIRTUAL TABLE hymns_fts USING fts5 (
                title, content, content='hymns', content_rowid='rowid'
              );
            ''');
             await m.issueCustomQuery('''
              CREATE VIRTUAL TABLE readings_fts USING fts5 (
                title, content, content='responsive_readings', content_rowid='rowid'
              );
            ''');
            print("onUpgrade (from < 3): FTS tables created (or already existed).");

            // Populate FTS tables (clear existing data first for safety? No, let's just insert)
            print("onUpgrade (from < 3): Populating FTS tables...");
            await m.issueCustomQuery('INSERT INTO hymns_fts (rowid, title, content) SELECT rowid, title, content FROM hymns;');
            await m.issueCustomQuery('INSERT INTO readings_fts (rowid, title, content) SELECT rowid, title, content FROM responsive_readings;');
            print("onUpgrade (from < 3): FTS tables populated.");

          } catch (e) {
            print("onUpgrade (from < 3): Error creating/populating FTS tables (might partially exist?): $e");
            // Might need more robust error handling if partial creation is possible
          }
        }
         print("onUpgrade finished.");
      },
       beforeOpen: (details) async {
         print("Running beforeOpen. Previous version: ${details.versionBefore}, Current version: ${details.versionNow}");
         if (details.wasCreated) {
           print("Database was just created.");
           // If you needed to seed data only on creation, do it here.
         }
         // You could also add columns here if needed, checking details.versionBefore
         print("Finished beforeOpen.");
       }
    );
  }
}
