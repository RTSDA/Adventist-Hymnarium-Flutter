import 'package:adventist_hymnarium/database/database.dart'; // Import for Hymn
import 'package:adventist_hymnarium/locator.dart';
import 'package:adventist_hymnarium/services/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

// Helper function to format duration
String formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return "$minutes:$seconds";
}

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});
  
  // Simple parsing logic (same as HymnDetailScreen)
  List<String> _parseLyrics(String? content) {
    if (content == null) return [];
    return content.trim().split(RegExp(r'\n\s*\n')); 
  }

  @override
  Widget build(BuildContext context) {
    final audioService = locator<AudioService>();
    
    return ListenableBuilder(
      listenable: audioService,
      builder: (context, child) {
        final currentHymn = audioService.currentlyPlayingHymn;
        final position = audioService.position;
        final duration = audioService.duration;
        final playerState = audioService.playerState;
        final isPlaying = playerState == PlayerState.playing;
        
        if (currentHymn == null) {
          // Keep the simple view if no hymn is active
          return Scaffold(
            appBar: AppBar(title: const Text('Now Playing')),
            body: const Center(child: Text('No hymn playing.')),
          );
        }

        final lyricsStanzas = _parseLyrics(currentHymn.content);

        return Scaffold(
          appBar: AppBar(title: const Text('Now Playing')),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(bottom: 20.0),
            child: Column(
              // Use Expanded for flexible layout
              children: [
                // --- Title Area --- 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '#${currentHymn.number} - ${currentHymn.title ?? 'Untitled'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                // --- Lyrics Area --- 
                Expanded(
                  child: SingleChildScrollView(
                     padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding for lyrics
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: lyricsStanzas.map((stanza) => Padding(
                         padding: const EdgeInsets.only(bottom: 16.0),
                         child: Text(
                           stanza.trim(),
                           style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                           textAlign: TextAlign.center,
                         ),
                       )).toList(),
                    ),
                  )
                ),
                // --- Slider Area (Conditional) ---
                if (duration.inSeconds > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Slider(
                          value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()), // Ensure value is clamped
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                          // Use onChangeStart and onChangeEnd for seeking
                          onChangeStart: (value) {
                            // Optional: You could temporarily pause playback while seeking 
                            // if you want, but often not necessary.
                            // audioService.pause(); 
                          },
                          onChanged: (value) {
                            // We only want to update the visual state during dragging,
                            // not constantly seek. Flutter's Slider handles the 
                            // visual update automatically if the value is driven by state.
                            // We might need a local state variable if we want immediate visual feedback
                            // *before* the audioService updates, but let's try without first.
                          },
                          onChangeEnd: (value) {
                            final newPosition = Duration(seconds: value.toInt());
                            print("Seeking to: $newPosition"); // Debug log
                            audioService.seek(newPosition);
                            // If we paused in onChangeStart, resume here:
                            // audioService.resume(); 
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatDuration(position)),
                              Text(formatDuration(duration)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else // Show SizedBox if slider is hidden to maintain some space
                   const SizedBox(height: 32.0), 

                // --- Controls Area --- 
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0), // Space at bottom
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play/Pause Button (Only control here as per reference)
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                        iconSize: 72.0,
                        onPressed: () {
                           if (isPlaying) {
                             audioService.pause();
                           } else {
                             audioService.resume();
                           }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 