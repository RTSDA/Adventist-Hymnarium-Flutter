import 'package:adventist_hymnarium/database/database.dart';
import 'package:adventist_hymnarium/screens/hymn_detail_screen.dart';
import 'package:adventist_hymnarium/screens/responsive_reading_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart'; // Import Provider
import 'package:adventist_hymnarium/services/hymnal_service.dart'; // Import HymnalService
import 'package:adventist_hymnarium/services/settings_service.dart'; // For clearing history action

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  // Method to get display title from HistoryEntry (can be moved to service or kept here)
  String _getItemTitle(HistoryEntry entry, HymnalService hymnalService) {
    // TODO: Need access to hymns/readings, potentially fetch from service or DB 
    // This is complex as HymnalService doesn't hold all hymns/readings directly
    // For now, just display IDs. A better approach is needed.
    if (entry.hymnNumber != null) {
      return 'Hymn #${entry.hymnNumber} (${entry.hymnalType})';
    } else if (entry.readingNumber != null) {
      return 'Reading #${entry.readingNumber}';
    }
    return 'Unknown Entry';
  }

  String _getItemSubtitle(HistoryEntry entry) {
    return DateFormat.yMMMd().add_jm().format(entry.viewedAt); // e.g., Sep 10, 2023, 5:00 PM
  }

  // Method to navigate (needs access to hymn/reading objects)
  void _navigateToDetail(BuildContext context, HistoryEntry entry, HymnalService hymnalService) async {
     // Fetch the hymn or reading using the service
     if (entry.hymnNumber != null && entry.hymnalType != null) {
        // Fetch Hymn
        print("History: Fetching hymn ${entry.hymnNumber} (${entry.hymnalType})");
        final hymn = await hymnalService.getHymn(entry.hymnNumber!, entry.hymnalType!);
        if (hymn != null && context.mounted) {
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: hymn)),
           );
        } else if (context.mounted){
           print("History: Could not fetch hymn ${entry.hymnNumber}");
           // Optional: Show error snackbar
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load hymn #${entry.hymnNumber}')));
        }
     } else if (entry.readingNumber != null) {
        // Fetch Reading
        print("History: Fetching reading ${entry.readingNumber}");
        final reading = await hymnalService.getReading(entry.readingNumber!);
         if (reading != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResponsiveReadingDetailScreen(reading: reading)),
            );
         } else if (context.mounted){
            print("History: Could not fetch reading ${entry.readingNumber}");
             // Optional: Show error snackbar
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load reading #${entry.readingNumber}')));
         }
     } else {
        print("History: Invalid history entry - no hymn or reading ID.");
     }
  }

  // Method to trigger clearing history via SettingsService
  void _clearHistory(BuildContext context) async {
     final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Clear History?'),
            content: const Text('Are you sure you want to delete all history entries? This cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Clear', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmed == true && context.mounted) {
         // Call the method on SettingsService, which calls HymnalService
         context.read<SettingsService>().clearRecentHymns(); 
         // Show snackbar confirmation
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('History cleared.')),
          );
      }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the HymnalService for changes
    final hymnalService = context.watch<HymnalService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          // Disable button if history is empty
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear History',
            onPressed: hymnalService.historyEntries.isEmpty 
                ? null 
                : () => _clearHistory(context), 
          ),
        ],
      ),
      body: Builder( // Use Builder to handle loading/empty states
         builder: (context) {
           if (hymnalService.isLoadingHistory) {
             return const Center(child: CircularProgressIndicator());
           } else if (hymnalService.historyEntries.isEmpty) {
             return const Center(child: Text('No history yet.'));
           } else {
             // Display the list from the service
             final historyItems = hymnalService.historyEntries;
             return ListView.builder(
               itemCount: historyItems.length,
               itemBuilder: (context, index) {
                 final entry = historyItems[index];
                 return ListTile(
                   // TODO: Update title logic once item fetching is implemented
                   title: Text(_getItemTitle(entry, hymnalService)),
                   subtitle: Text(_getItemSubtitle(entry)),
                   onTap: () => _navigateToDetail(context, entry, hymnalService),
                 );
               },
             );
           }
         },
      ),
    );
  }
} 