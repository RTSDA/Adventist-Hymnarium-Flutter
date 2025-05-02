import 'package:adventist_hymnarium/screens/favorites_screen.dart';
import 'package:adventist_hymnarium/screens/number_pad_screen.dart';
import 'package:adventist_hymnarium/screens/index_screen.dart';
import 'package:adventist_hymnarium/screens/hymn_list_screen.dart';
import 'package:adventist_hymnarium/screens/settings_screen.dart';
// REMOVED: import 'package:adventist_hymnarium/screens/responsive_readings_screen.dart';
// REMOVED: import 'package:adventist_hymnarium/screens/thematic_index_screen.dart';
import 'package:flutter/material.dart';
import 'package:adventist_hymnarium/widgets/mini_player.dart';
import 'package:adventist_hymnarium/locator.dart'; // Import locator
import 'package:adventist_hymnarium/services/settings_service.dart'; // Import SettingsService
import 'package:provider/provider.dart';

// Placeholder screens for other tabs
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Screen - Coming Soon!')),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _previousHymnalType; // Store previous hymnal type

  // Create GlobalKeys for each persistent Navigator state
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Define the screens for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    NumberPadScreen(),
    IndexScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize previous hymnal type if it hasn't been set yet
    if (_previousHymnalType == null) {
      _previousHymnalType = context.read<SettingsService>().selectedHymnalType;
       print("MainScreen didChangeDependencies: Initialized _previousHymnalType to $_previousHymnalType");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Reset stacks function (extracted logic from old handler)
  void _resetNavigationStacks() {
     print("MainScreen: Resetting navigation stacks due to hymnal change.");
     // Schedule the pop operation for after the current frame
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (!mounted) return; 
       
       print("MainScreen: Executing post-frame stack reset.");
       for (var i = 0; i < _navigatorKeys.length; i++) {
           final key = _navigatorKeys[i];
           if (key.currentState != null && key.currentState!.canPop()) {
             print("Popping stack for navigator key index: $i");
             key.currentState!.popUntil((route) => route.isFirst);
           } else {
             // print("Navigator key index: $i has no current state or cannot pop.");
           }
       }
     });
  }

  void _onItemTapped(int index) {
    // Handle tapping the *same* tab - pop to root
    if (_selectedIndex == index) {
       _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
         _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch SettingsService for changes
    final settingsService = context.watch<SettingsService>();
    final currentHymnalType = settingsService.selectedHymnalType;

    // Check if hymnal type changed since last build
    if (_previousHymnalType != currentHymnalType) {
      print("MainScreen build: Detected hymnal type change from $_previousHymnalType to $currentHymnalType");
      // If changed, reset navigation stacks but DO NOT force tab switch
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) { // Ensure widget is still mounted
            // REMOVED 강제 탭 전환
            // setState(() {
            //    _selectedIndex = 0;
            // });
             _resetNavigationStacks(); // Reset navigator stacks only
         }
      });
    }
    // Update the previous value for the next build cycle
    _previousHymnalType = currentHymnalType;

    // Use IndexedStack to keep inactive tabs alive
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: List.generate(_widgetOptions.length, (index) {
                // Return a Navigator for each tab
                return Navigator(
                  key: _navigatorKeys[index], // Assign the key
                  onGenerateRoute: (RouteSettings settings) {
                    return MaterialPageRoute(
                      settings: settings,
                      builder: (BuildContext context) {
                        // Return the root widget for this tab
                        return _widgetOptions.elementAt(index);
                      },
                    );
                  },
                );
              }),
            ),
          ),
          // Conditionally display MiniPlayer based on settings
          if (settingsService.showMiniPlayer)
             const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.numbers),
            label: 'Number',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Index',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
} 