import 'package:flutter/foundation.dart';
import 'package:adventist_hymnarium/database/database.dart'; // Import AppDatabase
import 'package:drift/drift.dart'; // Import Drift for Value()
import 'package:adventist_hymnarium/services/settings_service.dart'; // Import SettingsService
import 'package:adventist_hymnarium/locator.dart'; // Import locator

class FavoritesService extends ChangeNotifier {
  final AppDatabase _db;
  final SettingsService _settingsService; // Inject SettingsService

  // Internal state for favorite lists
  List<Hymn> _favoriteHymns = [];
  List<ResponsiveReading> _favoriteReadings = [];
  bool _isLoading = true; // Add loading state

  // Public getters for the lists and loading state
  List<Hymn> get favoriteHymns => _favoriteHymns;
  List<ResponsiveReading> get favoriteReadings => _favoriteReadings;
  bool get isLoading => _isLoading;

  FavoritesService(this._db, this._settingsService);

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged); // Remove listener
    super.dispose();
  }

  Future<void> init() async {
    print("FavoritesService: Initializing and loading favorites...");
    await loadFavorites(); // Initial load
    _settingsService.addListener(_onSettingsChanged); // Add listener
    print("FavoritesService: Initialization complete.");
  }

  // Listener callback for settings changes
  void _onSettingsChanged() {
     print("FavoritesService: Detected settings change...");
     // *** IMPORTANT CHECK ***
     // Only reload if the database isn't currently being updated.
     // The reinitialize method handles reloading after the update is complete.
     if (!_settingsService.isUpdatingDb) {
        print("FavoritesService: Database not updating, reloading favorites due to settings change...");
        loadFavorites(); // Reload favorites when settings change (specifically hymnal type)
     } else {
       print("FavoritesService: Database is currently updating, skipping reload triggered by settings change.");
     }
  }

  // Method to load/reload favorites from DB into state
  Future<void> loadFavorites() async {
    // Don't proceed if service is already disposed
    // A check might be needed depending on listener timing vs dispose

    _isLoading = true;
    notifyListeners(); // Notify UI that loading has started
    
    // Get current hymnal type from SettingsService
    final currentHymnalType = _settingsService.selectedHymnalType;
    print("FavoritesService: Loading favorites for type: $currentHymnalType");

    try {
      // Pass hymnal type to the updated DB method
      _favoriteHymns = await _db.getFavoriteHymns(currentHymnalType);
      // Readings are not type-specific in the DB, load all
      _favoriteReadings = await _db.getFavoriteReadings();
       print("FavoritesService: Loaded ${_favoriteHymns.length} hymn(s) and ${_favoriteReadings.length} reading(s).");
    } catch (e) {
       print("FavoritesService: Error loading favorites: $e");
       // Handle error state if necessary
       _favoriteHymns = [];
       _favoriteReadings = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is finished
    }
  }

  // Method to re-run initialization logic after DB swap
  // Revert to original - no argument, just reload using internal _db
  Future<void> reinitialize() async {
    print("FavoritesService: Re-initializing after database update...");
    // Update the internal database reference BEFORE using it - REMOVED
    // _db = newDb; 
    // print("FavoritesService: Internal DB reference updated.");

    // Simply call loadFavorites, which uses the internal _db
    // This instance should be NEW after the locator reset
    await loadFavorites();

    // _isLoading = true;
    // notifyListeners(); // Notify UI that loading has started
    
    // // Get current hymnal type from SettingsService
    // final currentHymnalType = _settingsService.selectedHymnalType;
    // print("FavoritesService: Reloading favorites for type: $currentHymnalType using new DB instance.");

    // try {
    //   // Use the EXPLICITLY PASSED newDb instance, not the potentially stale _db
    //   _favoriteHymns = await newDb.getFavoriteHymns(currentHymnalType);
    //   _favoriteReadings = await newDb.getFavoriteReadings();
    //    print("FavoritesService: Reloaded ${_favoriteHymns.length} hymn(s) and ${_favoriteReadings.length} reading(s).");
    // } catch (e, s) {
    //    print("FavoritesService: Error reloading favorites during reinitialize: $e\n$s");
    //    // Handle error state if necessary
    //    _favoriteHymns = [];
    //    _favoriteReadings = [];
    // } finally {
    //   _isLoading = false;
    //   notifyListeners(); // Notify UI that loading is finished
    // }
  }

  Future<void> clearHymnFavorites() async {
    print("FavoritesService: Clearing hymn favorites...");
    await _db.clearHymnFavorites();
    _favoriteHymns = []; // Update internal state
    notifyListeners(); // Notify listeners after clearing
  }

   Future<void> clearReadingFavorites() async {
     print("FavoritesService: Clearing reading favorites...");
     await _db.clearReadingFavorites();
     _favoriteReadings = []; // Update internal state
     notifyListeners(); // Notify listeners after clearing
  }

  // --- Methods for Toggling Individual Favorites (will be needed by detail screens) ---

  // Helper method to check if a specific hymn is a favorite
  bool isHymnFavorite(Hymn hymn) {
    // Check based on composite key (number and hymnalType)
    return _favoriteHymns.any((fav) => 
        fav.number == hymn.number && fav.hymnalType == hymn.hymnalType);
  }

  // Helper method to check if a specific reading is a favorite
  bool isReadingFavorite(ResponsiveReading reading) {
    return _favoriteReadings.any((fav) => fav.number == reading.number);
  }

  Future<void> toggleHymnFavorite(Hymn hymn) async {
    // Optimistic update: Assume DB call succeeds for now
    final originalList = List<Hymn>.from(_favoriteHymns);
    final isCurrentlyFavorite = isHymnFavorite(hymn);
    final newStatus = !isCurrentlyFavorite;

    // Update in-memory list immediately
    if (newStatus) {
      _favoriteHymns.add(hymn.copyWith(isFavorite: Value(true)));
    } else {
      _favoriteHymns.removeWhere((fav) => fav.number == hymn.number && fav.hymnalType == hymn.hymnalType);
    }
    notifyListeners(); // Notify UI immediately with optimistic state

    try {
      await _db.toggleHymnFavorite(hymn); // Call the actual DB method
      print("FavoritesService: Toggled hymn favorite in DB.");
      // No reload needed here, state already updated optimistically
      // await loadFavorites(); 
    } catch (e) {
      print("FavoritesService: Error toggling hymn favorite in DB: $e. Reverting optimistic update.");
      // Revert in-memory state if DB update failed
      _favoriteHymns = originalList;
      notifyListeners(); 
    }
   }

   Future<void> toggleReadingFavorite(ResponsiveReading reading) async {
     // Optimistic update
     final originalList = List<ResponsiveReading>.from(_favoriteReadings);
     final isCurrentlyFavorite = _favoriteReadings.any((fav) => fav.number == reading.number);
     final newStatus = !isCurrentlyFavorite;

     // Update in-memory list immediately
     if (newStatus) {
       _favoriteReadings.add(reading.copyWith(isFavorite: Value(true)));
     } else {
       _favoriteReadings.removeWhere((fav) => fav.number == reading.number);
     }
      notifyListeners(); // Notify UI immediately

     try {
       await _db.toggleReadingFavorite(reading); // This DB method exists
       print("FavoritesService: Toggled reading favorite in DB.");
       // No reload needed here
       // await loadFavorites();
     } catch (e) {
        print("FavoritesService: Error toggling reading favorite in DB: $e. Reverting optimistic update.");
        // Revert in-memory state if DB update failed
        _favoriteReadings = originalList;
        notifyListeners();
     }
   }

  // TODO: Add methods for adding/removing/checking favorites for hymns and readings
  // TODO: Add getters for favorite lists

} 