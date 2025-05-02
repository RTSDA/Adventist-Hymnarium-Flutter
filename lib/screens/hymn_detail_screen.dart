import 'package:adventist_hymnarium/database/database.dart';
import 'package:adventist_hymnarium/screens/sheet_music_screen.dart'; // Import SheetMusicScreen
import 'package:adventist_hymnarium/screens/now_playing_screen.dart'; // Correct import for NowPlayingScreen
import 'package:adventist_hymnarium/widgets/mini_player.dart'; // Import NowPlayingScreen placeholder
import 'package:adventist_hymnarium/services/media_service.dart'; // Needed later for actions
import 'package:adventist_hymnarium/locator.dart'; // Needed later for actions
import 'package:adventist_hymnarium/services/audio_service.dart'; // Import AudioService
import 'package:adventist_hymnarium/services/settings_service.dart';
import 'package:adventist_hymnarium/services/favorites_service.dart'; // Import FavoritesService
import 'package:adventist_hymnarium/services/hymnal_service.dart'; // Import HymnalService
import 'package:audioplayers/audioplayers.dart'; // Import PlayerState
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column; // <-- HIDE Column from Drift
import 'package:provider/provider.dart'; // Import Provider

// TODO: Implement actual hymn detail view with parsing, actions, etc.
class HymnDetailScreen extends StatefulWidget { // Changed to StatefulWidget for potential state changes (like favorite)
  final Hymn hymn;
  const HymnDetailScreen({super.key, required this.hymn});

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  // Remove direct DB access
  // final AppDatabase _db = AppDatabase.instance; 
  late Future<List<String>> _availableSheetsFuture;
  // Keep services needed for actions, but FavoritesService will be read from context
  final MediaService _mediaService = locator<MediaService>(); 
  final AudioService _audioService = locator<AudioService>(); 
  final SettingsService _settingsService = locator<SettingsService>();

  @override
  void initState() {
    super.initState();
    _availableSheetsFuture = _fetchAvailableSheets();
    _loadUserPreferences();
    // Remove local state initialization
    // _isFavorite = widget.hymn.isFavorite ?? false;
    _settingsService.addListener(_onSettingsChanged);
    // Add to history when the screen initializes
    _addHistory();
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    // Rebuild if settings (like theme) change
    if (mounted) {
      setState(() {});
    }
  }

  // Method to toggle favorite status using FavoritesService
  Future<void> _toggleFavorite() async {
    try {
      // Call the service method
      await context.read<FavoritesService>().toggleHymnFavorite(widget.hymn);
      // Optional: Show a snackbar or confirmation
      // ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Favorite status updated')) );
    } catch (e) {
      print("Error toggling favorite via service: $e");
      // Optional: Show error message
      // ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error updating favorite')) );
    }
  }

  // Method to add to history using HymnalService
  Future<void> _addHistory() async {
    // final AppDatabase db = AppDatabase.instance; // No longer needed here
    final Hymn? hymnToAdd = widget.hymn;
    final ResponsiveReading? readingToAdd = null;
    try {
      // Call the service method using context.read
      await context.read<HymnalService>().addHistoryEntry(hymnToAdd, readingToAdd);
    } catch (e) {
      print("Error adding hymn to history via service: $e");
    }
  }

  Future<List<String>> _fetchAvailableSheets() async {
    // Implementation of _fetchAvailableSheets method
    // This is a placeholder and should be replaced with the actual implementation
    return [];
  }

  // ADDED: Stub method
  void _loadUserPreferences() {
    // TODO: Implement loading user preferences if needed for this screen
    print("Placeholder: _loadUserPreferences called in HymnDetailScreen");
  }

