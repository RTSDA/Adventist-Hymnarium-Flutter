import 'package:flutter/material.dart';
import 'package:adventist_hymnarium/widgets/thematic_index.dart';
import 'package:adventist_hymnarium/widgets/responsive_readings_list.dart';
import 'package:adventist_hymnarium/screens/hymn_list_screen.dart';
import 'package:adventist_hymnarium/locator.dart'; // Import locator
import 'package:adventist_hymnarium/services/settings_service.dart'; // Import SettingsService

class IndexScreen extends StatefulWidget { // Changed to StatefulWidget
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> with TickerProviderStateMixin { // Added TickerProviderStateMixin
  final SettingsService _settingsService = locator<SettingsService>();
  TabController? _tabController; // Make nullable

  bool get _showReadings => _settingsService.selectedHymnalType != 'en-oldVersion';

  @override
  void initState() {
    super.initState();
    _updateTabController();
    _settingsService.addListener(_handleSettingsChange);
  }

  @override
  void dispose() {
    _settingsService.removeListener(_handleSettingsChange);
    _tabController?.dispose(); // Dispose nullable controller
    super.dispose();
  }

  void _handleSettingsChange() {
    if (mounted) {
      // Check previous state based on controller nullability or length
       final bool previousShowReadings = _tabController?.length == 3;
       if (_showReadings != previousShowReadings) {
          setState(() {
             // Recreate controller with correct length
             _updateTabController(); 
          });
       } else {
         setState(() {});
       }
    }
  }

  void _updateTabController() {
     // Dispose existing controller before creating a new one
     _tabController?.dispose(); 
     
     _tabController = TabController(
        length: _showReadings ? 3 : 2, 
        vsync: this 
     );
     // Add listener to handle tab changes if needed (optional)
      _tabController?.addListener(() {
         // Handle tab index changes if necessary
         if (_tabController != null && _tabController!.indexIsChanging) {
            // print("Tab changed to: ${_tabController!.index}");
         }
      });
  }
  
  List<Widget> _getTabs() {
    final tabs = <Widget>[
      const Tab(text: 'Hymn List'),
      const Tab(text: 'Thematic Index'),
    ];
    if (_showReadings) {
      tabs.add(const Tab(text: 'Responsive Readings'));
    }
    return tabs;
  }

  List<Widget> _getTabViews() {
    final views = <Widget>[
      const HymnListScreen(),
      const ThematicIndex(),
    ];
    if (_showReadings) {
      views.add(const ResponsiveReadingsList());
    }
    return views;
  }

  @override
  Widget build(BuildContext context) {
    // Check if controller is initialized before building the dependent widgets
    if (_tabController == null) {
      // Return a loading indicator or empty container while initializing
      return Scaffold(
          appBar: AppBar(title: const Text('Index')), 
          body: const Center(child: CircularProgressIndicator())
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Index'),
        bottom: TabBar(
          controller: _tabController, 
          tabs: _getTabs(), 
        ),
      ),
      body: TabBarView(
        controller: _tabController, 
        children: _getTabViews(), 
      ),
    );
  }
} 