import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:adventist_hymnarium/locator.dart';
import 'package:adventist_hymnarium/services/audio_service.dart';
// TODO: Import other necessary services when created (HymnalService, FavoritesManager etc.)
import 'package:adventist_hymnarium/services/hymnal_service.dart'; // Import HymnalService
import 'package:adventist_hymnarium/services/favorites_service.dart'; // Import FavoritesService
// import 'package:wakelock_plus/wakelock_plus.dart'; // Add when implementing Keep Screen On effect
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:get_it/get_it.dart';
import 'dart:io'; // Add import for File operations
import 'package:http/http.dart' as http; // Add import for HTTP requests
import 'package:path_provider/path_provider.dart'; // Add import for path_provider
import 'package:path/path.dart' as p; // Add import for path joining
import '../database/database.dart'; // Add import for AppDatabase
import 'dart:math'; // For temporary filename generation

// Define default values, similar to Swift's AppDefaults
class AppDefaults {
  static const double defaultFontSize = 16.0;
  static const double minFontSize = 12.0;
  static const double maxFontSize = 30.0;
  static const bool defaultShowVerseNumbers = true;
  static const bool defaultKeepScreenOn = true;
  static const bool defaultShowMiniPlayer = true;
  static const int defaultMaxRecentHymns = 10;
  static const int minRecentHymns = 5;
  static const int maxRecentHymns = 50;
  static const int stepRecentHymns = 5;
  // Default to the 1985 hymnal using the correct identifier
  static const String defaultHymnalType = 'en-newVersion';
}

class SettingsService extends ChangeNotifier {
  // Keys for SharedPreferences
  static const String _hymnalTypeKey = 'selectedHymnalType';
  static const String _fontSizeKey = 'fontSize';
  static const String _showVerseNumbersKey = 'showVerseNumbers';
  static const String _keepScreenOnKey = 'keepScreenOn';
  static const String _showMiniPlayerKey = 'showMiniPlayer';
  static const String _maxRecentHymnsKey = 'maxRecentHymns';
  static const String _keyDbUpdateUrl = 'db_update_url'; // Example key if we store URL
  static const String _databaseFilename = 'hymnarium_drift.db';
  // Using the actual URL from the iOS StorageService for now, corrected filename
  static const String _defaultDbDownloadUrl = 'https://adventisthymnarium.rockvilletollandsda.church/database/hymnarium.db';

  late SharedPreferences _prefs;
  // Remove locator calls from field initializers
  // final AudioService _audioService = locator<AudioService>(); 
  // final HymnalService _hymnalService = locator<HymnalService>();
  // final FavoritesService _favoritesService = locator<FavoritesService>();

  // State Variables
  String _selectedHymnalType = AppDefaults.defaultHymnalType;
  double _fontSize = AppDefaults.defaultFontSize;
  bool _showVerseNumbers = AppDefaults.defaultShowVerseNumbers;
  bool _keepScreenOn = AppDefaults.defaultKeepScreenOn;
  bool _showMiniPlayer = AppDefaults.defaultShowMiniPlayer;
  int _maxRecentHymns = AppDefaults.defaultMaxRecentHymns;
  bool _isDatabaseUpdating = false; // State for update progress
  bool _isUpdatingDb = false;
  String? _dbUpdateStatus;

  // Getters
  String get selectedHymnalType => _selectedHymnalType;
  double get fontSize => _fontSize;
  bool get showVerseNumbers => _showVerseNumbers;
  bool get keepScreenOn => _keepScreenOn;
  bool get showMiniPlayer => _showMiniPlayer;
  int get maxRecentHymns => _maxRecentHymns;
  bool get isDatabaseUpdating => _isDatabaseUpdating;
  bool get isUpdatingDb => _isUpdatingDb;
  String? get dbUpdateStatus => _dbUpdateStatus;
  // TODO: Add getters for db status/last updated when available from HymnalService

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _selectedHymnalType = _prefs.getString(_hymnalTypeKey) ?? AppDefaults.defaultHymnalType;
    _fontSize = _prefs.getDouble(_fontSizeKey) ?? AppDefaults.defaultFontSize;
    _showVerseNumbers = _prefs.getBool(_showVerseNumbersKey) ?? AppDefaults.defaultShowVerseNumbers;
    _keepScreenOn = _prefs.getBool(_keepScreenOnKey) ?? AppDefaults.defaultKeepScreenOn;
    _showMiniPlayer = _prefs.getBool(_showMiniPlayerKey) ?? AppDefaults.defaultShowMiniPlayer;
    _maxRecentHymns = _prefs.getInt(_maxRecentHymnsKey) ?? AppDefaults.defaultMaxRecentHymns;

    // Apply initial settings effects if needed (e.g., Wakelock)
    // _applyKeepScreenOnSetting();