  // Simple parsing: split by double newline. Needs refinement.
  List<String> _parseLyrics(String? content) { // Accept nullable content
    if (content == null) return []; // Return empty list if content is null
    return content.trim().split(RegExp(r'\n\s*\n')).where((s) => s.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Watch services
    final settingsService = context.watch<SettingsService>();
    final favoritesService = context.watch<FavoritesService>();
    final bool showNumbers = settingsService.showVerseNumbers;
    final currentFontSize = settingsService.fontSize;
    final bool isNewVersion = widget.hymn.hymnalType == 'en-newVersion'; // Check hymnal type

    // Check favorite status
    final bool isCurrentlyFavorite = favoritesService.isHymnFavorite(widget.hymn);

    // Parse lyrics into stanzas
    final stanzas = _parseLyrics(widget.hymn.content);

    final bool hasSheetMusic = isNewVersion;

    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.hymn.number}'), // Number is non-nullable
        actions: [
          // Placeholder Actions
          if (hasSheetMusic)
            IconButton(
              icon: const Icon(Icons.music_note_outlined), // Or Icons.description for PDF?
              tooltip: 'Sheet Music',
              onPressed: () {
                // Navigate to SheetMusicScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SheetMusicScreen(hymn: widget.hymn),
                  ),
                );
              },
            ),
          // Use ListenableBuilder to react to AudioService changes
          ListenableBuilder(
            listenable: _audioService,
            builder: (context, child) {
              // Use number for comparison
              final bool isPlayingThisHymn = 
                  _audioService.isPlaying && 
                  _audioService.currentlyPlayingHymn?.number == widget.hymn.number;
              final bool isPausedThisHymn = 
                  _audioService.playerState == PlayerState.paused &&
                  _audioService.currentlyPlayingHymn?.number == widget.hymn.number;
              
              // Check if loading this specific hymn
              final bool isLoadingThisHymn = 
                  _audioService.isLoading &&
                  _audioService.currentlyPlayingHymn?.number == widget.hymn.number;
              
              // Determine icon based on loading, playing, paused state
              IconData playIcon = Icons.play_circle_outline;
              String tooltip = 'Play Audio';
              Widget? iconWidget; // Use Widget? for potential ProgressIndicator

              if (isLoadingThisHymn) {
                 iconWidget = const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
                 tooltip = 'Loading Audio...';
              } else if (isPlayingThisHymn) {
                playIcon = Icons.pause_circle_outline;
                tooltip = 'Pause Audio';
              } else if (isPausedThisHymn) {
                playIcon = Icons.play_circle_outline;
                tooltip = 'Resume Audio';
              }
              // If not loading, use the determined icon
              iconWidget ??= Icon(playIcon);

              return IconButton(
                icon: iconWidget, // Use the widget (Icon or Indicator)
                iconSize: 28, 
                tooltip: tooltip,
                // Disable button while loading this hymn
                onPressed: isLoadingThisHymn ? null : () {
                  if (isPlayingThisHymn) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const NowPlayingScreen()),
                     );
                  } else {
                    // Toggle now only needs the hymn object
                    _audioService.togglePlayPause(widget.hymn);
                  }
                },
              );
            },
          ),
          IconButton(
            // Use the live status from the watched service
            icon: Icon(
              isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border,
              color: isCurrentlyFavorite ? Colors.red : null, 
            ),
            tooltip: 'Favorite',
            onPressed: _toggleFavorite, // Call the updated method
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display hymn title 
                Text(
                  widget.hymn.title ?? 'Untitled Hymn',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Build lyrics section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(stanzas.length, (index) {
                    String stanzaText = stanzas[index].trim();
                    String originalStanzaText = stanzaText; // Keep original for checks
                    String? label;
                    bool isActualChorus = false; // Flag if identified as chorus/refrain
                    
                    // Identify Chorus/Refrain based on prefix
                    if (stanzaText.toUpperCase().startsWith("CHORUS:")) {
                      isActualChorus = true;
                      label = "Chorus";
                    } else if (!isNewVersion && stanzaText.startsWith("Refrain")) {
                       // Check for "Refrain" specifically in old version
                       isActualChorus = true;
                       label = "Refrain";
                    }
                    
                    // Assign Verse label if not a chorus/refrain
                    if (!isActualChorus) {
                       label = "Verse ${index + 1}"; // Simple index-based label for now
                       // TODO: Could try parsing number for 1985 if needed, 
                       // but requires more complex regex matching within the loop.
                    }

                    // Process stanza text based on settings
                    if (showNumbers) {
                       // If showing labels, clean up the text a bit more consistently
                       // Remove CHORUS: prefix always if label is shown
                       if (label == "Chorus") {
                          stanzaText = stanzaText.replaceFirst(RegExp(r'^CHORUS:\s*', caseSensitive: false), '').trim();
                       }
                       // Remove Refrain prefix always if label is shown
                       else if (label == "Refrain") {
                          stanzaText = stanzaText.replaceFirst(RegExp(r'^Refrain\s*', caseSensitive: false), '').trim();
                       }
                       // ONLY remove leading number for 1985 version 
                       else if (isNewVersion) {
                          stanzaText = stanzaText.replaceFirst(RegExp(r'^\d+\.?\s+'), '').trim();
                       }
                    } else {
                       // If hiding labels, remove all potential prefixes
                       stanzaText = stanzaText.replaceFirst(RegExp(r'^CHORUS:\s*', caseSensitive: false), '').trim();
                       stanzaText = stanzaText.replaceFirst(RegExp(r'^Refrain\s*', caseSensitive: false), '').trim();
                       if (isNewVersion) {
                          stanzaText = stanzaText.replaceFirst(RegExp(r'^\d+\.?\s+'), '').trim();
                       }
                       // Hide the label itself
                       label = null; 
                    }

                    // Build the widgets for this stanza
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (label != null) // Display label if it exists
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                label,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.secondary, // Use secondary color for label
                                      fontSize: currentFontSize - 2, // Adjust label size relative to main text
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Text(
                            stanzaText, // Display processed text
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.5, 
                                  fontSize: currentFontSize, // Apply font size
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 