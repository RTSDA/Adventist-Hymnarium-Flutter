import 'package:flutter/material.dart';
import 'package:adventist_hymnarium/database/database.dart'; // Import the ResponsiveReading model
import 'package:flutter/widgets.dart'; // Import Widgets
// import 'package:adventist_hymnarium/widgets/responsive_reading_display.dart'; // REMOVED - Unused import
import 'package:adventist_hymnarium/locator.dart';
import 'package:adventist_hymnarium/services/settings_service.dart'; // ADDED Import
import 'package:provider/provider.dart'; // Import Provider
import 'package:adventist_hymnarium/services/favorites_service.dart'; // Import FavoritesService
import 'package:adventist_hymnarium/services/hymnal_service.dart'; // Import HymnalService

class ResponsiveReadingDetailScreen extends StatefulWidget {
  final ResponsiveReading reading;

  const ResponsiveReadingDetailScreen({super.key, required this.reading});

  @override
  State<ResponsiveReadingDetailScreen> createState() => _ResponsiveReadingDetailScreenState();
}

class _ResponsiveReadingDetailScreenState extends State<ResponsiveReadingDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    // Add to history when the screen initializes
    _addHistory();
  }

  void _loadUserPreferences() {
    // TODO: Implement loading user preferences if needed
    print("Placeholder: _loadUserPreferences called");
  }

  // Method to add to history using HymnalService
  Future<void> _addHistory() async {
    final Hymn? hymnToAdd = null;
    final ResponsiveReading? readingToAdd = widget.reading;
    try {
      // Call the service method using context.read
      await context.read<HymnalService>().addHistoryEntry(hymnToAdd, readingToAdd);
    } catch (e) {
      print("Error adding reading to history via service: $e");
    }
  }

  // Function to parse the reading content into paragraphs
  List<String> _parseReadingContent(String content) {
    // Split by double newline, similar to hymns, and trim whitespace
    return content.trim().split(RegExp(r'\n\s*\n')).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
  }

  // Function to determine the label for a paragraph index
  String _getParagraphLabel(int index, int totalParagraphs) {
    if (index == totalParagraphs - 1) {
      return "All";
    } else if (index % 2 == 0) {
      return "Leader";
    } else {
      return "Congregation";
    }
  }

  // Method to toggle favorite status using FavoritesService
  Future<void> _toggleFavorite() async {
     try {
       // Call the service method
       await context.read<FavoritesService>().toggleReadingFavorite(widget.reading);
     } catch (e) {
       print("Error toggling reading favorite via service: $e");
     }
  }

  @override
  Widget build(BuildContext context) {
    // Watch services
    final settingsService = context.watch<SettingsService>();
    final favoritesService = context.watch<FavoritesService>();
    // Check live favorite status from service
    // Need to add isReadingFavorite to FavoritesService first
    // For now, use potentially stale data for icon
    final bool isCurrentlyFavorite = favoritesService.isReadingFavorite(widget.reading);

    final paragraphs = _parseReadingContent(widget.reading.content);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color labelColor = Theme.of(context).colorScheme.primary; // Use primary color for labels

    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.reading.number}: ${widget.reading.title}'),
        actions: [ // Add actions for the favorite button
          IconButton(
            // Use live status from service
            icon: Icon(
              isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border,
              color: isCurrentlyFavorite ? Colors.red : null,
            ),
            tooltip: 'Favorite',
            onPressed: _toggleFavorite, // Call the updated toggle method
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // Adjust padding
        child: Center( // Center content horizontally
          child: ConstrainedBox( // Limit content width for readability
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center text within the column
              children: List.generate(paragraphs.length, (index) {
                final paragraph = paragraphs[index];
                final label = _getParagraphLabel(index, paragraphs.length);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0), // Increased spacing between paragraphs
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Center label and text
                    children: [
                      Text(
                        label,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: labelColor,
                          letterSpacing: 1.1, // Add slight letter spacing
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6.0), // Space between label and text
                      Text(
                        paragraph,
                        style: textTheme.bodyLarge?.copyWith(
                          height: 1.4, // Adjust line height
                          fontSize: settingsService.fontSize, // Apply font size from settings
                        ),
                        textAlign: TextAlign.center, 
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
} 