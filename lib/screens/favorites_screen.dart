import 'package:adventist_hymnarium/database/database.dart';
import 'package:adventist_hymnarium/screens/hymn_detail_screen.dart';
import 'package:adventist_hymnarium/screens/responsive_reading_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adventist_hymnarium/locator.dart';
import 'package:adventist_hymnarium/services/settings_service.dart';
import 'package:adventist_hymnarium/services/favorites_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabControllerIfNeeded();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _updateTabControllerIfNeeded() {
    final settingsService = context.read<SettingsService>();
    final showReadings = settingsService.selectedHymnalType != 'en-oldVersion';
    final needsTabController = showReadings;
    final hasTabController = _tabController != null;
    final tabLength = showReadings ? 2 : 0;

    if (needsTabController && (!hasTabController || _tabController!.length != tabLength)) {
        _tabController?.dispose();
        _tabController = TabController(length: tabLength, vsync: this);
    } else if (!needsTabController && hasTabController) {
        _tabController?.dispose();
        _tabController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<SettingsService>();
    final favoritesService = context.watch<FavoritesService>();

    final showReadings = settingsService.selectedHymnalType != 'en-oldVersion';

    if ((showReadings && _tabController == null) || (!showReadings && _tabController != null)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
           if(mounted) {
             setState(() {
                _updateTabControllerIfNeeded();
             });
           }
        });
    }

    final numberColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.lightBlueAccent
        : Theme.of(context).colorScheme.primary;

    AppBar appBar = AppBar(
       title: const Text('Favorites'),
       bottom: showReadings && _tabController != null
           ? TabBar(
               controller: _tabController,
               tabs: const [
                 Tab(text: 'Hymns'),
                 Tab(text: 'Readings'),
               ],
             )
           : null,
     );

    Widget body;
    if (favoritesService.isLoading) {
       body = const Center(child: CircularProgressIndicator());
    } else {
       if (showReadings && _tabController != null) {
         body = TabBarView(
           controller: _tabController,
           children: [
             _buildHymnsView(favoritesService, numberColor),
             _buildReadingsView(favoritesService, numberColor),
           ],
         );
       } else {
         body = _buildHymnsView(favoritesService, numberColor);
       }
    }

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }
  
  Widget _buildHymnsView(FavoritesService favoritesService, Color numberColor) {
     return favoritesService.favoriteHymns.isEmpty
             ? const Center(child: Text('No favorite hymns yet.'))
             : _buildHymnList(favoritesService.favoriteHymns, numberColor);
  }
  
  Widget _buildReadingsView(FavoritesService favoritesService, Color numberColor) {
     return favoritesService.favoriteReadings.isEmpty
             ? const Center(child: Text('No favorite readings yet.'))
             : _buildReadingList(favoritesService.favoriteReadings, numberColor);
  }

  Widget _buildHymnList(List<Hymn> favoriteHymns, Color numberColor) {
    return ListView.separated(
      itemCount: favoriteHymns.length,
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
      itemBuilder: (context, index) {
        final hymn = favoriteHymns[index];
        return ListTile(
          title: Row(
             children: [
               SizedBox(
                 width: 60.0,
                 child: Text(
                   '#${hymn.number}',
                   style: TextStyle(
                     color: numberColor,
                     fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                   ),
                   textAlign: TextAlign.left,
                 ),
               ),
               Expanded(
                 child: Text(
                   hymn.title ?? 'Untitled Hymn',
                   style: Theme.of(context).textTheme.bodyLarge,
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                 ),
               ),
             ],
           ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: hymn)),
            );
          },
        );
      },
    );
  }

  Widget _buildReadingList(List<ResponsiveReading> favoriteReadings, Color numberColor) {
    return ListView.separated(
      itemCount: favoriteReadings.length,
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
      itemBuilder: (context, index) {
        final reading = favoriteReadings[index];
        return ListTile(
           title: Row(
            children: [
              SizedBox(
                width: 60.0,
                child: Text(
                  '#${reading.number}',
                  style: TextStyle(
                    color: numberColor,
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(
                child: Text(
                  reading.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResponsiveReadingDetailScreen(reading: reading)),
            );
          },
        );
      },
    );
  }
} 