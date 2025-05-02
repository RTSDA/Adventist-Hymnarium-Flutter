import 'dart:async';
import 'package:adventist_hymnarium/database/database.dart';
import 'package:adventist_hymnarium/screens/hymn_detail_screen.dart';
import 'package:adventist_hymnarium/screens/responsive_reading_detail_screen.dart';
import 'package:adventist_hymnarium/services/settings_service.dart';
import 'package:adventist_hymnarium/locator.dart';
import 'package:flutter/material.dart';
import 'package:adventist_hymnarium/services/hymnal_service.dart';

// Combined class to hold either Hymn or Reading
class SearchResult {
  final Hymn? hymn;
  final ResponsiveReading? reading;
  final String title;
  final String subtitle;

  SearchResult({this.hymn, this.reading, required this.title, required this.subtitle});
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SettingsService _settingsService = locator<SettingsService>();

  List<SearchResult> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  // Keep track of the last searched query to avoid redundant searches
  String _lastSearchedQuery = "-"; // Initialize with a value that won't match an empty query

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final currentQuery = _searchController.text;
    if (currentQuery == _lastSearchedQuery) return; // Avoid searching the same query again
    
    // Reinstate debounce timer for performance on lower-end devices
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () { // Default debounce delay
      _performSearch(currentQuery);
    });

    // // Call search immediately on every text change (Removed)
    // _performSearch(currentQuery);
  }

  Future<void> _performSearch(String query) async {
    final trimmedQuery = query.trim();
    _lastSearchedQuery = query; // Store the actual query from the text field

    if (trimmedQuery.isEmpty) {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final currentHymnalType = _settingsService.selectedHymnalType;
    final List<SearchResult> combinedResults = [];

    // --- Get latest HymnalService instance HERE ---
    final HymnalService hymnalService = locator<HymnalService>();
    // --- End get latest instance ---

    try {
      // Search hymns using FTS5 via the service
      final hymns = await hymnalService.searchHymnsFTS(trimmedQuery, currentHymnalType);
      combinedResults.addAll(hymns.map((h) => SearchResult(
            hymn: h,
            title: '#${h.number} - ${h.title ?? ''}', // Handle potential null title
            subtitle: 'Hymn',
          )));

      // Search readings using FTS5 (if not old version) via the service
      if (currentHymnalType != 'en-oldVersion') {
        final readings = await hymnalService.searchReadingsFTS(trimmedQuery);
        combinedResults.addAll(readings.map((r) => SearchResult(
              reading: r,
              title: '#${r.number} - ${r.title}',
              subtitle: 'Reading',
            )));
      }
      
      // Note: Results from FTS5 are already ordered by relevance (rank).
      // We might want custom sorting later (e.g., grouping readings/hymns), 
      // but for now, we'll use the combined FTS rank order.

    } catch (e) {
      print("Search FTS error: $e");
      // Optionally show an error message in the UI
      if (mounted) {
         setState(() { 
            _results = []; // Clear results on error
            // TODO: Display error message in UI?
          });
      }
    } finally {
      if (mounted) {
        setState(() {
          // Only update results if the query hasn't changed since the search started
          if (_lastSearchedQuery == query) { 
             _results = combinedResults;
          }
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDetail(SearchResult result) {
    // Clear search and unfocus keyboard when navigating away
    // _searchController.clear(); // REMOVED: Keep search term on navigation
    FocusScope.of(context).unfocus(); 
    
    if (result.hymn != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HymnDetailScreen(hymn: result.hymn!),
        ),
      );
    } else if (result.reading != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResponsiveReadingDetailScreen(reading: result.reading!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showClearButton = _searchController.text.isNotEmpty;
    final bool hasResults = _results.isNotEmpty;
    final bool showEmptyMessage = !_isLoading && !hasResults;
    final String emptyResultMessage = _searchController.text.isEmpty
         ? 'Search by number, title, or lyrics' // Updated placeholder
         : 'No results found';
         
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search title, number, lyrics...', // Updated hint
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).appBarTheme.titleTextStyle?.color?.withOpacity(0.6)),
          ),
          style: TextStyle(color: Theme.of(context).appBarTheme.titleTextStyle?.color, fontSize: 18),
        ),
        actions: [
           if (showClearButton)
             IconButton(
               icon: const Icon(Icons.clear),
               tooltip: 'Clear Search',
               onPressed: () {
                 _searchController.clear();
                 // _onSearchChanged handles the update
               },
             ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : showEmptyMessage
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(emptyResultMessage, textAlign: TextAlign.center),
                  )
                )
              : ListView.builder(
                  // Add keyboard dismissal on scroll
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return ListTile(
                      title: Text(result.title),
                      subtitle: Text(result.subtitle),
                      onTap: () => _navigateToDetail(result),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
} 