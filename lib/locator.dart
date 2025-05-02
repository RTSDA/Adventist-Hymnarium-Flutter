import 'package:get_it/get_it.dart';
import 'package:adventist_hymnarium/services/audio_service.dart';
import 'package:adventist_hymnarium/services/media_service.dart';
import 'package:adventist_hymnarium/services/settings_service.dart';
import 'package:adventist_hymnarium/services/hymnal_service.dart';
import 'package:adventist_hymnarium/services/favorites_service.dart';
import 'package:adventist_hymnarium/database/database.dart'; // Import AppDatabase

// Instance of the service locator
final GetIt locator = GetIt.instance;

/// Registers services as singletons with the service locator.
Future<void> setupLocator() async {
  print('Registering services...');

  // Get database instance (assuming it's initialized)
  final AppDatabase db = AppDatabase.instance;

  // Register services as singletons, passing the db instance
  locator.registerLazySingleton<AudioService>(() => AudioService());
  locator.registerLazySingleton<SettingsService>(() => SettingsService());
  locator.registerLazySingleton<MediaService>(() => MediaService());
  locator.registerLazySingleton<HymnalService>(() => HymnalService(db));
  locator.registerLazySingleton<FavoritesService>(() => FavoritesService(db, locator<SettingsService>()));

  print("Service registration complete.");

  // Example of ensuring a service is ready if it has critical async init
  // print("Waiting for SettingsService...");
  // await locator.isReady<SettingsService>();
  // print("SettingsService is ready.");

  print("GetIt Locator setup fully complete.");
} 