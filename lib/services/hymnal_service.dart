import 'package:flutter/foundation.dart';
import 'package:adventist_hymnarium/database/database.dart'; // Import AppDatabase
import 'package:drift/drift.dart'; // Import Drift for Value()

class HymnalService extends ChangeNotifier {
  final AppDatabase _db;

  // Internal state for history
  List<HistoryEntry> _historyEntries = [];
  bool _isLoadingHistory = true;

  // Public getters
  List<HistoryEntry> get historyEntries => _historyEntries;
  bool get isLoadingHistory => _isLoadingHistory;

  HymnalService(this._db);

  Future<void> init() async {
    print("HymnalService: Initializing and loading history...");
    await loadHistory();
    print("HymnalService: Initialization complete.");
  }

  // Method to load/reload history from DB
  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      _historyEntries = await _db.getHistoryEntries();
      print("HymnalService: Loaded ${_historyEntries.length} history entries.");
    } catch (e) {
      print("HymnalService: Error loading history: $e");
      _historyEntries = [];
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // Method to re-run initialization logic after DB swap
  // Revert to original - no argument, just reload using internal _db
  Future<void> reinitialize() async {
    print("HymnalService: Re-initializing after database update...");
    // Update the internal database reference BEFORE using it - REMOVED
    // _db = newDb;
    // print("HymnalService: Internal DB reference updated.");

    // Simply call loadHistory, which uses the internal _db
    // This instance should be NEW after the locator reset
    await loadHistory();

    // _isLoadingHistory = true;
    // notifyListeners();
    // try {
    //    // Use the EXPLICITLY PASSED newDb instance, not the potentially stale _db
    //    _historyEntries = await newDb.getHistoryEntries();
    //    print("HymnalService: Reloaded ${_historyEntries.length} history entries using new DB instance.");
    //  } catch (e, s) {
    //    print("HymnalService: Error reloading history during reinitialize: $e\n$s");
    //    _historyEntries = [];
    //  } finally {
    //    _isLoadingHistory = false;
    //    notifyListeners();
    //  }
  }

  // Method to be called after database update
  // Future<void> reloadData() async { ... } // REMOVE or keep if needed elsewhere?
  // Let's remove reloadData for now to avoid confusion.

  Future<void> clearRecentHymns() async {
    print("HymnalService: Clearing recent hymns...");
    await _db.clearHistory(); // Call the actual database method
    _historyEntries = []; // Clear internal state
    notifyListeners(); // Notify listeners after clearing
  }

  // Method to add history entry (will be called from detail screens)
  Future<void> addHistoryEntry(Hymn? hymn, ResponsiveReading? reading) async {
    // Delegate the add operation (including duplicate check) to the database method
    try {
      await _db.addHistoryEntry(hymn, reading);
      print("HymnalService: addHistoryEntry called on DB.");
      // Reload history to ensure the list reflects the latest state 
      // (Handles both addition and potential skips due to duplicate check)
      await loadHistory();
    } catch (e) {
      print("HymnalService: Error calling DB addHistoryEntry: $e");
    }
  }

  // --- Data Fetching Methods ---

  Future<Hymn?> getHymn(int number, String hymnalType) async {
    // Directly call the database method
    return await _db.getHymnByNumberAndType(number, hymnalType);
  }

  Future<ResponsiveReading?> getReading(int number) async {
    // Directly call the database method
    return await _db.getReadingByNumber(number);
  }

  // --- Search Methods moved from direct DB access in screens ---
  
  /// Searches hymns using FTS5.
  /// Returns a list of matching Hymn objects, ordered by relevance.
  Future<List<Hymn>> searchHymnsFTS(String query, String hymnalType) async {
    // Delegate directly to the database method
    return await _db.searchHymnsFTS(query, hymnalType);
  }

  /// Searches readings using FTS5.
  /// Returns a list of matching ResponsiveReading objects, ordered by relevance.
  Future<List<ResponsiveReading>> searchReadingsFTS(String query) async {
    // Delegate directly to the database method
    return await _db.searchReadingsFTS(query);
  }

  /// Fetches all hymns for a specific hymnal type.
  Future<List<Hymn>> getHymnsByType(String hymnalType) async {
    return await _db.getHymnsByType(hymnalType);
  }

  /// Fetches all responsive readings.
  Future<List<ResponsiveReading>> getAllReadingsSorted() async {
     return await _db.getAllReadingsSorted();
  }

  /// Fetches hymns belonging to a specific thematic category.
  Future<List<Hymn>> getHymnsByCategory(ThematicList category) async {
    return await _db.getHymnsByCategory(category);
  }

  // TODO: Add other hymnal data related methods (get readings, etc. if needed)

  // TODO: Add methods for managing recent hymns (add hymn, get recent hymns)
  // TODO: Add methods for database status/update if this service handles it

} 