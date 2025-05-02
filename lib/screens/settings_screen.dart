import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:package_info_plus/package_info_plus.dart'; // Import package_info_plus
import 'package:adventist_hymnarium/locator.dart';
import 'package:adventist_hymnarium/services/settings_service.dart';
import './legal_screen.dart'; // Import LegalScreen
import './help_screen.dart'; // Import HelpScreen
// TODO: Import LegalScreen and HelpScreen when created
// import './legal_screen.dart';
// import './help_screen.dart';
import '../models/hymnal_info.dart'; // Correct import path for hymnal definitions

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Access settingsService via context.watch in build or use Consumer
  // final SettingsService _settingsService = locator<SettingsService>(); // Keep if needed for initState/dispose

  // Define the available hymnals and their display names here
  final Map<String, String> _availableHymnals = const {
    'en-newVersion': 'New Version (1985)',
    'en-oldVersion': 'Old Version (1941)',
    // Add other versions as needed
  };

  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    // No need to listen manually if using Provider for UI updates
    // _settingsService.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    // No need to remove listener if not added
    // _settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
         setState(() {
           _appVersion = packageInfo.version;
         });
      }
    } catch (e) {
      print("Error loading app version: $e");
       if (mounted) {
         setState(() {
           _appVersion = 'Error';
         });
      }
    }
  }

  // Method to show confirmation dialog
  Future<bool> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false when cancelled
                  },
                ),
                TextButton(
                  child: Text(confirmText, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true when confirmed
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer or context.watch to listen to SettingsService changes
    final settingsService = context.watch<SettingsService>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isUpdating = settingsService.isUpdatingDb;
    final updateStatus = settingsService.dbUpdateStatus;

    // Define hymnal options for SegmentedButton
    final List<ButtonSegment<String>> hymnalSegments = hymnalMap.entries.map((entry) {
      return ButtonSegment<String>(
          value: entry.key,
          label: Text(entry.value.shortName), // Use shortName from HymnalInfo
          // Adjust styling as needed
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      // Use Stack for overlaying progress indicator
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 20), // Add padding at the bottom
            children: [
              // --- Hymnal Section ---
              _buildSectionHeader(context, 'Hymnal'),
              ListTile(
                leading: const Icon(Icons.book_outlined),
                title: const Text('Hymnal Version'),
                // Replace DropdownButton with SegmentedButton in subtitle or adjust layout
                // trailing: DropdownButton<String>(...)
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SegmentedButton<String>(
                  style: SegmentedButton.styleFrom(
                     // Adjust visual density or padding if needed
                     visualDensity: VisualDensity.compact, 
                  ),
                  segments: hymnalSegments,
                  selected: <String>{settingsService.selectedHymnalType}, // Selection requires a Set
                  onSelectionChanged: (Set<String> newSelection) {
                    // SegmentedButton returns a Set, get the single selected value
                    if (newSelection.isNotEmpty) {
                      context.read<SettingsService>().setHymnalType(newSelection.first);
                    }
                  },
                  // Ensure only one can be selected
                  multiSelectionEnabled: false,
                  showSelectedIcon: false, // Optional: hide checkmark
                ),
              ),

              const Divider(height: 20, indent: 16, endIndent: 16),

              // --- Display Section ---
              _buildSectionHeader(context, 'Display'),
              SwitchListTile(
                title: const Text('Show Verse Numbers'),
                secondary: const Icon(Icons.format_list_numbered),
                value: settingsService.showVerseNumbers,
                onChanged: (bool value) {
                  context.read<SettingsService>().setShowVerseNumbers(value);
                },
              ),
              SwitchListTile(
                title: const Text('Show Mini Player'),
                secondary: const Icon(Icons.slideshow_outlined), // Example Icon
                value: settingsService.showMiniPlayer,
                onChanged: (bool value) {
                  context.read<SettingsService>().setShowMiniPlayer(value);
                },
              ),
              SwitchListTile(
                title: const Text('Keep Screen On'),
                secondary: const Icon(Icons.lightbulb_outline),
                value: settingsService.keepScreenOn,
                onChanged: (bool value) {
                  context.read<SettingsService>().setKeepScreenOn(value);
                  // Note: Actual wakelock enabling/disabling needs separate implementation
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_size),
                title: Text('Font Size', style: textTheme.titleMedium),
                subtitle: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Slider(
                       value: settingsService.fontSize,
                       min: AppDefaults.minFontSize,
                       max: AppDefaults.maxFontSize,
                       divisions: (AppDefaults.maxFontSize - AppDefaults.minFontSize).toInt(), // For steps of 1.0
                       label: settingsService.fontSize.round().toString(),
                       onChanged: (double value) {
                         context.read<SettingsService>().setFontSize(value);
                       },
                     ),
                     Center(
                       child: Text(
                         'Sample Text',
                         style: textTheme.bodyMedium?.copyWith(
                             fontSize: settingsService.fontSize
                         ),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                     const SizedBox(height: 8), // Add spacing below sample text
                   ],
                )
              ),

              const Divider(height: 20, indent: 16, endIndent: 16),

              // --- History Section ---
              _buildSectionHeader(context, 'History'),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Max Recent Hymns'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: 'Decrease',
                      onPressed: settingsService.maxRecentHymns <= AppDefaults.minRecentHymns
                        ? null // Disable if at min
                        : () {
                            context.read<SettingsService>().setMaxRecentHymns(
                              settingsService.maxRecentHymns - AppDefaults.stepRecentHymns
                            );
                          },
                    ),
                    Text(
                       settingsService.maxRecentHymns.toString(),
                       style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                       tooltip: 'Increase',
                      onPressed: settingsService.maxRecentHymns >= AppDefaults.maxRecentHymns
                        ? null // Disable if at max
                        : () {
                            context.read<SettingsService>().setMaxRecentHymns(
                              settingsService.maxRecentHymns + AppDefaults.stepRecentHymns
                            );
                          },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.delete_sweep_outlined, color: colorScheme.error),
                title: Text('Clear Recent Hymns', style: TextStyle(color: colorScheme.error)),
                onTap: () async {
                   final confirmed = await _showConfirmationDialog(
                     context: context,
                     title: 'Clear Recent Hymns?',
                     content: 'This will remove all hymns from your recent history.',
                     confirmText: 'Clear',
                   );
                   if (confirmed && mounted) {
                     context.read<SettingsService>().clearRecentHymns();
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Recent hymns cleared.')),
                     );
                   }
                },
              ),

              const Divider(height: 20, indent: 16, endIndent: 16),

              // --- Data Section ---
               _buildSectionHeader(context, 'Data'),
              ListTile(
                leading: Icon(Icons.favorite_border, color: colorScheme.error),
                title: Text('Clear Favorites', style: TextStyle(color: colorScheme.error)),
                onTap: () async {
                  final confirmed = await _showConfirmationDialog(
                    context: context,
                    title: 'Clear Favorites?',
                    content: 'This will remove all hymns and readings from your favorites.',
                    confirmText: 'Clear',
                  );
                  if (confirmed && mounted) {
                    context.read<SettingsService>().clearFavorites();
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Favorites cleared.')),
                     );
                  }
                },
              ),
              ListTile(
                leading: settingsService.isUpdatingDb 
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                    : const Icon(Icons.cloud_sync_outlined),
                title: const Text('Update Hymnal Database'),
                enabled: !settingsService.isUpdatingDb, 
                onTap: () async {
                   final confirmed = await _showConfirmationDialog(
                     context: context,
                     title: 'Update Hymnal Database?',
                     content: 'This will update the hymnal database to the latest version.',
                     confirmText: 'Update',
                   );
                   if (confirmed && mounted) {
                      context.read<SettingsService>().updateDatabase();
                   }
                },
              ),
              // TODO: Add ListTile for Database Last Updated (read from service)
              // TODO: Add ListTile for Database Status (read from service)

              const Divider(height: 20, indent: 16, endIndent: 16),

              // --- About Section ---
              _buildSectionHeader(context, 'About'),
              ListTile(
                 title: const Text('Help'),
                 leading: const Icon(Icons.help_outline),
                 onTap: () {
                   // TODO: Implement navigation to HelpScreen
                   // Navigator.push(context, MaterialPageRoute(builder: (context) => HelpScreen()));
                  //  ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text('Help screen coming soon!')),
                  //   );
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const HelpScreen()),
                   );
                 },
               ),
              ListTile(
                title: const Text('Legal Information'), // Changed from Privacy Policy for consistency
                leading: const Icon(Icons.gavel_outlined),
                onTap: () {
                  // TODO: Implement navigation to LegalScreen
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => LegalScreen()));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LegalScreen()),
                  );
                },
              ),
              ListTile(
                title: const Text('Version'),
                leading: const Icon(Icons.info_outline),
                trailing: Text(_appVersion, style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)),
                onTap: () { /* Maybe show more detailed info */ },
              ),
               ListTile(
                 title: const Text('Copyright'),
                 leading: const Icon(Icons.copyright),
                 trailing: Text(
                   settingsService.selectedHymnalType == 'en-newVersion'
                     ? "© 1985 Review and Herald®"
                     : "© 1941 Review and Herald®",
                   style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)
                 ),
               ),
            ],
          ),
          // --- Progress Indicator Overlay ---
          if (isUpdating)
            // Absorb pointer prevents interaction with the list below
            AbsorbPointer(
              absorbing: true, 
              child: Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent background
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            updateStatus ?? 'Processing...', // Display status message
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 