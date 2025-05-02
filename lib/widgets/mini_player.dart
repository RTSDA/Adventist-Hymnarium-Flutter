import 'package:adventist_hymnarium/locator.dart';
import 'package:adventist_hymnarium/screens/now_playing_screen.dart';
import 'package:adventist_hymnarium/services/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

// Placeholder for Now Playing Screen
// TODO: Move to own file and implement

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = locator<AudioService>();

    return ListenableBuilder(
      listenable: audioService,
      builder: (context, child) {
        final currentHymn = audioService.currentlyPlayingHymn;
        final playerState = audioService.playerState;

        // Only show if a hymn is loaded (playing, paused, or even stopped but still selected)
        if (currentHymn == null) {
          return const SizedBox.shrink(); // Don't show anything
        }

        bool isPlaying = playerState == PlayerState.playing;

        return Material(
          elevation: 8.0, // Add elevation for visual separation
          child: InkWell( // Make the whole bar tappable
            onTap: () {
              // Navigate to full Now Playing screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NowPlayingScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              // Use theme background color
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.95),
              height: 64.0, // Fixed height for mini player
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${currentHymn.number} - ${currentHymn.title ?? ''}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Play/Pause Button
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 32.0,
                    tooltip: isPlaying ? 'Pause' : 'Play',
                    onPressed: () {
                      // We need the URL again here - ideally AudioService holds it
                      // For now, let's just toggle based on state
                      if (isPlaying) {
                        audioService.pause();
                      } else { // Paused or stopped/completed
                        audioService.resume(); // Resume if paused, otherwise does nothing gracefully
                      }
                    },
                  ),
                  // Optional: Stop button
                  IconButton(
                    icon: const Icon(Icons.stop),
                    iconSize: 32.0,
                    tooltip: 'Stop',
                    onPressed: audioService.stop,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 