    // No need to notify listeners on init, as consumers will read initial value
    print("SettingsService Initialized.");
    // Don't notifyListeners here, consumers read initial state
  }

  // Setters
  Future<void> setHymnalType(String type) async {
    final audioService = locator<AudioService>(); // Fetch AudioService here
    await audioService.stop(); // Stop audio before changing type
    if (_selectedHymnalType == type) return; // No change

    _selectedHymnalType = type;
    await _prefs.setString(_hymnalTypeKey, type);
    print("SettingsService: Hymnal type set to $_selectedHymnalType");
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    final clampedValue = value.clamp(AppDefaults.minFontSize, AppDefaults.maxFontSize);
     if (_fontSize == clampedValue) return;

    _fontSize = clampedValue;
    await _prefs.setDouble(_fontSizeKey, _fontSize);
    print("SettingsService: Font size set to $_fontSize");
    notifyListeners();
  }

  Future<void> setShowVerseNumbers(bool value) async {
     if (_showVerseNumbers == value) return;
    _showVerseNumbers = value;
    await _prefs.setBool(_showVerseNumbersKey, _showVerseNumbers);
    print("SettingsService: Show verse numbers set to $_showVerseNumbers");
    notifyListeners();
  }

  Future<void> setKeepScreenOn(bool value) async {
     if (_keepScreenOn == value) return;
    _keepScreenOn = value;
    await _prefs.setBool(_keepScreenOnKey, _keepScreenOn);
    print("SettingsService: Keep screen on set to $_keepScreenOn");
    // _applyKeepScreenOnSetting(); // Apply the effect immediately
    notifyListeners();
  }

  Future<void> setShowMiniPlayer(bool value) async {
     if (_showMiniPlayer == value) return;
    _showMiniPlayer = value;
    await _prefs.setBool(_showMiniPlayerKey, _showMiniPlayer);
     print("SettingsService: Show mini player set to $_showMiniPlayer");
    notifyListeners();
  }

   Future<void> setMaxRecentHymns(int value) async {
    final clampedValue = value.clamp(AppDefaults.minRecentHymns, AppDefaults.maxRecentHymns);
     if (_maxRecentHymns == clampedValue) return;
     _maxRecentHymns = clampedValue;
     await _prefs.setInt(_maxRecentHymnsKey, _maxRecentHymns);
     print("SettingsService: Max recent hymns set to $_maxRecentHymns");
     notifyListeners();
     // TODO: Trim recent hymns list if necessary via HymnalService
   }

  // --- Action Methods (Implement using injected services) ---

  Future<void> clearRecentHymns() async {
    // Fetch service inside the method
    final hymnalService = locator<HymnalService>(); 
    print("SettingsService: Calling HymnalService to clear recent hymns...");
    await hymnalService.clearRecentHymns(); // Use fetched service
    print("SettingsService: HymnalService finished clearing recent hymns.");
    // No need to notify listeners here unless SettingsService holds history state
  }

   Future<void> clearFavorites() async {
     // Fetch service inside the method
     final favoritesService = locator<FavoritesService>();
     print("SettingsService: Calling FavoritesService to clear favorites...");
     // Call methods on the fetched service
     await favoritesService.clearHymnFavorites();
     await favoritesService.clearReadingFavorites();
     print("SettingsService: FavoritesService finished clearing favorites.");
     // No need to notify listeners here unless SettingsService holds favorites state
   }

  Future<void> forceUpdateDatabase() async {
    // Fetch service if needed, e.g.:
    // final hymnalService = locator<HymnalService>();
    print("SettingsService: Starting database update...");
    // _isDatabaseUpdating = true; // Use _isUpdatingDb instead
    // notifyListeners(); // Show progress indicator

    // // TODO: Implement actual update logic, potentially calling HymnalService
    // // await hymnalService.forceUpdateDatabase();
    // await Future.delayed(const Duration(seconds: 3)); // Simulate network delay
    // print("SettingsService: Database update finished (Placeholder).");

    // // TODO: Update db status/timestamp based on result from HymnalService
    //  // _prefs.setDouble('database_last_updated', DateTime.now().millisecondsSinceEpoch / 1000.0);

    // _isDatabaseUpdating = false;
    // notifyListeners(); // Hide progress indicator, update status
    await updateDatabase(); // Call the actual update logic
  }

  Future<void> updateDatabase() async {
    if (_isUpdatingDb) return; // Prevent concurrent updates

    _isUpdatingDb = true;
    _dbUpdateStatus = "Starting update...";
    notifyListeners();
    print("$_dbUpdateStatus");

    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, _databaseFilename));
    final tempDbFile = File(p.join(dbFolder.path, '$_databaseFilename.temp'));
    final dbUrl = _prefs.getString(_keyDbUpdateUrl) ?? _defaultDbDownloadUrl;

    try {
      // 1. Download to temporary file
      _dbUpdateStatus = "Downloading database...";
      notifyListeners();
      print("$_dbUpdateStatus");
      final response = await http.get(Uri.parse(dbUrl));

      if (response.statusCode == 200) {
        await tempDbFile.writeAsBytes(response.bodyBytes, flush: true);
        print("Database downloaded successfully to ${tempDbFile.path}");

        // --- Dispose old services BEFORE closing DB ---
        print("Disposing existing services before DB close...");
        try {
          if (locator.isRegistered<HymnalService>()) {
            locator<HymnalService>().dispose(); // Call dispose to remove listeners
            print("Disposed existing HymnalService.");
          }
           if (locator.isRegistered<FavoritesService>()) {
            locator<FavoritesService>().dispose(); // Call dispose to remove listeners
            print("Disposed existing FavoritesService.");
          }
        } catch (e) {
           print("Error disposing existing services (proceeding anyway): $e");
        }
        // --- End dispose old services ---

        // 2. Close current connection
        _dbUpdateStatus = "Closing current database connection...";
        notifyListeners();
        print("$_dbUpdateStatus");
        await AppDatabase.closeDatabase(); // Close existing instance and set _instance = null

        // 3. File Operations
        _dbUpdateStatus = "Replacing database file...";
        notifyListeners();
        print("$_dbUpdateStatus");
        if (await dbFile.exists()) {
          print("Deleted existing database file: ${dbFile.path}");
          await dbFile.delete();
        }
        await tempDbFile.rename(dbFile.path);
        print("Replaced database file with downloaded version: ${dbFile.path}");

        // 4. Re-initialize
        _dbUpdateStatus = "Initializing new database connection...";
        notifyListeners();
        print("$_dbUpdateStatus");
        // This will now create a new instance because _instance is null
        await AppDatabase.initialize();
        // Get a reference to the NEW database instance immediately after creation - REMOVED
        // final AppDatabase newDbInstance = AppDatabase.instance;

        // --- RE-INTRODUCE CRUCIAL STEP: Reset dependent singletons in GetIt ---
        _dbUpdateStatus = "Resetting dependent services...";
        notifyListeners();
        print("$_dbUpdateStatus");
        // Unregister existing singletons that depend on AppDatabase
        if (locator.isRegistered<HymnalService>()) {
            locator.unregister<HymnalService>();
            print("Unregistered HymnalService.");
        }
        if (locator.isRegistered<FavoritesService>()) {
            locator.unregister<FavoritesService>();
            print("Unregistered FavoritesService.");
        }
        // Re-register them. They will now get the *new* AppDatabase.instance when first requested.
        // Make sure this registration logic matches locator.dart
        locator.registerLazySingleton<HymnalService>(() => HymnalService(AppDatabase.instance));
        print("Re-registered HymnalService.");
        locator.registerLazySingleton<FavoritesService>(() => FavoritesService(AppDatabase.instance, locator<SettingsService>()));
        print("Re-registered FavoritesService.");
        // --- END CRUCIAL STEP ---

        // 5. Notify services (Fetch NEW instances and reinitialize)
        _dbUpdateStatus = "Reloading application data...";
        notifyListeners();
        print("$_dbUpdateStatus");
        // --- CRUCIAL STEP: Reinitialize using NEW service instances ---
        try {
          // These calls will now get the NEWLY registered singleton instances
          final hymnalService = locator<HymnalService>();
          final favoritesService = locator<FavoritesService>();
          
          // Call the reverted reinitialize methods (no argument needed)
          await hymnalService.reinitialize(); 
          await favoritesService.reinitialize();
          
          print("Services re-initialized.");
        } catch (e, s) {
           print("Error re-initializing services after DB update: $e\n$s");
          _dbUpdateStatus = "Error reloading data: $e";
           // Decide if the update is still considered 'complete' or failed
        }
        // --- END CRUCIAL STEP: Reinitialize using NEW service instances ---

        _dbUpdateStatus = "Database update process completed.";
        print(_dbUpdateStatus);
      } else {
        print("Error downloading database: Status code ${response.statusCode}");
        _dbUpdateStatus = "Error downloading: ${response.statusCode}";
        // Consider deleting temp file if it exists
        if (await tempDbFile.exists()) {
          await tempDbFile.delete();
        }
      }
    } catch (e, s) {
      print("Error during database update: $e\n$s");
      _dbUpdateStatus = "Update failed: $e";
       // Consider deleting temp file if it exists
       if (await tempDbFile.exists()) {
         try { await tempDbFile.delete(); } catch (_) {}
       }
    } finally {
      _isUpdatingDb = false;
      notifyListeners(); // Update UI with final status
    }
  }

  // --- Helper Methods ---

  // Example: Apply Keep Screen On setting
  // void _applyKeepScreenOnSetting() {
  //   if (_keepScreenOn) {
  //     WakelockPlus.enable();
  //     print("Wakelock Enabled");
  //   } else {
  //     WakelockPlus.disable();
  //      print("Wakelock Disabled");
  //   }
  // }

  // Dispose method already exists implicitly in ChangeNotifier if not overridden
} 