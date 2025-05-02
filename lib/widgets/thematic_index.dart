import 'package:adventist_hymnarium/locator.dart';
// REMOVED: import 'package:adventist_hymnarium/models/thematic_list.dart'; // Drift generates this
// REMOVED: import 'package:adventist_hymnarium/services/isar_service.dart';
import 'package:adventist_hymnarium/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:adventist_hymnarium/database/database.dart'; // Import Drift DB
import 'package:adventist_hymnarium/screens/thematic_category_screen.dart'; // Import the category screen

// TODO: Import ThematicCategoryScreen when created
// REMOVED: import 'package:adventist_hymnarium/screens/thematic_category_screen.dart';

class ThematicIndex extends StatefulWidget {
  const ThematicIndex({super.key});

  @override
  State<ThematicIndex> createState() => _ThematicIndexState();
}

class _ThematicIndexState extends State<ThematicIndex> {
  // REMOVED: final IsarService _isarService = locator<IsarService>();
  final SettingsService _settingsService = locator<SettingsService>();
  final AppDatabase _db = AppDatabase.instance; // Get Drift DB instance
  List<ThematicList> _categories = []; // Use Drift's ThematicList
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    // Listen for hymnal type changes to reload categories
    _settingsService.addListener(_loadCategories);
  }

  @override
  void dispose() {
    _settingsService.removeListener(_loadCategories);
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // REMOVED: final isar = _isarService.db;
      final selectedHymnalType = _settingsService.selectedHymnalType;
      print("Loading thematic categories for type: $selectedHymnalType");

      // Use Drift query
      final categories = await _db.getThematicListsSorted(selectedHymnalType);
      
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading thematic categories: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('No thematic categories found.'));
    }

    // Display the list of top-level categories
    return ListView.separated(
      itemCount: _categories.length,
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
      itemBuilder: (context, index) {
        final category = _categories[index];
        return ListTile(
          title: Text(
            category.thematic, // Display the category name (e.g., "Worship")
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            // Navigate to ThematicCategoryScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThematicCategoryScreen(category: category),
              ),
            );
          },
        );
      },
    );
  }
} 