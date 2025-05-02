import 'package:drift/drift.dart'; // Import drift for runtime options
import 'package:adventist_hymnarium/locator.dart';
import 'package:adventist_hymnarium/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:adventist_hymnarium/database/database.dart';
import 'package:provider/provider.dart';
import 'package:adventist_hymnarium/services/settings_service.dart';
import 'package:adventist_hymnarium/services/hymnal_service.dart';
import 'package:adventist_hymnarium/services/favorites_service.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Tell drift not to warn about multiple database instances in debug mode
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  print("Drift multiple DB warning suppressed.");

  // Initialize the Drift database (copies from asset if needed)
  await AppDatabase.initialize();

  // Initialize GetIt locator
  await setupLocator();
  // Initialize Services that have an init method
  // Note: Provider can also handle initializing if needed via create/lazy:false
  await locator<SettingsService>().init();
  await locator<HymnalService>().init();
  await locator<FavoritesService>().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide multiple services using MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsService>(
          create: (_) => locator<SettingsService>(),
        ),
        ChangeNotifierProvider<FavoritesService>(
          create: (_) => locator<FavoritesService>(),
        ),
        // Add HymnalService here if it becomes a ChangeNotifier and needs to be watched
        // ChangeNotifierProvider<HymnalService>(
        //   create: (_) => locator<HymnalService>(),
        // ),
        ChangeNotifierProvider<HymnalService>(
           create: (_) => locator<HymnalService>(),
        ),
      ],
      child: MaterialApp(
        title: 'Adventist Hymnarium',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const MainScreen(),
      ),
    );
  }
}
