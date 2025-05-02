import 'package:adventist_hymnarium/locator.dart';
import 'package:adventist_hymnarium/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:adventist_hymnarium/screens/hymn_detail_screen.dart';
import 'package:adventist_hymnarium/database/database.dart'; // Import Drift DB

// Enum for sorting type within this screen
enum HymnSortType { az, number }

class HymnListScreen extends StatefulWidget {
  const HymnListScreen({super.key});

  @override
  State<HymnListScreen> createState() => _HymnListScreenState();
}

class _HymnListScreenState extends State<HymnListScreen> {
  final AppDatabase _db = AppDatabase.instance; // Get Drift DB instance
  final SettingsService _settingsService = locator<SettingsService>();
  List<Hymn> _hymns = []; // Use Drift's Hymn class
  bool _isLoading = true;
  String _currentHymnalType = '';
  List<Hymn> _displayHymns = []; // List to display after sorting/filtering
  HymnSortType _sortType = HymnSortType.number; // Default to #

  @override
  void initState() {
    super.initState();
    _currentHymnalType = _settingsService.selectedHymnalType;
    _loadHymns();
    _settingsService.addListener(_onSettingsChanged);
  }
  
  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    final newHymnalType = _settingsService.selectedHymnalType;
    if (_currentHymnalType != newHymnalType) {
      _currentHymnalType = newHymnalType;
      _loadHymns(); // Reload hymns if hymnal type changes
    } else {
      // If only theme changed, just rebuild
      setState(() {});
    }
  }

  Future<void> _loadHymns() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final selectedHymnalType = _settingsService.selectedHymnalType;
      print('Loading hymns for type: $selectedHymnalType');
      
      final hymns = await _db.getHymnsByType(selectedHymnalType);
      
      if (!mounted) return;
      setState(() {
        _hymns = hymns;
        _sortHymns(); // Apply initial sort based on default
        _isLoading = false;
      });
    } catch (e, s) {
      print("Error loading hymns: $e");
      print(s);
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Apply sorting based on the selected segment
  void _sortHymns() {
    List<Hymn> sortedHymns;

    // Helper function to clean titles for sorting
    String cleanTitleForSort(String? title) {
      if (title == null) return '';
      return title.toLowerCase().replaceAll(RegExp(r'^[^\w\s]+'), '').trim();
    }

    switch (_sortType) {
      case HymnSortType.az:
        sortedHymns = List.from(_hymns)
          ..sort((a, b) {
            final cleanedA = cleanTitleForSort(a.title);
            final cleanedB = cleanTitleForSort(b.title);
            return cleanedA.compareTo(cleanedB);
          });
        break;
      case HymnSortType.number:
        sortedHymns = List.from(_hymns)..sort((a, b) => a.number.compareTo(b.number));
        break;
    }
    _displayHymns = sortedHymns;
  }

  @override
  Widget build(BuildContext context) {
    final numberColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.lightBlueAccent
        : Theme.of(context).colorScheme.primary;

    Widget content;
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_displayHymns.isEmpty) {
       content = const Center(child: Text('No hymns found.'));
    } else {
       content = _buildHymnList(numberColor);
    }

    return Scaffold(
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilterChip(
                    label: const Text('Sort A-Z'),
                    selected: _sortType == HymnSortType.az,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _sortType = HymnSortType.az;
                          _sortHymns();
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Sort #'),
                    selected: _sortType == HymnSortType.number,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _sortType = HymnSortType.number;
                          _sortHymns();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: content), // Display the list
          ],
        ),
    );
  }

  // Helper method to build the hymn list view
  Widget _buildHymnList(Color numberColor) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_displayHymns.isEmpty) {
      return const Center(child: Text('No hymns found for this selection.'));
    }
    return ListView.separated(
      itemCount: _displayHymns.length,
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
      itemBuilder: (context, index) {
        final hymn = _displayHymns[index];
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
                  hymn.title ?? '', // Handle potential null title
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
              MaterialPageRoute(
                builder: (context) => HymnDetailScreen(hymn: hymn),
              ),
            );
          },
        );
      },
    );
  }
} 